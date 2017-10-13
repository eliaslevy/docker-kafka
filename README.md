Kafka Docker image.  It expects a comma delimited list of ZooKeeper servers via the 
`ZOOKEEPER_SERVERS` environment variable, an optional root path within ZooKeeper were to
store it's state via `ZOOKEEPER_ROOT` (it defaults to `/kafka`), and an optional hostname for
the broker to adversize to clients via `ADVERTISED_HOST_NAME` (it defaults to the output of 
`hostname -f`).

It can be executed in Kuebernetes using a replication controller using a config like:

```
apiVersion: v1
kind: Service
metadata:
  name: kafka
spec:
  clusterIP: None
  ports:
    - name: kafka
      port: 9092
    - name: jmx
      port: 7203
  selector:
    app: kafka
---
apiVersion: v1
kind: ReplicationController
metadata:
  name: kafka
spec:
  replicas: 1
  template:
    metadata:
      labels:
        app: kafka
    spec:
      volumes:
        - name: config
          emptyDir: {}
        - name: data
          emptyDir: {}
        - name: log
          emptyDir: {}
      containers:
        - name: server
          image: elevy/kafka:latest
          env:
            - name: ZOOKEEPER_SERVERS
              value: zookeeper:2181
            - name: ZOOKEEPER_ROOT
              value: /kafka
            #- name: KAFKA_HEAP_OPTS
            #  value: "-Xms4g -Xmx4g"
          ports:
            - containerPort: 9092
            - containerPort: 7203
          volumeMounts:
            # Ensure persistence if the containers in the pod terminate.
            - mountPath: /kafka/config
              name: config
            - mountPath: /kafka/data
              name: data
            - mountPath: /kafka/log
              name: log
```