{{ config(
    indexes = [{'columns':['_airbyte_emitted_at'],'type':'btree'}],
    unique_key = '_airbyte_ab_id',
    schema = "public",
    tags = [ "top-level" ]
) }}
-- Final base SQL model
-- depends_on: {{ ref('data_stream_ab3') }}
select
    user_id,
    first_name,
    last_name,
    email,
    username,
    created_at,
    updated_at,
    _airbyte_ab_id,
    _airbyte_emitted_at,
    {{ current_timestamp() }} as _airbyte_normalized_at,
    _airbyte_data_stream_hashid
from {{ ref('data_stream_ab3') }}
-- data_stream from {{ source('public', '_airbyte_raw_users') }}
where 1 = 1
{{ incremental_clause('_airbyte_emitted_at') }}

