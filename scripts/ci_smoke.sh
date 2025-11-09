#!/usr/bin/env bash
set -euo pipefail

echo "== CI Smoke Checks =="

# Ensure env check runs and prints versions/paths
bash scripts/env_check.sh

echo "== Bazel workspace query =="
# Validate that the workspace is recognized and targets can be enumerated
bazel query //... > /dev/null

if [[ "${SMOKE_BUILD:-0}" == "1" ]]; then
	echo "== Optional build: examples ELF =="
	bazel build //examples:coralnpu_v2_hello_world_add_floats.elf --color=yes --curses=no
fi

echo "All smoke checks passed."
