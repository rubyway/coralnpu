# Coral NPU

Coral NPU is a hardware accelerator for ML inferencing. Coral NPU is an Open Source IP designed by Google Research and is freely available for integration into ultra-low-power System-on-Chips (SoCs) targeting wearable devices such as hearables, augmented reality (AR) glasses and smart watches.

Coral NPU is a neural processing unit (NPU), also known as an AI accelerator or deep-learning processor. Coral NPU is based on the 32-bit RISC-V Instruction Set Architecture (ISA).

Coral NPU includes three distinct processor components that work together: matrix, vector (SIMD), and scalar.

![Coral NPU Archicture](doc/images/arch_overview_alpha.png)
[Coral NPU Architecture Datasheet](https://developers.google.com/coral/guides/hardware/datasheet)

## Coral NPU Features
Coral NPU offers the following top-level feature set:

* RV32IMF_Zve32x RISC-V instruction set (specifically `rv32imf_zve32x_zicsr_zifencei_zbb`)
* 32-bit address space for applications and operating system kernels
* Four-stage processor, in-order dispatch, out-of-order retire
* Four-way scalar, two-way vector dispatch
* 128-bit SIMD, 256-bit (future) pipeline
* 8 KB ITCM memory (tightly-coupled memory for instructions)
* 32 KB DTCM memory (tightly-coupled memory for data)
* Both memories are single-cycle-latency SRAM, more efficient than cache memory
* AXI4 bus interfaces, functioning as both manager and subordinate, to interact with external memory and allow external CPUs to configure Coral NPU

## System Requirements

* Bazel 6.2.1
* Python 3.9-3.12 (3.13 support is in progress)
* Toolchain prerequisites listed below

### Host Package Prerequisites

These host tools must be installed so Bazel rules (e.g. converting firmware images) succeed:

| Purpose | Tool | Ubuntu (>=24.04) Install |
|---------|------|---------------------------|
| Binary -> VMEM conversion | srec_cat (from srecord) | `sudo apt-get install -y srecord` |

If a required tool is missing, the build will now emit a clear error (for example: `'srec_cat' not found in PATH. Please install the 'srecord' package ...`). Install the package and re-run the build.

## Quick Start

```bash
# Ensure that test suite passes
bazel run //tests/cocotb:core_mini_axi_sim_cocotb

# Build a binary
bazel build //examples:coralnpu_v2_hello_world_add_floats

# Build the Simulator (non-RVV for shorter build time):
bazel build //tests/verilator_sim:core_mini_axi_sim

# Run the binary on the simulator:
bazel-bin/tests/verilator_sim/core_mini_axi_sim --binary bazel-out/k8-fastbuild-ST-dd8dc713f32d/bin/examples/coralnpu_v2_hello_world_add_floats.elf
```


![](doc/images/Coral_Logo_200px-2x.png)

## 分支合并状态检查 / Branch merge status

为便捷判断某个功能分支是否已经合并进主分支（默认 `origin/main`），提供脚本 `scripts/branch_merge_status.sh`。

- 退出码（Exit codes）
	- 0：已合并/已包含（merged/included）
	- 1：尚未合并（not merged；会列出分支独有提交）
	- 2：错误（参数或引用不存在等）

- 用法（Usage）
```bash
# 当前分支 vs origin/main
scripts/branch_merge_status.sh

# 指定分支
scripts/branch_merge_status.sh my/feature

# 指定基线与远端
scripts/branch_merge_status.sh my/feature --base develop --remote upstream
```

脚本会打印分支/HEAD、远端基线 SHA、merge-base 以及具体状态（已合并/可快进/分叉）并列出双方独有提交，便于评审与发布流程判断。

## 环境快照与校验

为保证可复现的构建/测试环境，本仓库提供以下两种方式：

- Dev Container（推荐）：在 VS Code 中使用 `.devcontainer/` 定义的容器环境。该镜像基于 Ubuntu 24.04，并预装了构建所需系统依赖：
	- srecord（提供 `srec_cat`）
	- gtkwave（波形查看工具）

- 主机环境：按“Host Package Prerequisites”安装缺少的包（至少 `srecord`，以及需要查看波形时的 `gtkwave`）。

你可以用脚本快速检查当前环境是否满足依赖：

```bash
bash scripts/env_check.sh
```

该脚本会输出：

- 期望的 Bazel 版本（来自 `.bazelversion`）与实际 `bazel --version`
- Python3 版本
- `srec_cat`（来自 srecord）、`verilator`、`gtkwave` 的存在性与版本/路径
- 可选的 Bazel 工作空间快速检查

如脚本提示缺少 `srec_cat`，请安装 `srecord` 包；如缺少 `gtkwave`，请安装 `gtkwave` 包或使用 Dev Container。
