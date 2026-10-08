CREATE OR REPLACE VIEW `olist-e-commerce-pet-project.tests.products_qa_report` AS 

with raw as (
  select * from `olist-e-commerce-pet-project.01_raw.products`
),

problem_rows_count as (
select
  countif(product_id is null) product_id_is_null,
  countif(product_category_name is null) product_category_name_is_null,
  countif(product_weight_g is null or product_weight_g <= 0) weight_invalid,
  countif(product_length_cm is null or product_length_cm <= 0) length_invalid,
  countif(product_height_cm is null or product_height_cm <= 0) height_invalid,
  countif(product_width_cm is null or product_width_cm <= 0) width_invalid,
  countif(product_photos_qty is null) photos_qty_is_null
from raw)

select 'product_id NULL check' check_name,
  case when product_id_is_null=0 then 'pass' else 'fail' end status,
  cast(product_id_is_null as string) problem_rows_count
from problem_rows_count

union all

select 'product_category_name NULL check' check_name,
  case when product_category_name_is_null=0 then 'pass' else 'fail' end status,
  cast(product_category_name_is_null as string)
from problem_rows_count

union all

select 'weight missing or non-positive check' check_name,
  case when weight_invalid=0 then 'pass' else 'fail' end status,
  cast(weight_invalid as string)
from problem_rows_count

union all

select 'length missing or non-positive check' check_name,
  case when length_invalid=0 then 'pass' else 'fail' end status,
  cast(length_invalid as string)
from problem_rows_count

union all

select 'height missing or non-positive check' check_name,
  case when height_invalid=0 then 'pass' else 'fail' end status,
  cast(height_invalid as string)
from problem_rows_count

union all

select 'width missing or non-positive check' check_name,
  case when width_invalid=0 then 'pass' else 'fail' end status,
  cast(width_invalid as string)
from problem_rows_count

union all

select 'product_photos_qty NULL check' check_name,
  case when photos_qty_is_null=0 then 'pass' else 'fail' end status,
  cast(photos_qty_is_null as string)
from problem_rows_count

union all

select 'Duplicates check' check_name,
  case when count(row_count)=0 then 'pass' else 'fail' end status,
  cast(count(row_count) as string)
from (
  select product_id, count(*) row_count
  from raw
  group by product_id
  having count(*)>1
) dups