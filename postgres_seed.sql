-- ============================================
-- SEED DATA - Tạo ~1M bản ghi
-- Script cho PostgreSQL
-- Thời gian chạy: ~30-60 giây
-- ============================================

-- ============================================
-- 1. CITIES (63 tỉnh/thành)
-- ============================================
INSERT INTO cities (name, region) VALUES
('Hà Nội', 'Bắc'),
('TP. Hồ Chí Minh', 'Nam'),
('Đà Nẵng', 'Trung'),
('Hải Phòng', 'Bắc'),
('Cần Thơ', 'Nam'),
('Biên Hòa', 'Nam'),
('Huế', 'Trung'),
('Nha Trang', 'Trung'),
('Vũng Tàu', 'Nam'),
('Đà Lạt', 'Trung'),
('Quy Nhơn', 'Trung'),
('Buôn Ma Thuột', 'Trung'),
('Thái Nguyên', 'Bắc'),
('Nam Định', 'Bắc'),
('Vinh', 'Trung'),
('Thanh Hóa', 'Trung'),
('Hạ Long', 'Bắc'),
('Phan Thiết', 'Nam'),
('Cà Mau', 'Nam'),
('Rạch Giá', 'Nam');

-- ============================================
-- 2. CATEGORIES (Danh mục - có cây phân cấp cho recursive CTE)
-- ============================================
-- Level 1: Root categories
INSERT INTO categories (id, name, parent_id) VALUES
(1, 'Điện tử', NULL),
(2, 'Thời trang', NULL),
(3, 'Nhà cửa & Đời sống', NULL),
(4, 'Sách & Văn phòng phẩm', NULL),
(5, 'Thể thao & Du lịch', NULL);

-- Level 2: Sub-categories
INSERT INTO categories (id, name, parent_id) VALUES
(6,  'Điện thoại', 1),
(7,  'Laptop', 1),
(8,  'Phụ kiện', 1),
(9,  'Tablet', 1),
(10, 'Áo', 2),
(11, 'Quần', 2),
(12, 'Giày dép', 2),
(13, 'Túi xách', 2),
(14, 'Nội thất', 3),
(15, 'Nhà bếp', 3),
(16, 'Trang trí', 3),
(17, 'Sách', 4),
(18, 'VPP', 4),
(19, 'Thể thao', 5),
(20, 'Du lịch', 5);

-- Level 3: Sub-sub-categories
INSERT INTO categories (id, name, parent_id) VALUES
(21, 'iPhone', 6),
(22, 'Samsung', 6),
(23, 'Xiaomi', 6),
(24, 'MacBook', 7),
(25, 'ThinkPad', 7),
(26, 'Ốp lưng', 8),
(27, 'Sạc & Cáp', 8),
(28, 'Tai nghe', 8),
(29, 'iPad', 9),
(30, 'Samsung Tab', 9);

-- Reset sequence
SELECT setval('categories_id_seq', 30);

-- ============================================
-- 3. PRODUCTS (500 sản phẩm)
-- ============================================
INSERT INTO products (name, category_id, price, stock, status, created_at)
SELECT
    'Product ' || s.id || ' - ' || c.name,
    c.id,
    -- Giá theo category: điện tử đắt, VPP rẻ
    CASE
        WHEN c.id IN (21,22,23) THEN round((random() * 20000000 + 5000000)::numeric, -3)   -- Điện thoại: 5M-25M
        WHEN c.id IN (24,25) THEN round((random() * 30000000 + 15000000)::numeric, -3)     -- Laptop: 15M-45M
        WHEN c.id IN (29,30) THEN round((random() * 15000000 + 8000000)::numeric, -3)      -- Tablet: 8M-23M
        WHEN c.id IN (26,27,28) THEN round((random() * 500000 + 50000)::numeric, -3)       -- Phụ kiện: 50K-550K
        WHEN c.id BETWEEN 10 AND 13 THEN round((random() * 2000000 + 100000)::numeric, -3) -- Thời trang: 100K-2.1M
        WHEN c.id BETWEEN 14 AND 16 THEN round((random() * 5000000 + 500000)::numeric, -3) -- Nhà cửa: 500K-5.5M
        WHEN c.id IN (17,18) THEN round((random() * 200000 + 20000)::numeric, -3)          -- Sách/VPP: 20K-220K
        ELSE round((random() * 1000000 + 100000)::numeric, -3)                             -- Khác: 100K-1.1M
    END,
    floor(random() * 1000)::int,
    CASE WHEN random() < 0.05 THEN 'discontinued'
         WHEN random() < 0.15 THEN 'inactive'
         ELSE 'active'
    END,
    CURRENT_TIMESTAMP - (random() * interval '730 days')
