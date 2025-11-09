# syntax=docker/dockerfile:1

FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

ENV DEBIAN_FRONTEND=noninteractive

# Minimal system dependencies for this repo's build/test flows.
# - srecord: provides srec_cat used by Bazel actions (bin -> vmem)
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        srecord \
        gtkwave \
    && rm -rf /var/lib/apt/lists/*

# Optional: locale/timezone can be set here if needed.
