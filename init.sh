#!/bin/bash

set -e

# Stores an array of networks contained on the docker-compose.yml file.
NETWORKS=($(docker compose config --networks | awk '{print $1}'))

for network in "${NETWORKS[@]}"; do
	# Check if the network exists
	if ! docker network inspect "$network" >/dev/null 2>&1; then
		echo "Creating network: $network"
		docker network create --driver bridge --attachable "$network"
	else
		echo "Network already exists: $network"
	fi
done

# Starts the docker-compose services in detached mode
docker compose up -d
