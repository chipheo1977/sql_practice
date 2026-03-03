-- ============================================================
-- PHẦN 3: ORDER BY + LIMIT
-- ============================================================

-- Bài 3.1: Top 5 khách hàng chi tiêu nhiều nhất
-- Cột: name, email, membership, total_spent
-- Sắp xếp: total_spent giảm dần
select c.name, c.email, c.membership, sum(o.total_amount)
from customers c
inner join orders o 
	on c.id = o.customer_id
group by c.name, c.email, c.membership 
order by sum(o.total_amount) desc
limit 5

-- Bài 3.2: Top 10 sản phẩm có giá cao nhất đang active
-- Cột: product_name, category_name, price, stock
select 
	p.name as product_name,
	c."name" as category_name,
	p.price,
	p.stock
from products p
inner join categories c 
	on p.category_id = c.id
where p.status = 'active'
limit 10

-- Bài 3.3: 5 đơn hàng gần nhất của customer_id = 100
-- Cột: order_id, status, total_amount, created_at
select 
	o.id as order_id,
	o.status,
	o.total_amount,
	o.created_at
from orders o
where o.customer_id = 100
order by o.created_at desc
limit 5

-- Bài 3.4: Phân trang - Lấy đơn hàng từ page 3 (mỗi page 20 đơn)
-- ORDER BY created_at DESC
-- So sánh 2 cách: OFFSET vs Keyset Pagination
select *
from orders o
order by o.created_at desc
limit 20 offset 40

select *
from orders
where created_at < '2026-03-01 10:30:00'
order by created_at desc
limit 20

-- Bài 3.5: ORDER BY với CASE (custom sort)
-- Sắp xếp orders theo status THEO THỨ TỰ TÙY CHỈNH:
-- pending → confirmed → shipped → delivered → cancelled
-- Hint: ORDER BY CASE status WHEN 'pending' THEN 1 ...
select 
from orders o 
order by 
	case o.status 
		when 'peding' then 1
		when 'confirmed' then 2
		when 'shipped' then 3
		when 'delivered' then 4
		when 'cancelled' then 5
	end




