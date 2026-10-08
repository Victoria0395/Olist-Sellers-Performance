CREATE OR REPLACE VIEW `olist-e-commerce-pet-project.tests.order_reviews_qa_report` AS 

with raw as (
  select * from `olist-e-commerce-pet-project.01_raw.order_reviews`
),

problem_rows_count as (
select
  countif(review_id is null) review_id_is_null,
  countif(order_id is null) order_id_is_null,
  countif(review_score is null) review_score_is_null,
  countif(review_score < 1 or review_score > 5) review_score_out_of_range,
  countif(review_creation_date > review_answer_timestamp) answer_before_creation
from raw)

select 'review_id NULL check' check_name,
  case when review_id_is_null=0 then 'pass' else 'fail' end status,
  cast(review_id_is_null as string) problem_rows_count
from problem_rows_count

union all

select 'order_id NULL check' check_name,
  case when order_id_is_null=0 then 'pass' else 'fail' end status,
  cast(order_id_is_null as string)
from problem_rows_count

union all

select 'review_score NULL check' check_name,
  case when review_score_is_null=0 then 'pass' else 'fail' end status,
  cast(review_score_is_null as string)
from problem_rows_count

union all

select 'review_score out of 1-5 range check' check_name,
  case when review_score_out_of_range=0 then 'pass' else 'fail' end status,
  cast(review_score_out_of_range as string)
from problem_rows_count

union all

select 'review answer before creation date check' check_name,
  case when answer_before_creation=0 then 'pass' else 'fail' end status,
  cast(answer_before_creation as string)
from problem_rows_count

union all

select 'review_id duplicates check' check_name,
  case when count(row_count)=0 then 'pass' else 'fail' end status,
  cast(count(row_count) as string)
from (
  select review_id, count(*) row_count
  from raw
  group by review_id
  having count(*)>1
) dups

union all

select 'order_id duplicates check (multiple reviews per order)' check_name,
  'info' as status,
  cast(count(row_count) as string)
from (
  select order_id, count(*) row_count
  from raw
  group by order_id
  having count(*)>1
) dups

union all

select  'review before order' check_name,
  case when count(*)=0 then 'pass' else 'fail' end status,
  cast(count(*) as string)
from `olist-e-commerce-pet-project.01_raw.orders`orders
left join `olist-e-commerce-pet-project.01_raw.order_reviews`order_reviews
on order_reviews.order_id=orders.order_id
where review_answer_timestamp<datetime(order_purchase_timestamp)
