# TODO: Find a way to cross-compile for aarch64 on x86_64 without using Docker Buildx

# # Use a minimal Rust image for building
# FROM rust:alpine AS builder

# # Install build dependencies
# RUN apk add --no-cache musl-dev build-base

# # Install the Rust musl target for aarch64
# RUN rustup target add aarch64-unknown-linux-musl


# WORKDIR /app

# COPY Cargo.toml Cargo.lock  ./

# RUN mkdir -p src \
#     && echo 'fn main() { println!("This is a dummy file to satisfy Cargo"); }' > src/main.rs \
#     && cargo fetch --target aarch64-unknown-linux-musl

# COPY . .

# # Build the application
# # Leverage cache mounts for Cargo registry and target directories
# RUN --mount=type=cache,target=/usr/local/cargo/registry \
#     --mount=type=cache,target=/app/target \
#     cargo build --target aarch64-unknown-linux-musl --release \
#     && strip /app/target/aarch64-unknown-linux-musl/release/tire_monitor \
#     && mkdir -p /app/bin \
#     && cp /app/target/aarch64-unknown-linux-musl/release/tire_monitor /app/bin/

FROM rust:alpine AS base

# Install build dependencies
RUN apk add --no-cache musl-dev build-base

RUN cargo install cargo-chef
RUN rustup target add aarch64-unknown-linux-musl

# Step 1: Dependency planning
FROM base AS planner
WORKDIR /app
COPY . .
RUN --mount=type=cache,target=/usr/local/cargo/registry \
    cargo chef prepare --recipe-path recipe.json

# Step 2: Build dependencies only
FROM base AS builder
WORKDIR /app
COPY --from=planner /app/recipe.json recipe.json
RUN --mount=type=cache,target=/usr/local/cargo/registry \
    cargo chef cook --release --target aarch64-unknown-linux-musl --recipe-path recipe.json

# Step 3: Build application
COPY . .
RUN --mount=type=cache,target=/usr/local/cargo/registry \
    cargo build --release --target aarch64-unknown-linux-musl \
    && strip /app/target/aarch64-unknown-linux-musl/release/tire_monitor


# Use a minimal base image for the final stage
FROM scratch

# Copy the built executable from the builder stage
COPY --from=builder /app/target/aarch64-unknown-linux-musl/release/tire_monitor ./tire_monitor

# Command to run the executable
CMD ["./tire_monitor"]