create database pizzahut;
use pizzahut; 
-- Create TABLE
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    order_date DATE NOT NULL,
    order_time TIME NOT NULL
);
select * from order_details;

CREATE TABLE order_details (
    order_details_id INT PRIMARY KEY,
    order_id INT,
    pizza_id TEXT,
    quantity INT
);
CREATE TABLE pizza_types (
    pizza_type_id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    category TEXT NOT NULL,
    ingredients TEXT
);
CREATE TABLE pizzas (
    pizza_id TEXT PRIMARY KEY,
    pizza_type_id TEXT NOT NULL,
    size TEXT NOT NULL,
    price DOUBLE NOT NULL,
    FOREIGN KEY (pizza_type_id) REFERENCES pizza_types(pizza_type_id)
);

-- Data Analysis & Business Key Problems & Answers
-- My Analysis & Findings

-- Basic:
-- Q1.Retrieve the total number of orders placed.
-- Q2.Calculate the total revenue generated from pizza sales.
-- Q3.Identify the highest-priced pizza.
-- Q4.Identify the most common pizza size ordered.
-- Q5.List the top 5 most ordered pizza types along with their quantities.


-- Intermediate:
-- Q6.Join the necessary tables to find the total quantity of each pizza category ordered.
-- Q7.Determine the distribution of orders by hour of the day.
-- Q8.Join relevant tables to find the category-wise distribution of pizzas.
-- Q9.Group the orders by date and calculate the average number of pizzas ordered per day.
-- Q10.Determine the top 3 most ordered pizza types based on revenue.

-- Advanced:
-- Q11.Calculate the percentage contribution of each pizza type to total revenue.
-- Q12.Analyze the cumulative revenue generated over time.
-- Q13.Determine the top 3 most ordered pizza types based on revenue for each pizza category.



-- Q1.Retrieve the total number of orders placed.
select count(order_id) as total_orders
from orders;


-- Q2.Calculate the total revenue generated from pizza sales.
select 
round(sum(order_details.quantity * pizzas.price),2) as total_sales
from order_details join pizzas on order_details.pizza_id=pizzas.pizza_id;


-- Q3.Identify the highest-priced pizza.
select pizza_types.name,pizzas.price
from pizza_types join pizzas on pizza_types.pizza_type_id=pizzas.pizza_type_id
order by pizzas.price DESC limit 1 ;



-- Q4.Identify the most common pizza size ordered.
select pizzas.size, count(order_details.order_id) as order_count
from  pizzas join order_details on pizzas.pizza_id=order_details.pizza_id
group by pizzas.size
order by order_count DESC;

-- Q5.List the top 5 most ordered pizza types along with their quantities.
select pizza_types.name,sum(order_details.quantity) AS total_quantity
from pizza_types join pizzas
on pizza_types.pizza_type_id=pizzas.pizza_type_id
join order_details
on pizzas.pizza_id=order_details.pizza_id
group by pizza_types.name
order by total_quantity DESC limit 5;

-- Q6.Join the necessary tables to find the total quantity of each pizza category ordered.
select  pizza_types.category,sum(order_details.quantity) as total_quantity
from  pizza_types join 
pizzas on pizza_types.pizza_type_id=pizzas.pizza_type_id
join 
order_details on pizzas.pizza_id=order_details.pizza_id
group by pizza_types.category order by total_quantity DESC;

-- Q7.Determine the distribution of orders by hour of the day.
select hour(order_time), count(order_id) as no_of_orders
from orders
group by  hour(order_time) order by no_of_orders DESC;

-- Q8.Join relevant tables to find the category-wise distribution of pizzas.
SELECT category, COUNT(name) 
FROM pizza_types 
GROUP BY category;

-- Q9.Group the orders by date and calculate the average number of pizzas ordered per day.
select round(avg(quantity),0 )from(
select orders.order_date, sum(order_details.quantity) as quantity
from orders join order_details 
on 
orders.order_id=order_details.order_id
group by orders.order_date) as order_quantity;

-- Q10.Determine the top 3 most ordered pizza types based on revenue.
select pizza_types.name,sum(pizzas.price*order_details.quantity) as revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id=pizzas.pizza_type_id
join order_details 
on pizzas.pizza_id=order_details.pizza_id
group by pizza_types.name
order by revenue DESC limit 3;

-- Q11.Calculate the percentage contribution of each pizza type to total revenue.

select pizza_types.category,
(sum(pizzas.price*order_details.quantity)/ (select sum(order_details.quantity * pizzas.price) 
FROM order_details join pizzas on  order_details.pizza_id=pizzas.pizza_id)*100)
 as revenue_percentage
from pizza_types join pizzas
on pizza_types.pizza_type_id=pizzas.pizza_type_id
join order_details 
on pizzas.pizza_id=order_details.pizza_id
group by pizza_types.category 
order by revenue_percentage desc ;


-- Q.12Analyze the cumulative revenue generated over time.
SELECT 
    orders.order_date, 
    SUM(order_details.quantity * pizzas.price) AS daily_revenue,
    SUM(SUM(order_details.quantity * pizzas.price)) 
    OVER (ORDER BY orders.order_date) AS cumulative_revenue
FROM orders
JOIN order_details ON orders.order_id = order_details.order_id
JOIN pizzas ON order_details.pizza_id = pizzas.pizza_id
GROUP BY orders.order_date
ORDER BY orders.order_date;

-- Q13.Determine the top 3 most ordered pizza types based on revenue for each pizza category.
SELECT category, pizza_name, revenue
FROM (
    SELECT 
        pizza_types.category, 
        pizza_types.name AS pizza_name, 
        SUM(order_details.quantity * pizzas.price) AS revenue,
        RANK() OVER (PARTITION BY pizza_types.category ORDER BY SUM(order_details.quantity * pizzas.price) DESC) AS rn
    FROM pizza_types
    JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
    JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
    GROUP BY pizza_types.category, pizza_types.name
) ranked_pizzas
WHERE rn <= 3
ORDER BY category, rn;
-- End of project

