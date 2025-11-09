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

If you prefer a pre-configured container, use the dev container configuration in `.devcontainer/` (compatible with VS Code Dev Containers / GitHub Codespaces). It extends Ubuntu 24.04 and pre-installs `srecord`, so Bazel conversions succeed without additional setup.

## Quick Start
### Cocotb Tutorial Test

To run the tutorial cocotb testbench which loads and executes an ELF program:

1. Build the example program ELF:
```
bazel build //tests/cocotb/tutorial:coralnpu_v2_program
```
2. Run the cocotb test:
```
bazel run //tests/cocotb/tutorial:tutorial --test_output=errors
```

The test resolves the ELF path using (in order):
1. Environment variables `CORALNPU_ELF` or `ELF_PATH` (if set and points to a file)
2. Bazel runfiles lookup (workspace-aware)
3. `bazel-bin/tests/cocotb/tutorial/coralnpu_v2_program.elf`
4. Any matching `bazel-out/*/bin/tests/cocotb/tutorial/coralnpu_v2_program.elf`

If none are found it raises a clear error. Override explicitly:
```
export CORALNPU_ELF=/absolute/path/to/custom_program.elf
bazel run //tests/cocotb/tutorial:tutorial
```

### Required Global Symbols in Tutorial ELF

The tutorial program is expected to define the following global buffers (names can vary through allowed aliases):

| Purpose  | Primary Name      | Accepted Aliases                                      |
|----------|-------------------|-------------------------------------------------------|
| Input 1  | input1_buffer     | input1, in1, input_buffer_1                           |
| Input 2  | input2_buffer     | input2, in2, input_buffer_2                           |
| Output   | output_buffer     | output, out, result_buffer, outputs_buffer            |

If a symbol is missing, the test will raise an error listing attempted names. Define them in your C/C++ source, e.g.:
```c
// Example in program.cc
#include <stdint.h>
uint32_t input1_buffer[8];
uint32_t input2_buffer[8];
uint32_t output_buffer[8];
```

Populate inputs inside the test or from your program's initialization logic, and read back results after execution.

### Custom ELF Development Workflow

When iterating on your own program (e.g. `my_program.cc`) you can override the ELF the cocotb testbench loads without editing the test file:

```bash
export CORALNPU_ELF=$(pwd)/bazel-bin/tests/cocotb/tutorial/coralnpu_v2_program.elf
# Or point to a different target you built:
export CORALNPU_ELF=$(pwd)/bazel-bin/examples/coralnpu_v2_hello_world_add_floats.elf
bazel run //tests/cocotb/tutorial:tutorial --test_output=errors
```

If your binary is under another Bazel package, just set `CORALNPU_ELF` to its path inside `bazel-bin` (or provide an absolute path). The resolution order ensures explicit environment variables always win.

Minimal example C source defining required buffers:
```c
#include <stdint.h>
// Required global symbols (names or accepted aliases)
uint32_t input1_buffer[8];
uint32_t input2_buffer[8];
uint32_t output_buffer[8];

int main(void) {
	// Simple transform: output[i] = input1[i] + input2[i]
	for (int i = 0; i < 8; ++i) {
		output_buffer[i] = input1_buffer[i] + input2_buffer[i];
	}
	return 0; // Entry point address returned by loader.
}
```

### Git Fork & Upstream Sync Workflow

If you fork the repository for your own development (recommended, since upstream may evolve):

```bash
# Initial one-time setup after forking on GitHub (replace YOURNAME):
git remote rename origin upstream
git remote add origin https://github.com/YOURNAME/coralnpu.git

# Push your current main to your fork:
git push -u origin main

# Sync with upstream later:
git fetch upstream
git checkout main
git merge upstream/main      # or: git rebase upstream/main
git push origin main

# Create a feature branch:
git checkout -b feature/my-change
git push -u origin feature/my-change
```

Optional helper script (`scripts/sync-upstream.sh`):
```bash
#!/usr/bin/env bash
set -euo pipefail
git fetch upstream
git checkout main
git merge --ff-only upstream/main
git push origin main
```

### Troubleshooting Guide

| Symptom | Cause | Fix |
|---------|-------|-----|
| `FileNotFoundError: Cannot locate coralnpu_v2_program.elf` | ELF not built or path resolution failed | Run `bazel build //tests/cocotb/tutorial:coralnpu_v2_program` or set `CORALNPU_ELF=/abs/path/to/elf` |
| Missing required ELF symbols | Global arrays not defined with accepted names | Define `uint32_t input1_buffer[]`, `input2_buffer[]`, `output_buffer[]` (see aliases above) |
| `srec_cat not found` during build | Host tool `srecord` not installed | Install with `sudo apt-get install -y srecord` |
| `403` when pushing to `google-coral/coralnpu` | No write permission to upstream | Fork repo then set remotes (`origin` -> your fork, keep `upstream`) |
| Closed file / seek error when parsing ELF | Accessing symbols after file closed | Keep symbol lookup inside `with open(elf_path, "rb")` block (already implemented) |
| Verilator runs single-threaded | `--threads` not requested | Pass `--define VERILATOR_THREADS=<N>` to Bazel or set the `threads` attribute in the BUILD target. |

### Environment Variable Summary

| Variable | Purpose | Notes |
|----------|---------|-------|
| `CORALNPU_ELF` | Override default ELF path for tutorial cocotb test | Absolute or relative path; takes precedence |
| `ELF_PATH` | Secondary override (legacy/alternative) | Same behavior; if both set `CORALNPU_ELF` wins |
| `TEST_WORKSPACE` | Bazel sets this during `bazel run/test` | Used to build runfiles lookup label |



```bash
# Ensure that test suite passes
bazel run //tests/cocotb:core_mini_axi_sim_cocotb

# Build a binary
bazel build //examples:coralnpu_v2_hello_world_add_floats

# Build the Simulator (non-RVV for shorter build time):
bazel build //tests/verilator_sim:core_mini_axi_sim

# Run the binary on the simulator:
bazel-bin/tests/verilator_sim/core_mini_axi_sim --binary bazel-out/k8-fastbuild-ST-dd8dc713f32d/bin/examples/coralnpu_v2_hello_world_add_floats.elf

# Increase Verilator worker threads without editing BUILD files:
bazel build //tests/cocotb:core_mini_axi_model --define VERILATOR_THREADS=4
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

## Git LFS 说明 / Git LFS Note

当前仓库未启用 Git LFS 文件追踪：根目录没有 `.gitattributes` 中的 LFS 规则，且已移除遗留的 `pre-push` 钩子（原本要求安装 `git-lfs`）。因此推送操作无需 Git LFS 支持。

如果未来需要追踪较大的二进制或波形文件（例如仿真生成的 `.fst`、模型权重等），可按以下步骤启用：

```bash
sudo apt-get update && sudo apt-get install -y git-lfs   # 安装 git-lfs（容器或主机）
git lfs install                                          # 初始化当前用户的 LFS hooks
git lfs track "*.fst"                                   # 示例：追踪波形文件
git add .gitattributes
git commit -m "chore(lfs): track fst wave dumps"
git push origin <branch>
```

停用或撤销 LFS：
```bash
git lfs uninstall                 # 移除 LFS hooks（不删除已上传的 LFS 对象）
rm .gitattributes                 # 如不再需要任何 LFS 规则
git commit -m "chore(lfs): remove LFS tracking"
```

注意：若仅有少量、小体积的文本或源代码变更，不必启用 LFS；启用后需保证 CI 环境也具备 `git-lfs`（可在 devcontainer Dockerfile 或 CI workflow 中安装）。

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
