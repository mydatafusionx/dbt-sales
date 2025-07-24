{{
  config(
    materialized='view',
    unique_key='order_id'
  )
}}

with source as (
    select * from {{ source('raw', 'raw_orders') }}
),

transformed as (
    select
        order_id,
        customer_id,
        order_date,
        product_id,
        quantity,
        unit_price,
        total_amount,
        -- Adicionando algumas colunas calculadas
        quantity * unit_price as calculated_total,
        -- Garantindo que o total_amount está correto
        case
            when total_amount != (quantity * unit_price) then true
            else false
        end as needs_review
    from source
)

select * from transformed
