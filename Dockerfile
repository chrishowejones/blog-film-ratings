FROM openjdk:8u181-alpine3.8

WORKDIR /

RUN apk update && apk add bash

COPY wait-for-it.sh wait-for-it.sh

COPY target/film-ratings.jar film-ratings.jar
EXPOSE 3000

RUN chmod +x wait-for-it.sh

CMD ["sh", "-c", "./wait-for-it.sh --timeout=90 $DB_HOST:5432 -- java -jar film-ratings.jar"]
