create or replace table `olist-e-commerce-pet-project.exceptions.investigated_anomalies` as

select p.order_id, 'active_order_without_items' as rejection_reason, cast(null as string) as detail
from `olist-e-commerce-pet-project.01_raw.orders` p
left join `olist-e-commerce-pet-project.01_raw.order_items` c on c.order_id = p.order_id
where c.order_id is null and order_status in ('shipped', 'delivered')

union all

select p.order_id, 'delivered_order_without_payment_info', cast(null as string)
from `olist-e-commerce-pet-project.01_raw.orders` p
left join `olist-e-commerce-pet-project.01_raw.order_payments` c on c.order_id = p.order_id
where c.order_id is null

union all

select order_id, 'invalid_installments_zero', cast(null as string)
from `olist-e-commerce-pet-project.01_raw.order_payments`
where payment_installments = 0

union all

select 
c.order_id, 
'unexplained_payment_mismatch', 
concat('value gap: ', cast(round(p.order_value - c.order_value, 2) as string))
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
  and max_payment_installments <= 1
  and payment_type_voucher = 0


