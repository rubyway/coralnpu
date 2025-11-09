# syntax=docker/dockerfile:1

FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

ENV DEBIAN_FRONTEND=noninteractive

# Minimal system dependencies for this repo's build/test flows.
# - srecord: provides srec_cat used by Bazel actions (bin -> vmem)
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        srecord \
        gtkwave \
        curl \
        ca-certificates \
    # Install Bazel via Bazelisk (puts "bazel" on PATH)
    && curl -sSL -o /usr/local/bin/bazel https://github.com/bazelbuild/bazelisk/releases/download/v1.19.0/bazelisk-linux-amd64 \
    && chmod +x /usr/local/bin/bazel \
    # Print version (non-fatal) to help cache diagnostics
    && /usr/local/bin/bazel --version || true \
    && rm -rf /var/lib/apt/lists/*

# Install Bazelisk (lightweight Bazel launcher) so container always has `bazel`.
# Bazel version pinned via repository .bazelversion at runtime.
ARG BAZELISK_VERSION=v1.19.0
RUN curl -fsSL -o /usr/local/bin/bazel \
      https://github.com/bazelbuild/bazelisk/releases/download/${BAZELISK_VERSION}/bazelisk-linux-amd64 \
    && chmod +x /usr/local/bin/bazel \
    && bazel --version || true

# Optional: locale/timezone can be set here if needed.
