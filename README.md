# `git push` your data stack with Airbyte, Airflow and dbt

_For Airflow Summit 2022, by [@marcosmarcm](https://github.com/marcosmarxm) and [@evantahler](https://github.com/evantahler) from [Airbyte](https://github.com/airbytehq)_

[![CI](https://github.com/airbytehq/airflow-summit-airbyte-2022/actions/workflows/data-pipeline.yml/badge.svg)](https://github.com/airbytehq/airflow-summit-airbyte-2022/actions/workflows/data-pipeline.yml)

## What:

Links:

- [Slides](https://docs.google.com/presentation/d/17TuHlzgF3x_Q2NtkOq0O7SmR9e0MGqXMqlwVqJyUoKI)
- [Speaker Page](https://airflowsummit.org/sessions/2022/git-push-your-data-stack-with-airbyte-airflow-and-dbt/)

This project configures a sample data stack orchestrated by Airflow, using Airbyte to Extract and Load data, and dbt to Transform it.

## Running Locally:

0.  Install [Docker Desktop](https://www.docker.com/products/docker-desktop/) and Python 3 (if you are on MacOS, you already have Python 3).

1.  Create `{HOME}/.octavia` and add the following credentials for using a local postgres database managed by Docker:

```
POSTGRES_HOST=host.docker.internal
POSTGRES_PASSWORD=password
POSTGRES_USERNAME=demo_user
POSTGRES_DATABASE=postgres
```

2. Create the profile dbt in `{HOME}/.dbt/profiles.yaml`

```
config:
  partial_parse: true
  printer_width: 120
  send_anonymous_usage_stats: false
  use_colors: true
normalize:
  outputs:
    prod:
      dbname: postgres
      host: host.docker.internal
      pass: password
      port: 5432
      schema: public
      threads: 8
      type: postgres
      user: demo_user
  target: prod
```

3. Run the whole data stack using `./tools/start.sh`. This will install local requirements (PyYAML) and run everything though Docker. The script will exit when complete, but the Docker containers will remain running.

In your browser:

- Visit http://localhost:8080/ to see the Airflow UI (user: `airflow`, password: `airflow`) and your completed DAG.
- Visit http://localhost:8000/ to see the Airbyte UI and your completed Sync.
- Visit your local postgres database (`localhost:5432`) with the `username=demo_user` and `password=password` to see the staged and transformed data.

## Shut it down

Run `./tools/stop.sh` to stop the Docker containers.

## Testing

This repository is tested using Github Actions.
