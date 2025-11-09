## 规则/构建系统改动 / Bazel Rules & Build Changes

### 概述 / Summary
<!-- 说明涉及的规则(starlark)、宏、BUILD 目标或工具链 / Mention affected rules/macros/targets/toolchains -->

### 动机 / Motivation
<!-- 为什么需要这次规则或构建系统改动 / Why this change is needed -->

### API/属性变化 / API & Attributes Changes
- <!-- 新增/修改的 rule 属性；默认值变化；弃用说明 / New/changed rule attrs; default changes; deprecations -->

### 向后兼容性 / Backward Compatibility
- <!-- 是否有破坏性更改；迁移指南 / Any breaking changes; migration notes -->

### 性能与可复现性 / Performance & Reproducibility
- <!-- 线程/缓存/沙箱/远程缓存影响 / Threads, caching, sandbox, remote cache impact -->

### 验证 / Validation
```bash
# 示例：构建/查询 / Examples: build/query
bazel query //...
bazel build //path:target --color=yes --curses=no
```

### 风险与回滚 / Risks & Rollback
- <!-- 潜在风险；回滚步骤 / Potential risks; how to revert -->

### 后续 / Follow-ups
- <!-- 更多规则增强或文档补充 / Future improvements or docs -->

### Checklist
- [ ] 规则文档已更新 / Rule docs updated
- [ ] 无破坏性更改或已提供迁移 / No breaking changes or migration provided
- [ ] 在干净环境验证通过 / Validated from clean workspace