FROM generate_series(1, 500) s(id)
CROSS JOIN LATERAL (
    SELECT id, name FROM categories
    WHERE id = (s.id % 30) + 1
) c;

-- ============================================
-- 4. CUSTOMERS (50,000 khách hàng)
-- ============================================
INSERT INTO customers (name, email, phone, city_id, membership, created_at)
SELECT
    'Customer ' || s.id,
    'customer' || s.id || '@' ||
        (ARRAY['gmail.com','yahoo.com','outlook.com','hotmail.com','mail.com'])[floor(random()*5+1)::int],
    '09' || lpad((floor(random() * 100000000))::text, 8, '0'),
    floor(random() * 20 + 1)::int,
    (ARRAY['bronze','bronze','bronze','silver','silver','gold','platinum'])[floor(random()*7+1)::int],
    CURRENT_TIMESTAMP - (random() * interval '1095 days')  -- 3 năm
FROM generate_series(1, 50000) s(id);

INSERT INTO orders (customer_id, status, total_amount, shipping_fee, created_at)
SELECT
    floor(random() * 50000 + 1)::int,
    (ARRAY['pending','confirmed','confirmed','shipped','shipped','delivered','delivered','delivered','delivered','cancelled'])
        [floor(random()*10+1)::int],
    0,
    CASE 
        WHEN random() < 0.3 THEN 0
        WHEN random() < 0.7 THEN 30000
        ELSE 50000
    END,
    CURRENT_TIMESTAMP - ((random() ^ 2) * interval '730 days')
FROM generate_series(1, 100);

INSERT INTO order_items (order_id, product_id, quantity, unit_price, subtotal)
SELECT
    o.id,
    p.id,
    floor(random() * 5 + 1)::int AS qty,
    p.price,
    p.price * floor(random() * 5 + 1)::int
FROM (
    SELECT id 
    FROM orders 
    ORDER BY id DESC 
    LIMIT 100
) o
CROSS JOIN LATERAL (
    SELECT id, price 
    FROM products 
    ORDER BY random() 
    LIMIT 1
) p;

INSERT INTO order_items (order_id, product_id, quantity, unit_price, subtotal)
SELECT
    o.id,
    p.id,
    floor(random() * 3 + 1)::int AS qty,
    p.price,
    p.price * floor(random() * 3 + 1)::int
FROM (
    SELECT id 
    FROM orders 
    ORDER BY id DESC 
    LIMIT 100
) o
CROSS JOIN LATERAL (
    SELECT id, price 
    FROM products 
    ORDER BY random() 
    LIMIT 1
) p
WHERE random() < 0.6;

UPDATE orders o
SET total_amount = sub.total + o.shipping_fee
FROM (
    SELECT order_id, SUM(subtotal) as total
    FROM order_items
    GROUP BY order_id
) sub
WHERE o.id = sub.order_id
AND o.id IN (
    SELECT id FROM orders ORDER BY id DESC LIMIT 100
);



-- ============================================
-- 8. ANALYZE (cập nhật statistics cho query planner)
-- ============================================
ANALYZE cities;
ANALYZE customers;
ANALYZE categories;
ANALYZE products;
ANALYZE orders;
ANALYZE order_items;

-- ============================================
-- KIỂM TRA SỐ LƯỢNG
-- ============================================
SELECT 'cities' as tbl, count(*) from cities
UNION ALL SELECT 'customers', count(*) from customers
UNION ALL SELECT 'categories', count(*) from categories
UNION ALL SELECT 'products', count(*) from products
UNION ALL SELECT 'orders', count(*) from orders
UNION ALL SELECT 'order_items', count(*) from order_items;