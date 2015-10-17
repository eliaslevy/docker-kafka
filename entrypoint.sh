#!/bin/bash

echo "ENTRYPOINT"
echo $ZOOKEEPER_CONNECT

echo create /kafka_id_alloc 0 | /kafka/bin/zookeeper-shell.sh $ZOOKEEPER_CONNECT &> /dev/null
BROKER_ID=`echo set /kafka_id_alloc 0 | /kafka/bin/zookeeper-shell.sh $ZOOKEEPER_CONNECT 2>&1 | grep dataVersion | cut -d' ' -f 3`


sed -e "s|\${BROKER_ID}|$BROKER_ID|g" \
		-e "s|\${ZOOKEEPER_CONNECT}|$ZOOKEEPER_CONNECT|g" /kafka/config/server.properties.template > /kafka/config/server.properties

cd /kafka
exec "$@"
