CREATE OR REPLACE VIEW `olist-e-commerce-pet-project.tests.order_payments_qa_report` AS 

with raw as (
  select * from `olist-e-commerce-pet-project.01_raw.order_payments`
),

reference as (
  select * from `olist-e-commerce-pet-project.reference.valid_values`
),

problem_rows_count as (
select
  countif(order_id is null) order_id_is_null,
  countif(payment_sequential is null) payment_sequential_is_null,
  countif(payment_type is null) payment_type_is_null,
  countif(payment_installments is null) payment_installments_is_null,
  countif(payment_installments < 1) payment_installments_less_1,
  countif(payment_value is null) payment_value_is_null,
  countif(payment_value < 0) payment_value_less_0
from raw)

select 'order_id NULL check' check_name,
  case when order_id_is_null=0 then 'pass' else 'fail' end status,
  cast(order_id_is_null as string) problem_rows_count
from problem_rows_count

union all

select 'payment_sequential NULL check' check_name,
  case when payment_sequential_is_null=0 then 'pass' else 'fail' end status,
  cast(payment_sequential_is_null as string)
from problem_rows_count

union all

select 'payment_type NULL check' check_name,
  case when payment_type_is_null=0 then 'pass' else 'fail' end status,
  cast(payment_type_is_null as string)
from problem_rows_count

union all

select 'payment_installments NULL check' check_name,
  case when payment_installments_is_null=0 then 'pass' else 'fail' end status,
  cast(payment_installments_is_null as string)
from problem_rows_count

union all

select 'payment_installments less than 1 check' check_name,
  case when payment_installments_less_1=0 then 'pass'
  when payment_installments_less_1<=2 then 'pass — matches known baseline (investigated, marked as anomalies)'
    else 'fail — exceeds known baseline' end status,
  cast(payment_installments_less_1 as string)
from problem_rows_count

union all

select 'payment_value NULL check' check_name,
  case when payment_value_is_null=0 then 'pass' else 'fail' end status,
  cast(payment_value_is_null as string)
from problem_rows_count

union all

select 'payment_value less than 0 check' check_name,
  case when payment_value_less_0=0 then 'pass' else 'fail' end status,
  cast(payment_value_less_0 as string)
from problem_rows_count

union all

select 'Duplicates check' check_name,
  case when count(row_count)=0 then 'pass' else 'fail' end status,
  cast(count(row_count) as string)
from (
  select order_id, payment_sequential, count(*) row_count
  from raw
  group by order_id, payment_sequential
  having count(*)>1
) dups

union all

select 'Valid payment_type check' check_name,
  case when count(*)=0 then 'pass' else 'fail' end status,
  cast(count(*) as string) problem_rows_count
from (
  select payment_type, count(*) rows_count
  from raw
  group by payment_type
) uniq
left join reference
  on column_name = 'payment_type'
  and uniq.payment_type = reference.valid_value
where reference.valid_value is null and uniq.payment_type is not null