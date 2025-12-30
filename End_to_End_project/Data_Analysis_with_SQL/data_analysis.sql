--find top 10 highest reveue generating products 
select top 10 product_id,sum(sales_price) as sales
from df_orders
group by product_id
order by sales desc;

-- Find top 10 higest revenue generation products
select top 10
product_id, SUM(sales_price) as sales
from df_orders
group by product_id
order by sales desc;

--find top 5 higest selling products in each region
with cte as(
select product_id,region, sum(sales_price) as sales
from df_orders
group by region,product_id)
select * from(
select *,
ROW_NUMBER() over(partition by region order by sales desc) as rn
from cte) a
where rn <= 5;

-- find months over months growth comparion for 2022 and 2023 sales eg: jan 2022 vs jan 2023
with cte as (
Select Year(order_date) as order_year, MONTH(order_date) as order_month,
sum(sales_price) as sales 
from df_orders
group by Year(order_date),MONTH(order_date)
--order by Year(order_date),MONTH(order_date)
)
select order_month,
sum(case when order_year = 2022 then sales else 0 end) as sales_2022,
sum(case when order_year = 2023 then sales else 0 end) as sales_2023
from cte
group by order_month
order by order_month;

-- for each category which month had higest sales 
with cte as (
select category,FORMAT(order_date, 'yyyyMM') as order_year_month, 
SUM(sales_price) as sales
from df_orders
group by category,FORMAT(order_date, 'yyyyMM')
)
select * from (
select *,
ROW_NUMBER() over(partition by category order by sales desc) as rn
from cte) a
where rn = 1;

-- which sub category had highest growth by profit in 2023 compare to 2022

with cte as (
Select sub_category,Year(order_date) as order_year,
sum(sales_price) as sales 
from df_orders
group by sub_category,Year(order_date)
--order by Year(order_date),MONTH(order_date)
),
cte2 as(
select sub_category,
sum(case when order_year = 2022 then sales else 0 end) as sales_2022,
sum(case when order_year = 2023 then sales else 0 end) as sales_2023
from cte
group by sub_category
)
select top 1 *,
(sales_2023 - sales_2022)*100 / sales_2022 as growth
from cte2
order by (sales_2023 - sales_2022)*100 / sales_2022 desc