# join freight_value onto your per seller metrics and compare the average freight of the best and worst performing sellers(delivery time, delay rate, cancellation rate)

with seller_metrics as (
    select
        oi.seller_id,
        round(avg(oi.freight_value), 2) as avg_freight,
        round(
            avg(
                datediff(
                    o.order_delivered_customer_date,
                    o.order_purchase_timestamp
                )
            ), 2
        ) as avg_delivery_days,
        round(
            100.0 * count(
                distinct case
                    when o.order_delivered_customer_date >
                         o.order_estimated_delivery_date
                    then o.order_id
                end
            )
            /
            nullif(
                count(
                    distinct case
                        when o.order_delivered_customer_date is not null
                        then o.order_id
                    end
                ), 0
            ), 2
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
)
select *
from seller_metrics
where avg_delivery_days is not null 
and  delay_rate is not null
order by
    avg_delivery_days asc,
    delay_rate asc,
    cancellation_rate asc;
    
    
    
    with seller_metrics as (
    select
        oi.seller_id,
        round(avg(oi.freight_value), 2) as avg_freight,
        round(
            avg(
                datediff(
                    o.order_delivered_customer_date,
                    o.order_purchase_timestamp
                )
            ), 2
        ) as avg_delivery_days,
        round(
            100.0 * count(
                distinct case
                    when o.order_delivered_customer_date >
                         o.order_estimated_delivery_date
                    then o.order_id
                end
            )
            /
            nullif(
                count(
                    distinct case
                        when o.order_delivered_customer_date is not null
                        then o.order_id
                    end
                ), 0
            ), 2
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
    group by oi.seller_id),
ranked_sellers as (
    select
        *,
        row_number() over (
            order by
                avg_delivery_days asc,
                delay_rate asc,
                cancellation_rate asc
        ) as best_rank,
        row_number() over (
            order by
                avg_delivery_days desc,
                delay_rate desc,
                cancellation_rate desc
        ) as worst_rank
    from seller_metrics
    where avg_delivery_days is not null
      and delay_rate is not null
)
select
    'best 10' as seller_group,
    round(avg(avg_freight), 2) as average_freight
from ranked_sellers
where best_rank <= 10

union all

select
    'worst 10' as seller_group,
    round(avg(avg_freight), 2) as average_freight
from ranked_sellers
where worst_rank <= 10;


#Q4 write your conclusion to the bussiness question in 3-5 sentences . which sellers hurt fullfilment and 
#whether flight cost explains it_ citing the numbers from Q1_4

#from  the results I got from Q1–Q4, seller performance varies significantly in terms of order volume, revenue, delivery time, delay rate, and cancellation rate.
 #The weaker-performing sellers showed longer delivery times and higher delay rates, indicating that delivery performance is an important fulfillment issue.
 #The best-performing sellers had an average freight cost of 10.83, compared with 27.74 for the worst-performing sellers.
 #we can see that higher freight costs are associated with weaker fulfillment performance and may be one factor contributing to poor seller performance.


