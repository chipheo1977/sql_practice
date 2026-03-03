-- ============================================================
-- PHẦN 2: GROUP BY + HAVING
-- ============================================================

-- ────────────────────────────
-- 2.1: GROUP BY cơ bản
-- ────────────────────────────

-- Bài 2.1a: Đếm số khách hàng theo membership
-- Cột: membership, customer_count
select c.membership, count(c.id) as customer_count
from customers c
group by c.membership

-- Bài 2.1b: Đếm số đơn hàng theo status
-- Cột: status, order_count, total_revenue
select o.status, count(o.id) as order_count, sum(o.total_amount) as total_revenue
from orders o 
group by o.status

-- Bài 2.1c: Doanh thu theo tháng trong năm 2025
-- Cột: month, total_orders, total_revenue
-- Chỉ tính đơn delivered
select 
	extract(month from o.created_at) as month, 
	count(o.id) as total_orders, 
	sum(o.total_amount) as total_revenue
from orders o
where o.created_at >= '2025-01-01 00:00:00' 
	and created_at < '2026-01-01 00:00:00'
group by extract(month from o.created_at)
order by month

-- Bài 2.1d: Thống kê sản phẩm theo category
-- Cột: category_name, product_count, avg_price, min_price, max_price
select 
	c.name as category_name,
	count(p.id) as product_count,
	AVG(p.price) AS avg_price,
    MIN(p.price) AS min_price,
    MAX(p.price) AS max_price
from categories c 
inner join products p 
	on c.id = p.category_id
group by c."name" 

-- ────────────────────────────
-- 2.2: GROUP BY + HAVING (lọc trên kết quả aggregate)
-- ────────────────────────────

-- Bài 2.2a: Tìm khách hàng có >= 30 đơn hàng
-- Cột: customer_id, name, order_count
select 
	c.name,
	count(o.id) as order_count
from customers c
inner join orders o
	on c.id = o.customer_id
group by c."name" 
having count(o.id) >= 30

-- Bài 2.2b: Tìm sản phẩm có tổng doanh thu > 1 tỷ
-- Cột: product_name, total_qty, total_revenue
select 
	p.name,
	sum(oi.quantity) as total_qty,
	sum(oi.quantity  * oi.unit_price ) as total_revenue
from products p 
inner join order_items oi 
	on p.id = oi.product_id 
group by p."name" 
having sum(oi.quantity  * oi.unit_price ) > 1000000

-- Bài 2.2c: Tìm thành phố có > 100,000 đơn hàng delivered
-- Cột: city_name, delivered_count, total_revenue
select 
	ci.name as city_name,
	count(o.id) as delivered_count,
	SUM(o.total_amount ) as total_revenue
from cities ci
inner join customers c 
	on ci.id = c.city_id 
inner join orders o 
	on c.id = o.customer_id 
where o.status = 'delivered'
group by ci.name
having count(o.id) > 100000

-- ────────────────────────────
-- 2.3: GROUP BY nhiều cột
-- ────────────────────────────

-- Bài 2.3a: Thống kê số đơn theo thành phố + membership
-- Cột: city, membership, order_count, avg_order_value
select 
	ci.name as city_name,
	c.membership,
	count(o.id) as order_count,
	AVG(o.total_amount ) as avg_order_value
from cities ci
inner join customers c 
	on ci.id = c.city_id 
inner join orders o 
	on c.id = o.customer_id
group by ci.name, c.membership

-- Bài 2.3b: Doanh thu theo category + tháng (pivot-style)
-- Cột: category_name, month, revenue
SELECT 
    c.name,
    SUM(CASE WHEN EXTRACT(MONTH FROM o.created_at) = 1 
        THEN oi.quantity * oi.unit_price ELSE 0 END) AS jan,
    SUM(CASE WHEN EXTRACT(MONTH FROM o.created_at) = 2 
        THEN oi.quantity * oi.unit_price ELSE 0 END) AS feb,
    SUM(CASE WHEN EXTRACT(MONTH FROM o.created_at) = 3 
        THEN oi.quantity * oi.unit_price ELSE 0 END) AS mar
FROM categories c
JOIN products p ON c.id = p.category_id
JOIN order_items oi ON p.id = oi.product_id
JOIN orders o ON oi.order_id = o.id
GROUP BY c.name;

























