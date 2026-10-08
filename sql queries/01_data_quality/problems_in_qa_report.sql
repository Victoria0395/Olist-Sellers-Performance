CREATE OR REPLACE VIEW `olist-e-commerce-pet-project.tests.problems_in_qa_report` AS 

select *
from(
SELECT 'customers' table_name, *
FROM `olist-e-commerce-pet-project.tests.customers_qa_report` 

union all 

SELECT 'order_items' table_name, *
FROM `olist-e-commerce-pet-project.tests.order_items_qa_report` 

union all 

SELECT 'orders' table_name, *
FROM `olist-e-commerce-pet-project.tests.orders_qa_report` 

union all 

SELECT 'order_payments' table_name, *
FROM `olist-e-commerce-pet-project.tests.order_payments_qa_report` 

union all 

SELECT 'order_reviews' table_name, *
FROM `olist-e-commerce-pet-project.tests.order_reviews_qa_report` 

union all 

SELECT 'products' table_name, *
FROM `olist-e-commerce-pet-project.tests.products_qa_report` 

union all 

SELECT 'sellers' table_name, *
FROM `olist-e-commerce-pet-project.tests.sellers_qa_report` 

union all 

SELECT 'referential_integrity' table_name, *
FROM `olist-e-commerce-pet-project.tests.referential_integrity_report` )tab
where status<>'pass'
order by 1