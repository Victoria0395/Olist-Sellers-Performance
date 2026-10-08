CREATE OR REPLACE VIEW `olist-e-commerce-pet-project.tests.order_items_qa_report` AS 

with raw as (
  select * 
  from `olist-e-commerce-pet-project.01_raw.order_items`
),

reference as (
  select *
  from `olist-e-commerce-pet-project.reference.valid_values`
),

problem_rows_count as (
select 
countif(order_id is null) order_id_is_null, 
countif(order_item_id is null) order_item_id_is_null, 
countif(product_id is null) product_id_is_null, 
countif(seller_id is null) seller_id_is_null, 
countif(shipping_limit_date is null) shipping_limit_date_is_null,
countif(price is null) price_is_null,
countif(freight_value is null) freight_value_is_null
FROM raw)


select 'order_id NULL check' check_name, 
case when order_id_is_null=0  then 'pass' else 'fail' end status, 
CAST(order_id_is_null AS STRING) problem_row_count
from problem_rows_count

union all

select 'order_item_id NULL check' check_name, 
case when order_item_id_is_null=0  then 'pass' else 'fail' end status, 
CAST(order_item_id_is_null AS STRING)
from problem_rows_count

union all

select 'product_id NULL check' check_name, 
case when product_id_is_null=0  then 'pass' else 'fail' end status, 
CAST(product_id_is_null AS STRING)
from problem_rows_count


union all

select 'seller_id NULL check' check_name, 
case when seller_id_is_null=0  then 'pass' else 'fail' end status, 
CAST(seller_id_is_null AS STRING)
from problem_rows_count

union all

select 'shipping_limit_date NULL check' check_name, 
case when shipping_limit_date_is_null=0  then 'pass' else 'fail' end status, 
CAST(shipping_limit_date_is_null AS STRING)
from problem_rows_count

union all

select 'price NULL check' check_name, 
case when price_is_null=0  then 'pass' else 'fail' end status, 
CAST(price_is_null AS STRING)
from problem_rows_count

union all

select 'freight_value NULL check' check_name, 
case when freight_value_is_null=0  then 'pass' else 'fail' end status, 
CAST(freight_value_is_null AS STRING)
from problem_rows_count

union all

select 'Dublicates check' check_name, 
case when  count(row_count) =0 
then 'pass' else 'fail' end status, 
CAST(count(row_count) AS STRING)
from (
select order_id, order_item_id, count(*) row_count
FROM raw 
group by order_id, order_item_id
having count(*)>1) accounts



