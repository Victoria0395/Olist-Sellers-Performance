CREATE OR REPLACE table `olist-e-commerce-pet-project.reference.valid_values` AS 

select 'state' column_name, customer_state as valid_value
from `olist-e-commerce-pet-project.01_raw.customers`
group by customer_state

union all

select 'payment_type' column_name, payment_type as valid_value
from `olist-e-commerce-pet-project.01_raw.order_payments`
group by payment_type

union all

select 'order_status' column_name, order_status as valid_value
from `olist-e-commerce-pet-project.01_raw.orders`
group by order_status
