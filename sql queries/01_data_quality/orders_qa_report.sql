CREATE OR REPLACE VIEW `olist-e-commerce-pet-project.tests.orders_qa_report` AS 

with raw as (
  select * from `olist-e-commerce-pet-project.01_raw.orders`
),

reference as (
  select * from `olist-e-commerce-pet-project.reference.valid_values`
),

problem_rows_count as (
select 
  countif(order_id is null) order_id_is_null,
  countif(customer_id is null) customer_id_is_null,
  countif(order_status is null) order_status_is_null,
  countif(order_purchase_timestamp is null) order_purchase_timestamp_is_null,
  countif(order_approved_at < order_purchase_timestamp) approved_before_purchase,
  countif(order_delivered_carrier_date < order_approved_at) carrier_before_approved,
  countif(order_delivered_customer_date < order_delivered_carrier_date) delivered_before_carrier,
  countif(order_delivered_customer_date < order_purchase_timestamp) delivered_before_purchase
from raw)

select 'order_id NULL check' check_name,
  case when order_id_is_null=0 then 'pass' else 'fail' end status,
  cast(order_id_is_null as string) problem_rows_count
from problem_rows_count

union all

select 'customer_id NULL check' check_name,
  case when customer_id_is_null=0 then 'pass' else 'fail' end status,
  cast(customer_id_is_null as string)
from problem_rows_count

union all

select 'order_status NULL check' check_name,
  case when order_status_is_null=0 then 'pass' else 'fail' end status,
  cast(order_status_is_null as string)
from problem_rows_count

union all

select 'order_purchase_timestamp NULL check' check_name,
  case when order_purchase_timestamp_is_null=0 then 'pass' else 'fail' end status,
  cast(order_purchase_timestamp_is_null as string)
from problem_rows_count

union all

select 'approved_at before purchase_timestamp check' check_name,
  case when approved_before_purchase=0 then 'pass' else 'fail' end status,
  cast(approved_before_purchase as string)
from problem_rows_count

union all

select 'delivered_carrier before approved_at check' check_name,
  case when carrier_before_approved=0 then 'pass' 
  when carrier_before_approved <= 1359 then 'pass — matches known baseline (investigated, flagged in stg_orders)'
    else 'fail — exceeds known baseline' end status,
  cast(carrier_before_approved as string)
from problem_rows_count

union all

select 'delivered_customer before delivered_carrier check' check_name,
  case when delivered_before_carrier=0 then 'pass' 
  when delivered_before_carrier <= 23 then 'pass — matches known baseline (investigated, flagged in stg_orders)'
    else 'fail — exceeds known baseline' end status,
  cast(delivered_before_carrier as string)
from problem_rows_count

union all

select 'delivered_customer before purchase_timestamp check' check_name,
  case when delivered_before_purchase=0 then 'pass' else 'fail' end status,
  cast(delivered_before_purchase as string)
from problem_rows_count

union all

select 'Duplicates check' check_name,
  case when count(row_count)=0 then 'pass' else 'fail' end status,
  cast(count(row_count) as string)
from (
  select order_id, count(*) row_count
  from raw
  group by order_id
  having count(*)>1
) dups

union all

select 'Valid order_status check' check_name,
  case when count(*)=0 then 'pass' else 'fail' end status,
  cast(count(*) as string) problem_rows_count
from (
  select order_status, count(*) rows_count
  from raw
  group by order_status
) uniq
left join reference
  on column_name = 'order_status'
  and uniq.order_status = reference.valid_value
where reference.valid_value is null and uniq.order_status is not null

