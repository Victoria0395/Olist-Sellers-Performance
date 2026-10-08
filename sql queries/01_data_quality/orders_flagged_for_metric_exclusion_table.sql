create or replace table `olist-e-commerce-pet-project.exceptions.orders_flagged_for_metric_exclusion` as

select order_id, 'carrier_before_approved' as flag_reason
from `olist-e-commerce-pet-project.01_raw.orders`
where order_delivered_carrier_date < order_approved_at

union all

select order_id, 'customer_before_carrier'
from `olist-e-commerce-pet-project.01_raw.orders`
where order_delivered_customer_date < order_delivered_carrier_date