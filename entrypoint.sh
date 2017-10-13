#!/bin/bash

# Create a ZK connection string for the servers and the root.
ZOOKEEPER_CONNECT=$ZOOKEEPER_SERVERS${ZOOKEEPER_ROOT:=/kafka}

if [ -z $ADVERTISED_HOST_NAME ]; then
  ADVERTISED_HOST_NAME=$(hostname -f)
  echo "Advertizing host name ${ADVERTISED_HOST_NAME}."
fi

# Create the config file.
sed -i \
    -e "s|\${ADVERTISED_HOST_NAME}|$ADVERTISED_HOST_NAME|g" \
    -e "s|\${ZOOKEEPER_CONNECT}|$ZOOKEEPER_CONNECT|g" /kafka/config/server.properties

cd /kafka
exec "$@"
