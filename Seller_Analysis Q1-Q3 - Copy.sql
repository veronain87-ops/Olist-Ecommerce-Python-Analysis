create database olist;

use olist;
RENAME TABLE customers_202503150948 TO customers;
RENAME TABLE order_items_202503150951 TO order_items;
RENAME TABLE order_payments_202503150951 TO order_payments;
RENAME TABLE orders_202503150951 TO orders;

#clean data and null delivery date

select count(*) as null_delivery_dates
from orders
where order_delivered_customer_date is null;

select count(*) as blank_delivery_dates
from orders
where order_delivered_customer_date = '';


update orders
set order_delivered_customer_date = null
where order_delivered_customer_date = '';


select count(*) as null_delivery_dates
from orders
where order_delivered_customer_date is null;


select
    order_id,
    count(*) as duplicate_count
from orders
group by order_id
having count(*) > 1;




# Q1 — Rank sellers by order volume and revenue,pull out the top10 and bottom 10
#ordered by Revenue top 10 and bottom
select
    seller_id,
    COUNT(DISTINCT order_id) AS order_volume,
    ROUND(SUM(price), 2) AS revenue
from order_items
group by seller_id
order by revenue desc
limit 10
;

select
    seller_id,
    COUNT(DISTINCT order_id) AS order_volume,
    ROUND(SUM(price), 2) AS revenue
from order_items
group by seller_id
order by revenue asc
limit 10
;

#ordered by volume top 10 and bottom

select
    seller_id,
    count(distinct order_id) as order_volume,
    round(sum(price), 2) as revenue
from order_items
group by seller_id
order by order_volume desc
limit 10;

select
    seller_id,
    count(distinct order_id) as order_volume,
    round(sum(price), 2) as revenue
from order_items
group by seller_id
order by order_volume asc
limit 10;

# Q2 compute the average delivery time per seller, in days(delivered date - purchase date)

select
    oi.seller_id,
    ROUND(
        avg(
            DATEDIFF(
                o.order_delivered_customer_date,
                o.order_purchase_timestamp
            )
        ), 2
    ) as avg_delivery_days
from orders as o
inner join order_items as oi
    on o.order_id = oi.order_id
where o.order_delivered_customer_date is not null
group by oi.seller_id
order by avg_delivery_days asc
;


#Q3 compute each seller's delay rate (delivered after the estimated date) and cancellation rate.


select
    oi.seller_id,
round(
        100.0 * count(
            distinct case
                when o.order_delivered_customer_date >
                     o.order_estimated_delivery_date
                then o.order_id
            end
        )
        /
        count(
            distinct case
                when o.order_delivered_customer_date is not null
                then o.order_id
            end
        ),
        2
    ) as delay_rate,
    round(
        100.0 * count(
            distinct case
                when o.order_status = 'canceled'
                then o.order_id
            end
        )
        / count(distinct o.order_id),
        2
    ) as cancellation_rate
from orders as o
inner join order_items as oi
    on o.order_id = oi.order_id
group by oi.seller_id
order by delay_rate desc;

select
    order_status,
    count(*) as total_orders
from orders
group by order_status;



 
 











