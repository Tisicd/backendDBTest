FROM postgres:15-alpine

COPY init.sql /docker-entrypoint-initdb.d/

ENV POSTGRES_DB=backdb
ENV POSTGRES_USER=postgres
ENV POSTGRES_PASSWORD=postgres

EXPOSE 5432



