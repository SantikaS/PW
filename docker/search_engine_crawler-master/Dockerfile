FROM python:3.6-alpine

WORKDIR /usr/src/app
RUN mkdir /usr/src/app/crawler
ADD ./crawler /usr/src/app/crawler

COPY requirements.txt ./
COPY requirements-test.txt ./
#RUN apt-get update && apt-get install -y python3-pip
RUN pip3 install --no-cache-dir -r requirements.txt -r requirements-test.txt

ENV MONGO mongo
ENV MONGO_PORT 27017
ENV RMQ_HOST rabbitmq
ENV RMQ_QUEUE rabbitmq
ENV RMQ_USERNAME admin
ENV RMQ_PASSWORD admin
ENV CHECK_INTERVAL 1
ENV EXCLUDE_URLS ".*github.com"
ENV URL "https://vitkhab.github.io/search_engine_test_site/"

ENTRYPOINT python3 -u crawler/crawler.py $URL