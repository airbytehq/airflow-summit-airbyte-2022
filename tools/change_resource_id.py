import yaml

source_state = yaml.safe_load(open("airbyte/sources/fake_users/state.yaml"))
source_id = source_state.get("resource_id")

destination_state = yaml.safe_load(open("airbyte/destinations/postgres_destination/state.yaml"))
destination_id = destination_state.get("resource_id")

connection_config = yaml.safe_load(open("airbyte/connections/demo_connection/configuration.yaml"))
connection_config["source_id"] = source_id
connection_config["destination_id"] = destination_id

yaml.dump(connection_config, open("airbyte/connections/demo_connection/configuration.yaml", "w"))
