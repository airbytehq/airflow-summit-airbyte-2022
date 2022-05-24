{{ config(
    indexes = [{'columns':['_airbyte_emitted_at'],'type':'btree'}],
    unique_key = '_airbyte_ab_id',
    schema = "_airbyte_public",
    tags = [ "top-level-intermediate" ]
) }}
-- SQL model to parse JSON blob stored in a single column and extract into separated field columns as described by the JSON Schema
-- depends_on: {{ source('public', '_airbyte_raw_users') }}
select
    {{ json_extract_scalar('_airbyte_data', ['id'], ['id']) }} as user_id,
    {{ json_extract_scalar('_airbyte_data', ['name'], ['name']) }} as name,
    {{ json_extract_scalar('_airbyte_data', ['mail'], ['mail']) }} as email,
    {{ json_extract_scalar('_airbyte_data', ['username'], ['username']) }} as username,
    {{ json_extract_scalar('_airbyte_data', ['created_at'], ['created_at']) }} as created_at,
    {{ json_extract_scalar('_airbyte_data', ['updated_at'], ['updated_at']) }} as updated_at,
    _airbyte_ab_id,
    _airbyte_emitted_at,
    {{ current_timestamp() }} as _airbyte_normalized_at
from {{ source('public', '_airbyte_raw_users') }} as table_alias
-- data_stream
where 1 = 1
{{ incremental_clause('_airbyte_emitted_at') }}

