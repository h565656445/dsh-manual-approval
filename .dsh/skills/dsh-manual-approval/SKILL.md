---
name: dsh-manual-approval
description: 人工审批幂等消费与预算校验技能 / Skill for idempotent manual-approval consumption and budget checks
---

# Hermes 人工审批 / Hermes Manual Approval

本技能用于人工审批消费：以审批哈希为幂等键做一次性消费记录，拒绝负预算与重复消费。

This skill covers manual-approval consumption: one-shot consumption keyed by the approval hash, rejecting negative budgets and re-consumption.

## When to use / 何时使用

受监督 Worker 需要人工放行并记录审批消费时。

Use when a supervised worker needs manual release and approval-consumption evidence.

## Workflow / 工作流

1. 确认审批哈希与预算。
2. 调用 Use-HermesManualStartApproval。
3. 核对消费记录与 token。

## References / 参考

- 项目 README: 见仓库根目录
- 作者: h565656445 (GitHub)