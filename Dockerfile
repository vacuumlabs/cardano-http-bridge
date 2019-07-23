# build stage, see http://whitfin.io/speeding-up-rust-docker-builds/
FROM rust:1.37-slim as build

WORKDIR /home/docker
RUN USER=docker cargo new --bin cardano-http-bridge
WORKDIR /home/docker/cardano-http-bridge

COPY Cargo.toml Cargo.lock ./
COPY cardano-deps ./cardano-deps

RUN cargo build --release
RUN rm src/*.rs

COPY ./src ./src
RUN rm -r target/release/deps/cardano_http_bridge*
RUN cargo build --release

# final stage
FROM debian:jessie-slim

EXPOSE 8082

WORKDIR /home/docker
COPY --from=build /home/docker/cardano-http-bridge/target/release/cardano-http-bridge .

ENTRYPOINT ["sh","-c", "./cardano-http-bridge start --networks-dir /home/docker/data --port 8082 --template $CARDANO_NETWORK"]
