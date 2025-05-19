#!/bin/bash
# Start HDFS
$HADOOP_HOME/sbin/start-dfs.sh

# Start YARN
$HADOOP_HOME/sbin/start-yarn.sh

# Start Hive Metastore
nohup hive --service metastore &

# Start HiveServer2
nohup hive --service hiveserver2 &

# Start Spark History Server
nohup /opt/spark/sbin/start-history-server.sh &

# Start Kafka and Zookeeper
nohup /opt/kafka/bin/zookeeper-server-start.sh /opt/kafka/config/zookeeper.properties &
sleep 5
nohup /opt/kafka/bin/kafka-server-start.sh /opt/kafka/config/server.properties &

# Start Airflow webserver & scheduler
airflow db init
nohup airflow scheduler &
nohup airflow webserver -p 8080 &

# Start Hue (optional)
cd /opt/hue && build/env/bin/supervisor &

# Keep container running
tail -f /dev/null
