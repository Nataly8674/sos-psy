FROM dart:stable AS build

WORKDIR /app

COPY pubspec.* ./
RUN dart pub get

COPY . .

RUN dart compile exe bin/server.dart -o server

FROM debian:bullseye-slim

WORKDIR /app

COPY --from=build /app/server /app/server

RUN mkdir -p /app/data

EXPOSE 8080

CMD ["/app/server"]