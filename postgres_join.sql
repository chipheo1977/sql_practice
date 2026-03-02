-- PHẦN 1: JOIN
-- ============================================================

-- ────────────────────────────
-- 1.1: INNER JOIN
-- ────────────────────────────

-- Bài 1.1a: Liệt kê tên khách hàng + tên thành phố
-- Cột: customer_name, city_name, region
select c.name as customer_name, ci.name as city_name, ci.region  
from customers c 
inner join cities ci 
	on c.city_id = ci.id
	
-- Bài 1.1b: Liệt kê 10 đơn hàng gần nhất
-- kèm tên khách hàng, email, thành phố
-- Cột: order_id, customer_name, email, city, total_amount, created_at
select o.id as order_id, c.name as customer_name, c.email, ci.name, o.total_amount, o.created_at 
from orders o 
inner join customers c
	on o.customer_id = c.id
inner join cities ci
	on c.city_id = ci.id
order by o.created_at DESC
limit 10

-- Bài 1.1c: Liệt kê chi tiết đơn hàng #100
-- Cột: order_id, product_name, category_name, quantity, unit_price, subtotal
select o.id as order_id, p.name as product_name, ca.name as category_name, oi.quantity, oi.unit_price, oi.subtotal 
from orders o
inner join order_items oi
	on o.id = oi.order_id 
inner join products p
	on oi.product_id = p.id
inner join categories ca
	on p.category_id = ca.id
where o.id = 100

-- ────────────────────────────
-- 1.2: LEFT JOIN
-- ────────────────────────────

-- Bài 1.2a: Tìm sản phẩm CHƯA BAO GIỜ được đặt mua
-- Cột: product_id, product_name, price, status
select p.id as product_id, p."name" as product_name, oi.id 
from products p
left join order_items oi 
	on p.id = oi.product_id
where oi.id is null

-- Bài 1.2b: Liệt kê TẤT CẢ categories kèm số sản phẩm
-- (kể cả category chưa có sản phẩm nào → hiển thị 0)
-- Cột: category_name, product_count
select ca.name as category_name, count(p.id) as product_count
from categories ca
left join products p
	on ca.id = p.category_id
group by ca.name

-- Bài 1.2c: Tìm khách hàng đã đăng ký nhưng CHƯA BAO GIỜ đặt hàng
-- Cột: customer_id, name, email, membership, created_at
select o.id as order_id, c.id as customer_id, c."name", c.email, c.membership, o.created_at 
from customers c
left join orders o
	on o.customer_id = c.id
where o.id is null

-- ────────────────────────────
-- 1.3: RIGHT JOIN (ít dùng, nhưng phải biết)
-- ────────────────────────────

-- Bài 1.3: Viết lại bài 1.2b bằng RIGHT JOIN thay LEFT JOIN
-- Kết quả phải GIỐNG HỆT
select ca.name as category_name, count(p.id) as product_count
from products p
right join categories ca
	on ca.id = p.category_id
group by ca.name

-- ────────────────────────────
-- 1.4: SELF JOIN
-- ────────────────────────────

-- Bài 1.4: Liệt kê categories kèm tên parent category
-- Cột: child_id, child_name, parent_name
-- Hint: categories tự JOIN với chính nó qua parent_id
select c1.id as child_id, c1."name" as child_name, c2."name" as parent_name
from categories c1
join categories c2
	on c1.parent_id = c2.id

-- ────────────────────────────
-- 1.5: CROSS JOIN
-- ────────────────────────────

-- Bài 1.5: Tạo bảng "ma trận" tất cả membership × status
-- Mục đích: đếm có bao nhiêu order cho mỗi cặp (membership, order_status)
-- Cột: membership, order_status, order_count
-- Yêu cầu: nếu cặp nào = 0 order vẫn phải hiển thị (count = 0)
-- Hint: CROSS JOIN membership values × status values, rồi LEFT JOIN orders
SELECT 
    m.membership,
    s.status AS order_status,
    COUNT(o.id) AS order_count
FROM 
    (SELECT DISTINCT membership FROM customers) m
CROSS JOIN 
    (SELECT DISTINCT status FROM orders) s
LEFT JOIN customers c
    ON c.membership = m.membership
LEFT JOIN orders o
    ON o.customer_id = c.id
    AND o.status = s.status
GROUP BY 
    m.membership,
    s.status
ORDER BY 
    m.membership,
    s.status
limit 10


