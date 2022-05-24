FROM apache/airflow:2.3.0

USER root
RUN apt update
RUN apt install git -y
RUN apt update -y && sudo apt install -y build-essential libpq-dev

USER airflow
RUN pip install --no-cache-dir apache-airflow-providers-airbyte
RUN pip install psycopg2-binary --no-binary psycopg2-binary
RUN pip install dbt-core
RUN pip install dbt-postgres

USER root
RUN mkdir -p -m 777 /opt/airflow/dbt
RUN mkdir -p -m 777 /opt/airflow/dbt/logs
RUN mkdir -p -m 777 /opt/airflow/dbt/build
RUN mkdir -p -m 777 /opt/airflow/logs
RUN mkdir -p -m 777 /opt/airflow/logs/scheduler
RUN mkdir -p -m 777 /dbt
RUN chmod a+x /usr/bin/git
COPY dbt /opt/airflow/dbt
COPY dbt/profiles.yml /home/airflow/.dbt/profiles.yml
