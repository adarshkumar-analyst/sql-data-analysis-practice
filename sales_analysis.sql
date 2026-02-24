
-- Show total sales for each city.
select city,
     round(sum(sales_amount),2)
from sales
     group by city;

-- Find the average sales amount for each product category.
select product_category,
        round(avg(sales_amount),2)
from sales
group by product_category;

-- Display the top 5 highest sales orders.
SELECT *
FROM sales
ORDER BY sales_amount DESC
LIMIT 5;


-- Calculate the percentage of orders paid by Cash.
select
     sum(case when payment_method='Cash' then 1 else 0 end )
     as total_cash,
     100 * sum(case when payment_method='Cash' then 1 else 0 end )/count(payment_method) 
     as cash_percentage
from sales;     

-- Show the total quantity purchased by each customer.
select customer_id,
       sum(quantity) total_quantity
from sales
group by customer_id;

-- Find customers whose total sales are greater than the overall average sales.
select *
 from sales
 where sales_amount>(
                      select avg(sales_amount)
                      from sales
				      );
                      

-- Label each order using CASE:
-- Low < 500 ,Medium 500–1500 ,High > 1500
select *,
case
      when sales_amount < 500 then 'Low'
      when sales_amount between 500 and 1500 then 'Medium'
      else 'High'
      end as Sales_amt_label
 from sales;     
      
-- Show the latest order for each customer.
select * 
 from sales s
 where order_date =(
                      select  max(order_date)
                      from sales
                      where customer_id=s.customer_id
                      group by customer_id
                      );
                      									
-- Find cities where average sales are higher than the overall average.
select city,avg(sales_amount)
from sales s
group by city
having avg(sales_amount) >(
                     select avg(sales_amount)
                     from sales
                     );

-- Find customers who purchased both Electronics and Clothing.
select distinct e.customer_id,e.customer_name
from sales s
join sales e
on e.customer_id=s.customer_id
where e.product_category ='Electronics' and 
      s.product_category ='Clothing';

-- Find the top 3 highest sales orders in each city.
with cte as (
select *,
rank() over(partition by city order by sales_amount) as rnk
from sales)
select *
from cte
where rnk<=3;

-- Calculate the running total of sales by order date.
select *,
         round(
         sum(sales_amount) over(order by order_date),2)
         as running_total
from sales;

-- Rank customers based on their total sales.
with cte as (
select customer_id,round(sum(sales_amount),2) as total_sales
from sales
group by customer_id
order by total_sales desc)
select *,
rank() over(order by total_sales desc ) as rnk
from cte;

-- Show the difference in sales from the previous order.
with cte as(
             select *,
                 lag(sales_amount) over(order by order_date ) as pre_order
			from sales)
select *,
round( sales_amount - pre_order,2) as sales_diff
from cte;

-- Find the highest price product in each category
with cte as (
select product_category,price,
rank() over(partition by product_category order by price desc) as rnk
from sales)
select *
 from cte
 where rnk=1;

-- Calculate month-wise sales growth percentage
with cte as(
select 
       date_format(order_date,'%y-%m') as _month,
       round(sum(sales_amount),2) as total_sales
       from sales
       group by date_format(order_date,'%y-%m')
       )
 
select _month,
	  total_sales,
      lag(total_sales) over(order by _month ) as pre_months,
      round(
      (total_sales -lag(total_sales) over(order by _month ))/
      lag(total_sales) over(order by _month ) * 100,2)
      as growth_per
 from cte;     

-- Detect duplicate customers (same name with multiple IDs).
select customer_name,count(distinct customer_id) as uniue_ids
from sales
group by customer_name
having count(distinct customer_id)>1;

-- Find the best-selling category in each city.
with cte as (
select 
      city,
      product_category,
      sum(sales_amount) as total_sales
      from sales
      group by city,product_category
      ),
 rank_data as (
 select *,
        rank() over(partition by city order by total_sales) as rnk
        from cte 
        )
select city,
	   product_category,
	   total_sales
 from rank_data
 where rnk=1
 order by total_sales;

-- Find customers whose three consecutive orders show increasing sales.

WITH ordered_sales AS (
    SELECT
        customer_id,
        customer_name,
        order_date,
        sales_amount,
        LAG(sales_amount, 1) OVER (PARTITION BY customer_id ORDER BY order_date) AS prev1,
        LAG(sales_amount, 2) OVER (PARTITION BY customer_id ORDER BY order_date) AS prev2
    FROM sales
)

SELECT DISTINCT
    customer_id,
    customer_name
FROM ordered_sales
WHERE sales_amount > prev1
  AND prev1 > prev2;
       






