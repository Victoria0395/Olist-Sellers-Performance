CREATE OR REPLACE VIEW `olist-e-commerce-pet-project.tests.customers_qa_report` AS 

with raw as (
  select * 
  from `olist-e-commerce-pet-project.01_raw.customers`
),

reference as (
  select *
  from `olist-e-commerce-pet-project.reference.valid_values`
),

problem_rows_count as (
select 
countif(customer_id is null) customer_id_is_null, 
countif(customer_unique_id is null) customer_unique_id_is_null, 
countif(customer_zip_code_prefix is null) customer_zip_code_prefix_is_null, 
countif(customer_city is null) customer_city_is_null, 
countif(customer_state is null) customer_state_is_null
FROM raw)


select 'customer_id NULL check' check_name, 
case when customer_id_is_null=0  then 'pass' else 'fail' end status, 
CAST(customer_id_is_null AS STRING) problem_row_count
from problem_rows_count

union all

select 'customer_unique_id NULL check' check_name, 
case when customer_unique_id_is_null=0  then 'pass' else 'fail' end status, 
CAST(customer_unique_id_is_null AS STRING)
from problem_rows_count

union all

select 'customer_zip_code_prefix NULL check' check_name, 
case when customer_zip_code_prefix_is_null=0  then 'pass' else 'fail' end status, 
CAST(customer_zip_code_prefix_is_null AS STRING)
from problem_rows_count


union all

select 'customer_city NULL check' check_name, 
case when 
customer_city_is_null=0  then 'pass' else 'fail' end status, 
CAST(customer_city_is_null AS STRING)
from problem_rows_count

union all

select 'customer_state NULL check' check_name, 
case when customer_state_is_null=0  then 'pass' else 'fail' end status, 
CAST(customer_state_is_null AS STRING)
from problem_rows_count

union all

select 'Dublicates check' check_name, 
case when  count(row_count) =0 
then 'pass' else 'fail' end status, 
CAST(count(row_count) AS STRING)
from (
select customer_id, count(*) row_count
FROM raw 
group by customer_id
having count(*)>1) accounts

union all

select 'Valid customer_state check' check_name, 
case when count(*)=0
then 'pass' else 'fail' end status,
CAST(count(*) AS STRING)  problem_rows_count 
from (
select customer_state, count(*) rows_count
FROM raw
group by customer_state) uniq
left join reference
on column_name = 'state' 
and uniq.customer_state = reference.valid_value
where reference.valid_value is null and uniq.customer_state is not null






