{{
  config(
    materialized='table'
  )
}}

with orders as (
    select * from {{ ref('stg_orders') }}
),

order_totals as (
    select
        order_id,
        customer_id,
        order_date,
        count(*) as items_count,
        sum(quantity) as total_quantity,
        sum(total_amount) as order_total,
        min(unit_price) as min_item_price,
        max(unit_price) as max_item_price
    from orders
    group by 1, 2, 3
)

select
    order_id,
    customer_id,
    order_date,
    items_count,
    total_quantity,
    order_total,
    min_item_price,
    max_item_price,
    -- Adicionando métricas adicionais
    case
        when items_count > 1 then true
        else false
    end as is_multi_item_order,
    -- Categorizando o valor do pedido
    case
        when order_total < 20 then 'Pequeno'
        when order_total < 50 then 'Médio'
        else 'Grande'
    end as order_size
from order_totals
