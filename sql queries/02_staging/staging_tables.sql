-- =====================================================
-- stg_customers
-- =====================================================
create or replace table `olist-e-commerce-pet-project.02_staging.stg_customers` as
select
  customer_id,           -- order-scoped, joins 1:1 to orders
  customer_unique_id,    -- person-scoped, use for repeat-purchase/LTV logic
  customer_zip_code_prefix,
  customer_city,
  customer_state
from `olist-e-commerce-pet-project.01_raw.customers`;

-- =====================================================
-- stg_orders
-- =====================================================
create or replace table `olist-e-commerce-pet-project.02_staging.stg_orders` as
select
  order_id,
  customer_id,
  order_status,
  order_purchase_timestamp,
  order_approved_at,
  order_delivered_carrier_date,
  order_delivered_customer_date,
  order_estimated_delivery_date,
  (order_delivered_carrier_date < order_approved_at) as carrier_before_approved,
  (order_delivered_customer_date < order_delivered_carrier_date) as customer_before_carrier,
  (order_delivered_carrier_date < order_approved_at)
    or (order_delivered_customer_date < order_delivered_carrier_date) as has_date_sequence_anomaly
from `olist-e-commerce-pet-project.01_raw.orders`;

-- =====================================================
-- stg_order_items
-- =====================================================
create or replace table `olist-e-commerce-pet-project.02_staging.stg_order_items` as
select
  order_id,
  order_item_id,
  product_id,
  seller_id,
  shipping_limit_date,
  price,
  freight_value
from `olist-e-commerce-pet-project.01_raw.order_items`;

-- =====================================================
-- stg_order_payments
-- =====================================================
create or replace table `olist-e-commerce-pet-project.02_staging.stg_order_payments` as
select
  order_id,
  payment_sequential,
  payment_type,
  nullif(payment_installments, 0) as payment_installments,  -- 0 is invalid, confirmed data entry error
  payment_value
from `olist-e-commerce-pet-project.01_raw.order_payments`;

-- =====================================================
-- stg_order_reviews
-- =====================================================
create or replace table `olist-e-commerce-pet-project.02_staging.stg_order_reviews` as
with ranked as (
  select
    *,
    count(distinct seller_id) over (partition by order_id) as distinct_sellers_in_order
  from `olist-e-commerce-pet-project.01_raw.order_reviews` r
  left join (
    select order_id, seller_id
    from `olist-e-commerce-pet-project.01_raw.order_items`
    group by order_id, seller_id
  ) oi using (order_id)
),
latest_per_order as (
  select *,
    row_number() over (partition by order_id order by review_creation_date desc, review_answer_timestamp desc) as rn
  from ranked
)
select
  to_hex(md5(concat(review_id, '_', order_id))) as review_key,
  review_id,
  order_id,
  review_score,
  review_comment_title,
  review_comment_message,
  review_creation_date,
  review_answer_timestamp,
  (distinct_sellers_in_order = 1) as valid_review_attribution
from latest_per_order
where rn = 1;

-- =====================================================
-- stg_products
-- =====================================================
create or replace table `olist-e-commerce-pet-project.02_staging.stg_products` as
select
  product_id,
  coalesce(product_category_name, 'uncategorized') as product_category_name,
  product_category_name is null as category_was_missing,
  product_photos_qty,
  case when product_weight_g <= 0 then null else product_weight_g end as product_weight_g,
  coalesce(product_weight_g, 0) <= 0 as weight_was_invalid,
  product_length_cm,
  product_height_cm,
  product_width_cm
from `olist-e-commerce-pet-project.01_raw.products`;

-- =====================================================
-- stg_sellers
-- =====================================================
create or replace table `olist-e-commerce-pet-project.02_staging.stg_sellers` as
select
  seller_id,
  seller_zip_code_prefix,
  seller_city,
  seller_state
from `olist-e-commerce-pet-project.01_raw.sellers`;


-- =====================================================
-- stg_category_translation
-- =====================================================
create or replace table `olist-e-commerce-pet-project.02_staging.stg_category_translation` as
select product_category_name, product_category_name_english
from `olist-e-commerce-pet-project.01_raw.product_category_name_translation`

union all

select 'uncategorized', 'Uncategorized'  -- so the fallback resolves cleanly downstream

union all
select 'portateis_cozinha_e_preparadores_de_alimentos', 'small_kitchen_appliances_food_prep' -- missing translation

union all
select 'pc_gamer', 'gaming_pc'  -- missing translation
;