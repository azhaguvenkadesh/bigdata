#!/bin/bash
echo "Verifying Hadoop:" && hadoop version
echo "Verifying Hive:" && hive --version
echo "Verifying Spark:" && spark-shell --version
echo "Verifying Hue:" && curl -s -o /dev/null -w "%{http_code}\n" http://localhost:8888
echo "Verifying Oozie:" && oozie version
echo "Verifying Sqoop:" && sqoop version
echo "Verifying Airflow:" && airflow version
echo "Verifying Kafka:" && kafka-topics.sh --version
