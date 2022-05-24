#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

"""Example DAG demonstrating the usage of the AirbyteTriggerSyncOperator."""

from datetime import datetime, timedelta
import requests
from airflow.operators.python import PythonOperator
import json


from airflow import DAG
from airflow.providers.airbyte.operators.airbyte import AirbyteTriggerSyncOperator
from airflow.operators.bash_operator import BashOperator

DBT_PROJECT_DIR = "/opt/airflow/dbt/"

def get_ab_conn_id(ds=None, **kwargs):
    ab_url = "http://airbyte-server:8001/api/v1"
    headers = {"Accept": "application/json", "Content-Type": "application/json"}
    workspace_id = requests.post(f"{ab_url}/workspaces/list", headers=headers).json().get("workspaces")[0].get("workspaceId")
    payload = json.dumps({"workspaceId": workspace_id})
    connections = requests.post(f"{ab_url}/connections/list", headers=headers, data=payload).json().get("connections")
    for c in connections:
        if c.get("name") == "demo_connection":
            return c.get("connectionId")


with DAG(
    dag_id='airflow_summit_airbyte',
    schedule_interval='@daily',
    start_date=datetime(2021, 1, 1),
    dagrun_timeout=timedelta(minutes=60),
    tags=['example'],
    catchup=False,
) as dag:

    airbyte_conn_id = PythonOperator(
        task_id="get_ab_conn_id",
        python_callable=get_ab_conn_id,
    )

    sync_source_destination = AirbyteTriggerSyncOperator(
        task_id='airbyte_sync_source_dest_example',
        connection_id=airbyte_conn_id.output,
        trigger_rule="none_failed",
    )

    dbt_deps = BashOperator(
        task_id="dbt_deps",
        bash_command=f"dbt deps --profiles-dir {DBT_PROJECT_DIR} --project-dir {DBT_PROJECT_DIR}",
        trigger_rule="none_failed",
    )

    dbt_run = BashOperator(
        task_id="dbt_run",
        bash_command=f"dbt run --project-dir {DBT_PROJECT_DIR}",
        trigger_rule="none_failed",
    )


    sync_source_destination >> dbt_deps >> dbt_run
