{{
  config(
    materialized='table',
    unique_key='customer_id'
  )
}}

with customer_orders as (
    select
        customer_id,
        min(order_date) as first_order_date,
        max(order_date) as most_recent_order_date,
        count(order_id) as number_of_orders,
        sum(total_amount) as lifetime_value
    from {{ ref('stg_orders') }}
    group by 1
)

select
    customer_id,
    first_order_date,
    most_recent_order_date,
    coalesce(number_of_orders, 0) as number_of_orders,
    coalesce(lifetime_value, 0) as lifetime_value,
    -- Adicionando métricas adicionais
    (current_date - first_order_date) as days_as_customer,
    case
        when number_of_orders > 0 then lifetime_value / number_of_orders
        else 0
    end as avg_order_value
from customer_orders
