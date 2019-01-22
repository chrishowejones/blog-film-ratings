FROM openjdk:8u181-alpine3.8

WORKDIR /

COPY target/film-ratings.jar film-ratings.jar
EXPOSE 3000

CMD java -jar film-ratings.jar
