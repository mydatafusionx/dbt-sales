{{
  config(
    materialized='view',
    unique_key='order_id'
  )
}}

with source as (
    select * from {{ source('raw', 'raw_orders') }}
),

customers as (
    select 
        customer_id,
        full_name as customer_name,
        segment as customer_segment,
        country_standardized as customer_country
    from {{ ref('stg_customers') }}
),

products as (
    select 
        product_id,
        product_name,
        category as product_category,
        subcategory as product_subcategory,
        is_premium_product
    from {{ ref('stg_products') }}
),

transformed as (
    select
        -- Chaves e identificadores
        o.order_id,
        o.customer_id,
        o.product_id,
        
        -- Datas
        o.order_date,
        date_trunc('month', o.order_date) as order_month,
        
        -- Dimensões do cliente
        c.customer_name,
        c.customer_segment,
        c.customer_country,
        
        -- Dimensões do produto
        p.product_name,
        p.product_category,
        p.product_subcategory,
        p.is_premium_product,
        
        -- Métricas de quantidade
        o.quantity,
        o.unit_price,
        o.total_amount,
        
        -- Cálculos
        o.quantity * o.unit_price as calculated_total,
        o.total_amount - (o.quantity * o.unit_price) as price_discrepancy,
        
        -- Flags de qualidade
        case
            when o.total_amount != (o.quantity * o.unit_price) then true
            else false
        end as needs_review,
        
        -- Classificações
        case
            when o.total_amount < 50 then 'Pequeno'
            when o.total_amount < 200 then 'Médio'
            else 'Grande'
        end as order_size_category
        
    from source o
    left join customers c on o.customer_id = c.customer_id
    left join products p on o.product_id = p.product_id
)

select * from transformed
