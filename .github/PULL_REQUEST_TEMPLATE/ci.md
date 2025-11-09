## CI 改动 / Continuous Integration Changes

### 概述 / Summary
<!-- 描述新增/修改的工作流、触发条件、缓存策略 / Describe workflows, triggers, caching -->

### 动机 / Motivation
<!-- 为什么需要这些 CI 变更 / Why these CI changes are needed -->

### 工作流详情 / Workflow Details
- <!-- 新增文件列表与用途 / New workflow files & purposes -->
- <!-- 触发条件 (push/pr/dispatch/schedule) / Triggers -->

### 资源与性能 / Resources & Performance
- <!-- 运行时长、并发、是否需要自托管 runner / Duration, concurrency, self-hosted requirement -->

### 安全 / Security
- <!-- 机密、权限、action 版本锁定 / Secrets, permissions, action version pinning -->

### 验证 / Validation
```bash
# 可选本地复现（如 act 工具） / Optional local reproduction (e.g. act)
# act pull_request -W .github/workflows/xxx.yml
```

### 回滚策略 / Rollback Strategy
<!-- 如果新工作流导致失败如何临时禁用或回滚 / How to disable or revert -->

### 后续 / Follow-ups
- <!-- 计划添加的缓存/矩阵/测试分层 / Future caching/matrix/test tiers -->

### Checklist
- [ ] 工作流文件语法正确 / Workflow syntax valid
- [ ] Action 版本固定 / Actions version pinned
- [ ] 无多余权限 / Minimal permissions
- [ ] 文档或 README 引用已更新 / Docs/README references updated
