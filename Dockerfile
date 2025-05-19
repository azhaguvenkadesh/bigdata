FROM codercom/code-server:latest

# Set environment variables
ENV HADOOP_VERSION=3.3.3 \
    HIVE_VERSION=3.1.3 \
    SPARK_VERSION=3.5.0 \
    HUE_VERSION=4.11 \
    OOZIE_VERSION=5.2.1 \
    SQOOP_VERSION=1.4.7 \
    AIRFLOW_VERSION=2.9.2 \
    KAFKA_VERSION=3.7.2 \
    SCALA_VERSION=2.12.15 \
    JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64

USER root

# Install dependencies
RUN apt-get update && apt-get install -y \
    openjdk-11-jdk \
    wget \
    curl \
    git \
    unzip \
    net-tools \
    python3-pip \
    python3-venv \
    build-essential \
    libmysql-java \
    libkrb5-dev \
    gnupg2 \
    libsnappy-dev \
    libsasl2-dev \
    libssl-dev \
    libffi-dev \
    lsb-release \
    software-properties-common

# Scala & Hadoop
RUN wget https://downloads.lightbend.com/scala/${SCALA_VERSION}/scala-${SCALA_VERSION}.deb && \
    dpkg -i scala-${SCALA_VERSION}.deb && \
    rm scala-${SCALA_VERSION}.deb

# Hadoop
RUN wget https://downloads.apache.org/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz && \
    tar -xzf hadoop-${HADOOP_VERSION}.tar.gz -C /opt && \
    rm hadoop-${HADOOP_VERSION}.tar.gz && \
    ln -s /opt/hadoop-${HADOOP_VERSION} /opt/hadoop

# Hive
RUN wget https://downloads.apache.org/hive/hive-${HIVE_VERSION}/apache-hive-${HIVE_VERSION}-bin.tar.gz && \
    tar -xzf apache-hive-${HIVE_VERSION}-bin.tar.gz -C /opt && \
    rm apache-hive-${HIVE_VERSION}-bin.tar.gz && \
    ln -s /opt/apache-hive-${HIVE_VERSION}-bin /opt/hive

# Spark
RUN wget https://downloads.apache.org/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop3.tgz && \
    tar -xzf spark-${SPARK_VERSION}-bin-hadoop3.tgz -C /opt && \
    rm spark-${SPARK_VERSION}-bin-hadoop3.tgz && \
    ln -s /opt/spark-${SPARK_VERSION}-bin-hadoop3 /opt/spark

# Kafka
RUN wget https://downloads.apache.org/kafka/${KAFKA_VERSION}/kafka_2.13-${KAFKA_VERSION}.tgz && \
    tar -xzf kafka_2.13-${KAFKA_VERSION}.tgz -C /opt && \
    rm kafka_2.13-${KAFKA_VERSION}.tgz && \
    ln -s /opt/kafka_2.13-${KAFKA_VERSION} /opt/kafka

# Sqoop
RUN wget https://downloads.apache.org/sqoop/${SQOOP_VERSION}/sqoop-${SQOOP_VERSION}.bin__hadoop-3.3.3.tar.gz && \
    tar -xzf sqoop-${SQOOP_VERSION}.bin__hadoop-3.3.3.tar.gz -C /opt && \
    rm sqoop-${SQOOP_VERSION}.bin__hadoop-3.3.3.tar.gz && \
    ln -s /opt/sqoop-${SQOOP_VERSION}.bin__hadoop-3.3.3 /opt/sqoop

# Oozie
RUN wget https://downloads.apache.org/oozie/${OOZIE_VERSION}/oozie-${OOZIE_VERSION}.tar.gz && \
    tar -xzf oozie-${OOZIE_VERSION}.tar.gz -C /opt && \
    rm oozie-${OOZIE_VERSION}.tar.gz && \
    ln -s /opt/oozie-${OOZIE_VERSION} /opt/oozie

# Hue dependencies and install
RUN apt-get install -y python3-dev python3-setuptools python3-pip \
    libgmp-dev libmysqlclient-dev libsasl2-dev libldap2-dev \
    libssl-dev libffi-dev libtidy-dev libcurl4-openssl-dev && \
    pip3 install virtualenv

RUN cd /opt && \
    git clone https://github.com/cloudera/hue.git && \
    cd hue && \
    git checkout release-${HUE_VERSION} && \
    make apps

# Apache Airflow
RUN pip install apache-airflow==${AIRFLOW_VERSION} \
    apache-airflow[mysql,celery,postgres,redis,ssh]==${AIRFLOW_VERSION}

# Set PATH
ENV PATH="$PATH:/opt/hadoop/bin:/opt/hive/bin:/opt/spark/bin:/opt/kafka/bin:/opt/sqoop/bin:/opt/oozie/bin:/opt/hue/build/env/bin"

# Set default working directory
WORKDIR /home/coder/project

# Expose ports for various services (adjust as needed)
EXPOSE 8080 8088 50070 8888 5000 18080 10000 8020 4040

# Start script for required services
COPY start-all.sh /usr/local/bin/start-all.sh
RUN chmod +x /usr/local/bin/start-all.sh

CMD ["start-all.sh"]
