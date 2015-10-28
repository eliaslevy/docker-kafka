FROM elevy/java:7

ENV KAFKA_VERSION 0.8.2.2
ENV SCALA_VERSION 2.10
ENV KAFKA_RELEASE ${SCALA_VERSION}-${KAFKA_VERSION}

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y jq && \
    mkdir -p /kafka/config /kafka/data /kafka/logs /kafka/templates && \
    cd /tmp && \
    MIRROR=`curl -sSL https://www.apache.org/dyn/closer.cgi\?as_json\=1 | jq -r '.preferred'` && \
    curl -sSLO "${MIRROR}/kafka/${KAFKA_VERSION}/kafka_${KAFKA_RELEASE}.tgz" && \
    curl -sSLO https://dist.apache.org/repos/dist/release/kafka/${KAFKA_VERSION}/kafka_${KAFKA_RELEASE}.tgz.asc && \
    curl -sSL  https://kafka.apache.org/KEYS | gpg -q --import - && \
    gpg -q --verify kafka_${KAFKA_RELEASE}.tgz.asc && \
    tar -zx -C /kafka --strip-components=1 --no-same-owner -f kafka_${KAFKA_RELEASE}.tgz --wildcards '*/bin/*.sh' '*/libs/' && \
    rm -rf kafka_* && \
    cd /kafka/libs && \
    curl -sSLO http://repo1.maven.org/maven2/org/slf4j/slf4j-log4j12/1.7.9/slf4j-log4j12-1.7.9.jar && \
    useradd --system -d /kafka --user-group kafka && \
    chmod a+rwx /kafka/data /kafka/logs

ADD  config /kafka/templates/
COPY entrypoint.sh /

ENV PATH="/kafka/bin:$PATH" \
    JMX_PORT=7203 \
    KAFKA_JVM_PERFORMANCE_OPTS="-server -XX:PermSize=48m -XX:MaxPermSize=48m -XX:+UseG1GC -XX:MaxGCPauseMillis=20 -XX:InitiatingHeapOccupancyPercent=35 -XX:+DisableExplicitGC -Djava.awt.headless=true"

#USER kafka

ENTRYPOINT [ "/entrypoint.sh" ]

CMD [ "kafka-server-start.sh", "/kafka/config/server.properties" ]

# Kafka, JMX
EXPOSE 9092 7203
