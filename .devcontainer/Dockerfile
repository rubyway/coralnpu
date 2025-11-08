# syntax=docker/dockerfile:1
FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

ENV DEBIAN_FRONTEND=noninteractive

# Core build deps can be extended later; keep minimal for now.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        srecord \
    && rm -rf /var/lib/apt/lists/*

# Optional: locale/timezone can be set here if needed.
