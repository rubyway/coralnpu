#!/usr/bin/env bash
set -euo pipefail

echo "== CI Smoke Checks =="

# Ensure env check runs and prints versions/paths
bash scripts/env_check.sh

echo "== Bazel workspace query =="
# Validate that the workspace is recognized and targets can be enumerated
bazel query //... > /dev/null

echo "All smoke checks passed."
