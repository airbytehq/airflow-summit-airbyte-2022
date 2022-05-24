{{ config(
    indexes = [{'columns':['_airbyte_emitted_at'],'type':'btree'}],
    unique_key = '_airbyte_ab_id',
    schema = "_airbyte_public",
    tags = [ "top-level-intermediate" ]
) }}
-- SQL model to build a hash column based on the values of this record
-- depends_on: {{ ref('data_stream_ab2') }}
select
    {{ dbt_utils.surrogate_key([
        'user_id',
    ]) }} as _airbyte_data_stream_hashid,
    tmp.*
from {{ ref('data_stream_ab2') }} tmp
-- data_stream
where 1 = 1
{{ incremental_clause('_airbyte_emitted_at') }}

