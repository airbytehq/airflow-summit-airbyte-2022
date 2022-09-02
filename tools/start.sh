#!/bin/bash
# expand alias
docker login
shopt -s expand_aliases

# Install local requirements
pip3 install -r requirements.txt

# Network airflow_summit_network declared as external, but could not be found.
# Please create the network manually using `docker network create airflow_summit_network` and try again.


docker network create -d bridge airflow_summit_network

# configure octavia in the script
OCTAVIA_ENV_FILE=${HOME}/.octavia
DBT_PROFILE_FILE=${HOME}/.dbt/profiles.yaml
alias octavia='docker run -i --rm -v $(pwd):/home/octavia-project --network airflow_summit_network --env-file ${OCTAVIA_ENV_FILE} --user $(id -u):$(id -g) airbyte/octavia-cli:0.39.0-alpha --airbyte-url http://airbyte-server:8001'

# Cleanup old state files
rm -rf airbyte/*/*/state.yaml

# Because of Mac M1 + dbt, we need to use an older version of postgres for now
docker run --name dest --network airflow_summit_network -e POSTGRES_USER=demo_user -e POSTGRES_PASSWORD=password -p 5432:5432 -d postgres:10

cd airflow
cp ${DBT_PROFILE_FILE} dbt/profiles.yml
docker build . -t airflow-airbyte:1.0.0 --platform linux/amd64
rm -f dbt/profiles.yml
cd ..
docker-compose -f airflow/docker-compose.yaml up -d airflow-init
docker-compose -f airflow/docker-compose.yaml up -d
docker exec airflow-webserver airflow connections add 'airbyte_default' --conn-uri 'http://airbyte-server:8001'
docker-compose -f airbyte/docker-compose.yaml up -d

echo "wait airbyte to be ready..."
bash -c 'while [[ "$(curl -s -o /dev/null -w ''%{http_code}'' localhost:8001/api/v1/health)" != "200" ]]; do echo "  [`date`] waiting...." && sleep 5; done'

cd airbyte
octavia init
octavia apply -f sources/fake_users/configuration.yaml
octavia apply -f destinations/postgres_destination/configuration.yaml
cd ..; python3 tools/change_resource_id.py; cd airbyte
octavia apply -f connections/demo_connection/configuration.yaml

touch $(pwd)/test.log
docker exec airflow-webserver airflow dags test airflow_summit_airbyte 2022-01-01 | tee $(pwd)/test.log

if [[ $(grep "Some task instances failed:" $(pwd)/test.log) ]]; then
    echo "The dag exit with errors"
    exit 1
else
    echo "The dag exit successfully"
    exit 0
fi

docker stop dest
docker rm dest
