FROM python:2.7-alpine
#FROM python:2.7.18-alpine3.11

WORKDIR /usr/src/app
RUN mkdir /usr/src/app/ui
ADD ./ui /usr/src/app/ui

COPY requirements.txt ./
COPY requirements-test.txt ./
RUN pip install --no-cache-dir -r requirements.txt -r requirements-test.txt

ENV MONGO mongo
ENV MONGO_PORT 27017
ENV FLASK_APP ui.py
EXPOSE 8000

ENTRYPOINT cd ui && gunicorn ui:app -b 0.0.0.0