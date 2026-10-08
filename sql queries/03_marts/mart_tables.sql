-- =====================================================
-- dim_customers
-- =====================================================
create or replace table `olist-e-commerce-pet-project.03_marts.dim_customers` as
select
  customer_id,
  customer_unique_id,
  customer_zip_code_prefix,
  customer_state
from `olist-e-commerce-pet-project.02_staging.stg_customers`;

-- =====================================================
-- dim_sellers
-- =====================================================
create or replace table `olist-e-commerce-pet-project.03_marts.dim_sellers` as
select
  seller_id,
  seller_zip_code_prefix,
  seller_state
from `olist-e-commerce-pet-project.02_staging.stg_sellers`;

-- =====================================================
-- dim_products
-- =====================================================
create or replace table `olist-e-commerce-pet-project.03_marts.dim_products` as
select
  p.product_id,
  p.product_category_name,
  t.product_category_name_english,
  p.category_was_missing,
  p.product_weight_g,
  p.weight_was_invalid,
  p.product_length_cm,
  p.product_height_cm,
  p.product_width_cm
from `olist-e-commerce-pet-project.02_staging.stg_products` p
left join `olist-e-commerce-pet-project.02_staging.stg_category_translation` t
  on t.product_category_name = p.product_category_name;

-- =====================================================
-- fct_order_items  (order-item grain, the base fact everything rolls up from)
-- =====================================================
create or replace table `olist-e-commerce-pet-project.03_marts.fct_order_items` as
select
  oi.order_id,
  oi.order_item_id,
  oi.product_id,
  oi.seller_id,
  o.customer_id,
  oi.price,
  oi.freight_value,
  o.order_status,
  o.order_purchase_timestamp,
  oi.shipping_limit_date,
  o.order_approved_at,
  o.order_delivered_carrier_date,
  o.order_delivered_customer_date,
  o.order_estimated_delivery_date,
  o.has_date_sequence_anomaly,
  (o.order_delivered_customer_date > o.order_estimated_delivery_date) as is_late_delivery
from `olist-e-commerce-pet-project.02_staging.stg_order_items` oi
join `olist-e-commerce-pet-project.02_staging.stg_orders` o on o.order_id = oi.order_id;

-- =====================================================
-- mart_seller_performance  (one row per seller — headline dashboard table)
-- =====================================================
create or replace table `olist-e-commerce-pet-project.03_marts.seller_performance` as
with 
order_seller_agg as (
  select
    seller_id,
    min(date(order_purchase_timestamp)) as first_order_date,
    max(date(order_purchase_timestamp)) as last_order_date,
    date_diff(max(date(order_purchase_timestamp)), min(date(order_purchase_timestamp)), day)+1 as tenure_days,
    count(distinct date(order_purchase_timestamp)) as days_with_order,
    count(distinct order_id) as total_orders,
    count(distinct case when order_status = 'delivered' then order_id end) as total_delivered_orders,
    round(sum(case when order_status = 'delivered' then price else 0 end),2) as GMV,
    round(sum(case when order_status = 'delivered' then freight_value else 0 end),2) as freight_revenue,
    countif(case when order_status = 'delivered' then is_late_delivery end) late_delivery,
    round(avg(case when not has_date_sequence_anomaly
    then timestamp_diff(order_delivered_carrier_date, order_approved_at, hour) end), 1) as avg_handling_hours
  from `olist-e-commerce-pet-project.03_marts.fct_order_items`
  group by seller_id
),

review_agg as (
  select
    oi.seller_id,
    count(distinct r.order_id) review_count_total,
    round(avg(review_score),1) avg_review_score_total
  from (
    select order_id, seller_id
    from `olist-e-commerce-pet-project.03_marts.fct_order_items`
    group by order_id, seller_id) oi
  join `olist-e-commerce-pet-project.02_staging.stg_order_reviews` r on r.order_id = oi.order_id
  where r.valid_review_attribution
  group by oi.seller_id
)


select ds.*, osa.* except (seller_id), ra.* except (seller_id),
case when row_number() over (order by GMV desc) <=100 then 'top 100'
when row_number() over (order by GMV desc) <=200 then 'top 200'
when row_number() over (order by GMV desc) <=300 then 'top 300'
when row_number() over (order by GMV desc) <=500 then 'top 500' else '500+' end rank_level
from `olist-e-commerce-pet-project.03_marts.dim_sellers` ds
left join  order_seller_agg osa on osa.seller_id = ds.seller_id
left join review_agg ra on ra.seller_id = ds.seller_id
;

-- =====================================================
-- mart_seller_monthly_trend  (one row per seller per category per month — for trajectory charts)
-- =====================================================
create or replace table `olist-e-commerce-pet-project.03_marts.seller_category_monthly_trend` as

with main as (
select
  seller_id,
  date_trunc(date(order_purchase_timestamp), month) order_month,
  product_category_name_english as category,
  count(distinct order_id) as month_orders,
  count(distinct case when order_status = 'delivered' then order_id end) as month_delivered_orders,
  round(sum(case when order_status = 'delivered' then price else 0 end), 2) as month_GMV,
  round(sum(case when order_status = 'delivered' then freight_value else 0 end), 2) as month_freight_revenue,
  from `olist-e-commerce-pet-project.03_marts.fct_order_items` fct_order_items
  left join `olist-e-commerce-pet-project.03_marts.dim_products`  dim_products
  on fct_order_items.product_id=dim_products.product_id
group by seller_id, date_trunc(date(order_purchase_timestamp), month), product_category_name_english),

cohorts as (
  select seller_id, order_month, case when min(main.order_month) over (partition by seller_id) = order_month then 'New'
when lag(main.order_month) over (partition by seller_id order by main.order_month) >= date_sub(main.order_month, interval 1 month) then 'Retention' else 'Reactivation' 
end cohort_status 
  from main
  group by seller_id, order_month
)

select main.*, cohort_status 
from main
left join cohorts on cohorts.seller_id=main.seller_id and cohorts.order_month = main.order_month
order by seller_id, order_month