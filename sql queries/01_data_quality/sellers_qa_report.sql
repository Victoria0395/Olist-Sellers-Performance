CREATE OR REPLACE VIEW `olist-e-commerce-pet-project.tests.sellers_qa_report` AS 

with raw as (
  select * from `olist-e-commerce-pet-project.01_raw.sellers`
),

reference as (
  select * from `olist-e-commerce-pet-project.reference.valid_values`
),

problem_rows_count as (
select
  countif(seller_id is null) seller_id_is_null,
  countif(seller_zip_code_prefix is null) seller_zip_code_prefix_is_null,
  countif(seller_city is null) seller_city_is_null,
  countif(seller_state is null) seller_state_is_null
from raw)

select 'seller_id NULL check' check_name,
  case when seller_id_is_null=0 then 'pass' else 'fail' end status,
  cast(seller_id_is_null as string) problem_rows_count
from problem_rows_count

union all

select 'seller_zip_code_prefix NULL check' check_name,
  case when seller_zip_code_prefix_is_null=0 then 'pass' else 'fail' end status,
  cast(seller_zip_code_prefix_is_null as string)
from problem_rows_count

union all

select 'seller_city NULL check' check_name,
  case when seller_city_is_null=0 then 'pass' else 'fail' end status,
  cast(seller_city_is_null as string)
from problem_rows_count

union all

select 'seller_state NULL check' check_name,
  case when seller_state_is_null=0 then 'pass' else 'fail' end status,
  cast(seller_state_is_null as string)
from problem_rows_count

union all

select 'Duplicates check' check_name,
  case when count(row_count)=0 then 'pass' else 'fail' end status,
  cast(count(row_count) as string)
from (
  select seller_id, count(*) row_count
  from raw
  group by seller_id
  having count(*)>1
) dups

union all

select 'Valid seller_state check' check_name,
  case when count(*)=0 then 'pass' else 'fail' end status,
  cast(count(*) as string) problem_rows_count
from (
  select seller_state, count(*) rows_count
  from raw
  group by seller_state
) uniq
left join reference
  on column_name = 'state'
  and uniq.seller_state = reference.valid_value
where reference.valid_value is null and uniq.seller_state is not null