{{ config(
    indexes = [{'columns':['_airbyte_emitted_at'],'type':'btree'}],
    unique_key = '_airbyte_ab_id',
    schema = "_airbyte_public",
    tags = [ "top-level-intermediate" ]
) }}
-- SQL model to cast each column to its adequate SQL type converted from the JSON schema type
-- depends_on: {{ ref('data_stream_ab1') }}
select
    cast(user_id as {{ dbt_utils.type_bigint() }}) as user_id,
    split_part(cast(name as {{ dbt_utils.type_string() }}), ' ', 1) as first_name,
    split_part(cast(name as {{ dbt_utils.type_string() }}), ' ', 2) as last_name,
    cast(email as {{ dbt_utils.type_string() }}) as email,
    cast(username as {{ dbt_utils.type_string() }}) as username,
    cast(created_at as {{ dbt_utils.type_timestamp() }}) as created_at,
    cast(updated_at as {{ dbt_utils.type_timestamp() }}) as updated_at,
    _airbyte_ab_id,
    _airbyte_emitted_at,
    {{ current_timestamp() }} as _airbyte_normalized_at
from {{ ref('data_stream_ab1') }}
-- data_stream
where 1 = 1
{{ incremental_clause('_airbyte_emitted_at') }}

