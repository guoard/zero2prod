FROM lukemathwalker/cargo-chef:latest-rust-1.74 AS chef
WORKDIR /app
RUN apt-get update && apt-get install -y lld clang

FROM chef as planner
COPY . .
RUN cargo chef prepare --recipe-path recipe.json

FROM chef as builder
COPY --from=planner /app/recipe.json recipe.json
RUN cargo chef cook --release --recipe-path recipe.json
COPY . .
ENV SQLX_OFFLINE true
RUN cargo build --release --bin zero2prod

FROM debian:bookworm-slim AS runtime
WORKDIR /app
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends openssl ca-certificates curl && \
    apt-get autoremove -y && \
    apt-get clean && rm -rf /var/lib/apt/lists /var/cache/apt/archives
COPY --from=builder /app/target/release/zero2prod zero2prod
COPY configuration configuration
ENV APP_ENVIRONMENT production
ENTRYPOINT ["./zero2prod"]
