{{
  config(
    materialized='view',
    unique_key='product_id'
  )
}}

with source as (
    select * from {{ source('raw', 'raw_products') }}
),

transformed as (
    select
        product_id,
        product_name,
        category,
        subcategory,
        unit_cost,
        unit_price,
        created_at,
        -- Calculando a margem de lucro
        (unit_price - unit_cost) as profit_margin,
        round(((unit_price - unit_cost) / nullif(unit_cost, 0)) * 100, 2) as profit_margin_percentage,
        -- Criando uma chave de categoria/subcategoria
        lower(concat(category, '_', subcategory)) as category_key,
        -- Identificando produtos premium
        case 
            when unit_price > 1000 then true 
            else false 
        end as is_premium_product,
        -- Calculando dias desde a criação
        (current_date - date(created_at)) as days_since_creation
    from source
)

select * from transformed
