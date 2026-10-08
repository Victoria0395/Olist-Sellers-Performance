create or replace view `olist-e-commerce-pet-project.tests.referential_integrity_report` as

select 'order_items -> orders' check_name,
  case when count(*) = 0 then 'pass' else 'fail' end status,
  count(*) problem_rows_count
from `olist-e-commerce-pet-project.01_raw.order_items` c
left join `olist-e-commerce-pet-project.01_raw.orders` p on c.order_id = p.order_id
where p.order_id is null

union all

select 'orders -> order_items (childless)' check_name,
  case when count(*) = 0 then 'pass' else 'fail' end status,
  count(*) problem_rows_count
from `olist-e-commerce-pet-project.01_raw.orders` p
left join `olist-e-commerce-pet-project.01_raw.order_items` c on c.order_id = p.order_id
where c.order_id is null

union all

select 'customers -> orders' check_name,
  case when count(*) = 0 then 'pass' else 'fail' end status,
  count(*) problem_rows_count
from `olist-e-commerce-pet-project.01_raw.customers` c
left join `olist-e-commerce-pet-project.01_raw.orders` p on c.customer_id = p.customer_id
where p.customer_id is null

union all

select 'orders -> customers (childless)' check_name,
  case when count(*) = 0 then 'pass' else 'fail' end status,
  count(*) problem_rows_count
from `olist-e-commerce-pet-project.01_raw.orders` p
left join `olist-e-commerce-pet-project.01_raw.customers` c on c.customer_id = p.customer_id
where c.customer_id is null

union all

select 'order_items -> sellers' check_name,
  case when count(*) = 0 then 'pass' else 'fail' end status,
  count(*) problem_rows_count
from `olist-e-commerce-pet-project.01_raw.sellers` c
left join `olist-e-commerce-pet-project.01_raw.order_items` p on c.seller_id = p.seller_id
where p.seller_id is null

union all

select 'order_items -> sellers (childless)' check_name,
  case when count(*) = 0 then 'pass' else 'fail' end status,
  count(*) problem_rows_count
from `olist-e-commerce-pet-project.01_raw.order_items` p
left join `olist-e-commerce-pet-project.01_raw.sellers` c on c.seller_id = p.seller_id
where c.seller_id is null

union all

select 'order_payments -> orders' check_name,
  case when count(*) = 0 then 'pass' else 'fail' end status,
  count(*) problem_rows_count
from `olist-e-commerce-pet-project.01_raw.order_payments` c
left join `olist-e-commerce-pet-project.01_raw.orders` p on c.order_id = p.order_id
where p.order_id is null

union all

select 'orders -> order_payments (childless)' check_name,
  case when count(*) = 0 then 'pass' else 'fail' end status,
  count(*) problem_rows_count
from `olist-e-commerce-pet-project.01_raw.orders` p
left join `olist-e-commerce-pet-project.01_raw.order_payments` c on c.order_id = p.order_id
where c.order_id is null

union all

select 'order_reviews -> orders' check_name,
  case when count(*) = 0 then 'pass' else 'fail' end status,
  count(*) problem_rows_count
from `olist-e-commerce-pet-project.01_raw.order_reviews` c
left join `olist-e-commerce-pet-project.01_raw.orders` p on c.order_id = p.order_id
where p.order_id is null

union all

select 'order_items -> products' check_name,
  case when count(*) = 0 then 'pass' else 'fail' end status,
  count(*) problem_rows_count
from `olist-e-commerce-pet-project.01_raw.products` c
left join `olist-e-commerce-pet-project.01_raw.order_items` p on c.product_id = p.product_id
where p.product_id is null

union all

select 'order_items -> products (childless)' check_name,
  case when count(*) = 0 then 'pass' else 'fail' end status,
  count(*) problem_rows_count
from `olist-e-commerce-pet-project.01_raw.order_items` p
left join `olist-e-commerce-pet-project.01_raw.products` c on c.product_id = p.product_id
where c.product_id is null

union all

select 'products -> category translation' check_name,
  case when count(*) = 0 then 'pass' else 'fail' end status,
  count(*) problem_rows_count
from `olist-e-commerce-pet-project.01_raw.product_category_name_translation` c
left join `olist-e-commerce-pet-project.01_raw.products` p on c.product_category_name = p.product_category_name
where p.product_category_name is null

union all

select 'products -> category translation (childless)' check_name,
  case when count(*) = 0 then 'pass' else 'fail' end status,
  count(*) problem_rows_count
from `olist-e-commerce-pet-project.01_raw.products` p
left join `olist-e-commerce-pet-project.01_raw.product_category_name_translation` c on c.product_category_name = p.product_category_name
where c.product_category_name is null

union all

select 'unexplained order_items/payment mismatch check' check_name,
  case 
    when count(*) = 0 then 'pass'
    when count(*) <= 13 then 'pass — matches known baseline (investigated, documented)'
    else 'fail — exceeds known baseline, new cases require investigation'
  end status,
  count(*) as problem_rows_count
from (
  select c.order_id
  from (
    select order_id, round(coalesce(sum(price),0) + coalesce(sum(freight_value),0), 2) order_value
    from `olist-e-commerce-pet-project.01_raw.order_items` group by order_id
  ) c
  join (
    select order_id, round(coalesce(sum(payment_value),0), 2) order_value,
      max(payment_installments) max_payment_installments,
      countif(payment_type = 'voucher') payment_type_voucher
    from `olist-e-commerce-pet-project.01_raw.order_payments` group by order_id
  ) p on c.order_id = p.order_id
  where abs(c.order_value - p.order_value) > 0.05
    and not (max_payment_installments > 1)
    and payment_type_voucher = 0)







