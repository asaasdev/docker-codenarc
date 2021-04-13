FROM openjdk:8-jdk-slim AS build

RUN DEBIAN_FRONTEND=noninteractive \
    apt-get update && \
    apt-get install -y git && \
    apt-get clean && rm -rf /var/lib/apt/lists/* 

WORKDIR /code

RUN git clone -b master --depth 1 https://github.com/asaasdev/CodeNarc.git

WORKDIR /code/CodeNarc

RUN ./gradlew --no-daemon jar

FROM groovy:4.0

USER root

RUN DEBIAN_FRONTEND=noninteractive \
    apt-get update && \
    apt-get install -y git && \
    apt-get clean && rm -rf /var/lib/apt/lists/* 

USER groovy

ENV CODENARC_VER=2.0.0
ENV SLF4J_VER=1.7.30
ENV GMETRICS_VERSION=1.1
ENV GROOVY_JAR=$GROOVY_HOME/lib/*
ENV HOME_JARS=/home/groovy/*

RUN wget https://repo1.maven.org/maven2/org/slf4j/slf4j-api/$SLF4J_VER/slf4j-api-$SLF4J_VER.jar
RUN wget https://repo1.maven.org/maven2/org/slf4j/slf4j-simple/$SLF4J_VER/slf4j-simple-$SLF4J_VER.jar
RUN wget https://github.com/dx42/gmetrics/releases/download/v$GMETRICS_VERSION/gmetrics-$GMETRICS_VERSION.jar

COPY --from=build /code/CodeNarc/build/libs/CodeNarc-$CODENARC_VER.jar odeNarc-$CODENARC_VER.jar

COPY codenarc /usr/bin

WORKDIR /app

ENTRYPOINT ["codenarc"]
