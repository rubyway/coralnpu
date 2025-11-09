## 仿真改动 / Simulation Changes

### 概述 / Summary
<!-- 说明涉及的模拟器(Verilator/VCS/其他)、测试、波形/日志输出 / Simulator, tests, wave/log outputs -->

### 动机 / Motivation
<!-- 为什么需要这次仿真改动 / Why this simulation change is needed -->

### 关键参数 / Key Parameters
- 线程 / Threads: `--define VERILATOR_THREADS=N`
- 波形 / Waveforms: `--trace` / FST/VCD
- 超时 / Timeout: <!-- 如适用 / if applicable -->

### 主要更改 / Key Changes
- <!-- 新增或修改的 targets/tests/rules / New or changed targets/tests/rules -->

### 验证 / Validation
```bash
# 示例：构建与运行 / Example: build & run
bazel build //tests/verilator_sim:core_mini_axi_sim --color=yes --curses=no
# 运行并打开波形（如适用） / Run & open waveform (if applicable)
# gtkwave path/to/wave.fst
```

### 性能与稳定性 / Performance & Stability
- <!-- 构建时长、运行用时、内存占用、并发性 / Build time, runtime, memory, concurrency -->

### 兼容性 / Compatibility
- <!-- 与现有测试/规则/脚本的兼容性 / Compatibility with existing tests/rules/scripts -->

### 风险与回滚 / Risks & Rollback
- <!-- 潜在风险；回滚步骤 / Potential risks; how to revert -->

### 后续 / Follow-ups
- <!-- 打算新增的测试/波形/工具支持 / Future tests/waves/tools support -->

### Checklist
- [ ] 可重现仿真步骤 / Reproducible sim steps
- [ ] 波形/日志可用 / Wave/log available
- [ ] 性能可接受 / Performance acceptable
- [ ] 与 CI 兼容 / CI compatible
