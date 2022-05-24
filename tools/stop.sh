#!/bin/bash

cd airbyte/; docker-compose down -v; cd ..
cd airflow/; docker-compose down -v; cd ..
docker stop dest && docker rm dest -v

# Cleanup old state files
rm -rf airbyte/*/*/state.yaml
