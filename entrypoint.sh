#!/bin/bash

# Create a ZK connection string for the servers and the root.
ZOOKEEPER_CONNECT=()
IFS=\, read -a servers <<< "${ZOOKEEPER_SERVERS:=zookeeper:2181}"
for server in "${servers[@]}"; do 
	ZOOKEEPER_CONNECT+=("$server${ZOOKEEPER_ROOT:=/kafka}")
done
ZOOKEEPER_CONNECT=$(IFS=, ; echo "${ZOOKEEPER_CONNECT[*]}")

echo "Using ZK at ${ZOOKEEPER_CONNECT}"

# Create the ZK root.
echo create "$ZOOKEEPER_ROOT" 0 | /kafka/bin/zookeeper-shell.sh $ZOOKEEPER_SERVERS &> /dev/null

# Create node to use for id allocation.
echo create /kafka_id_alloc 0 | /kafka/bin/zookeeper-shell.sh $ZOOKEEPER_CONNECT &> /dev/null

# Allocate an id by writing to a node and retriving its version number.
BROKER_ID=`echo set /kafka_id_alloc 0 | /kafka/bin/zookeeper-shell.sh $ZOOKEEPER_CONNECT 2>&1 | grep dataVersion | cut -d' ' -f 3`
echo "Allocated brokder id ${BROKER_ID}."

# Create the config file.
sed -e "s|\${BROKER_ID}|$BROKER_ID|g" \
		-e "s|\${ZOOKEEPER_CONNECT}|$ZOOKEEPER_CONNECT|g" /kafka/config/server.properties.template > /kafka/config/server.properties

cd /kafka
exec "$@"
