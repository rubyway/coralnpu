#!/usr/bin/env bash
set -euo pipefail

red() { printf "\033[31m%s\033[0m\n" "$*"; }
green() { printf "\033[32m%s\033[0m\n" "$*"; }
yellow() { printf "\033[33m%s\033[0m\n" "$*"; }

have() { command -v "$1" >/dev/null 2>&1; }
which_or() { command -v "$1" 2>/dev/null || true; }

root_dir() {
  git rev-parse --show-toplevel 2>/dev/null || pwd
}

echo "== Coral NPU 环境检查 =="

# Expected Bazel version
EXPECTED_BAZEL="(未指定)"
if [[ -f .bazelversion ]]; then
  EXPECTED_BAZEL=$(cat .bazelversion)
fi

echo "- 期望 Bazel 版本: ${EXPECTED_BAZEL}"

# Bazel actual
if have bazel; then
  echo "- Bazel: $(bazel --version) ($(which_or bazel))"
else
  yellow "- Bazel 未安装或不在 PATH (可在 devcontainer 外部主机安装，或使用容器内构建)"
fi

# Python version
if have python3; then
  echo "- Python3: $(python3 --version) ($(which_or python3))"
else
  yellow "- Python3 未找到"
fi

# srec_cat
if have srec_cat; then
  echo "- srec_cat: $(srec_cat --version 2>&1 | head -n1) ($(which_or srec_cat))"
else
  red "- 缺失: srec_cat (请安装 'srecord' 包)"
fi

# verilator
if have verilator; then
  # --version prints two lines; show first
  echo "- Verilator: $(verilator --version 2>&1 | head -n1) ($(which_or verilator))"
else
  yellow "- Verilator 未在 PATH (通常由 Bazel 第三方依赖/规则构建，不强制要求系统安装)"
fi

# gtkwave
if have gtkwave; then
  echo "- GTKWave: $(gtkwave --version 2>&1 | head -n1) ($(which_or gtkwave))"
else
  yellow "- GTKWave 未安装 (devcontainer 已内置; 主机上可使用: sudo apt-get install -y gtkwave)"
fi

# Minimal build smoke test (optional)
if have bazel; then
  echo "\n可选快速检查: Bazel 查询示例目标"
  if bazel query //... >/dev/null 2>&1; then
    green "- Bazel 工作空间可被识别"
  else
    yellow "- Bazel 查询失败（可能首次运行需下载依赖或网络受限）"
  fi
fi

echo "\n完成。"
