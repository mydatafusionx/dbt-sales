{{
  config(
    materialized='table',
    unique_key='product_id'
  )
}}

with product_sales as (
    select
        product_id,
        count(distinct order_id) as number_of_orders,
        sum(quantity) as total_quantity_sold,
        sum(total_amount) as total_revenue,
        avg(unit_price) as average_price,
        min(order_date) as first_sale_date,
        max(order_date) as last_sale_date
    from {{ ref('stg_orders') }}
    group by 1
)

select
    product_id,
    number_of_orders,
    total_quantity_sold,
    total_revenue,
    average_price,
    first_sale_date,
    last_sale_date,
    -- Adicionando métricas calculadas
    case
        when total_quantity_sold > 0 then total_revenue / total_quantity_sold
        else 0
    end as average_revenue_per_unit,
    -- Categorização de produtos
    case
        when total_quantity_sold = 0 then 'Sem vendas'
        when total_quantity_sold < 3 then 'Baixa demanda'
        when total_quantity_sold < 10 then 'Média demanda'
        else 'Alta demanda'
    end as demand_category
from product_sales
