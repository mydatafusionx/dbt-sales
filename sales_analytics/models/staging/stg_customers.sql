{{
  config(
    materialized='view',
    unique_key='customer_id'
  )
}}

with source as (
    select * from {{ source('raw', 'raw_customers') }}
),

transformed as (
    select
        customer_id,
        first_name,
        last_name,
        email,
        registration_date,
        segment,
        country,
        -- Adicionando algumas transformações
        lower(email) as email_lower,
        concat(first_name, ' ', last_name) as full_name,
        -- Padronizando o país
        case 
            when lower(country) in ('brasil', 'brazil', 'br') then 'Brasil'
            when lower(country) in ('portugal', 'pt') then 'Portugal'
            when lower(country) in ('espanha', 'espanha', 'es') then 'Espanha'
            else country
        end as country_standardized,
        -- Calculando dias desde o cadastro
        (current_date - registration_date) as days_since_registration
    from source
)

select * from transformed
