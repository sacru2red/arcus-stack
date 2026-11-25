# 🏹 ARCUS-STACK (`arcus-stack`)

<p align="center">
  <a href="./README.md">English</a> |
  <a href="./README.ko.md">한국어</a> |
  <a href="./README.ja.md">日本語</a> |
  <strong>简体中文</strong> |
  <a href="./README.es.md">Español</a>
</p>

> **A**gent **R**ules, **C**ommands & **U**niversal **S**kills  
> *(**SACRU** 的字母异位词 — 兼容五大 AI 编程助手的通用技能与工作流栈)*

**`arcus-stack`** 是一套无需修改即可在 **Antigravity (`agy`)、Claude Code、Codex、Cursor 和 OpenCode** 五大 AI 编程助手中通用的技能与工作流合集。

---

## 💡 为什么要做这个项目？

在 **T3 Code** 或 **Orca** 等多智能体编排环境中开发时，我们经常需要根据任务在不同编程助手（`agy`、Claude Code、Codex、Cursor、OpenCode）之间切换或并行调用。然而，不同工具读取技能的目录结构和配置格式各不相同，**导致在某个工具中顺手的技能无法在调用其他助手时直接复用**，非常不便。

**`arcus-stack` 正是为了解决这种碎片化问题而生。** 它不依赖沉重的 MCP 服务端进程，仅使用五大工具均原生支持的 `SKILL.md` 与 `AGENTS.md` 标准规范，让你无论在哪个环境中调用哪个助手，都能获得完全一致的技能与工程准则。

本项目融合了以下四个开源项目的核心优势：
- **[`pstack`](https://github.com/cursor/plugins/tree/main/pstack)**：*“欲速则先深潜”*（深挖根本原因、最小化改动范围、编写可验证的代码）
- **[`oh-my-openagent`](https://github.com/code-yeongyu/oh-my-openagent)**：自主循环直至任务彻底完成的 `ultrawork` 模式与策略/执行分离
- **[`oh-my-claudecode`](https://github.com/yeachan-heo/oh-my-claudecode)**：规划、实现、审查角色分工与自动化工作流
- **[`oh-my-antigravity`](https://github.com/Joonghyun-Lee-Frieren/oh-my-antigravity)**：分阶段质量护栏与基于真实运行证据的完成校验

---

## 📦 核心技能 (`arcus-*`)

| 技能名称 | 类别 | 核心收益与功能说明 |
| :--- | :--- | :--- |
| **`arcus-mode`** | 主控模式 | 去除客套废话，直接获得简洁回答与经过验证的代码，全面提升助手的默认工程水准。根据任务自动应用 24 条工程原则、22 个任务剧本以及子智能体委派规范。 |
| **`arcus-plan`** | 规划与设计 | 避免一上来就改代码导致方向跑偏和返工。在写代码前先定位根本原因与改动影响范围，输出分步实施与验证计划。 |
| **`arcus-work`** | 自主执行 | 杜绝半途而废或留下未完成的占位代码，将任务一气呵成执行到底。自主循环完成代码探索、实现、自检以及真实测试与构建验证。 |
| **`arcus-review`** | 代码审查 | 拦截掩盖表面报错的临时补丁代码，防止线上隐患。严格检查是否解决了根本原因、是否破坏模块边界、是否遗漏边界情况以及是否具备真实测试证据。 |
| **`arcus-in-your-own-words`** | 目标对齐 | 避免助手理解偏差写出南辕北辙的代码而浪费时间。在动手之前，让助手用自己的话复述你的目标与核心问题以确认理解一致。 |
| **`arcus-create-verification`** | 生成应用验证技能 | 免去每次改动后人工启动应用逐一点选测试的繁琐工作。自动生成并实测一个像真实用户一样启动并操作应用的项目专属验证技能（`verify-<app>`）。 |
| **`arcus-maintain-verification`** | 维护应用验证技能 | 防止业务代码更新后原有的验证流程过期失效。对比最新源码与真实运行表现，自动校准并更新项目的验证技能与功能清单。 |
| **`arcus-ketchup`** | 进度简报 | 无需从头翻阅冗长的聊天记录，一眼看清当前进展以及需要你拍板的事项。用大白话、流程图和带推荐理由的待决策清单总结你上一条消息以来的所有变化。 |
| **`arcus-why`** | 历史变更溯源 | 省去对着现有代码盲目猜测“当时为什么这么写”的时间。通过追溯 Git 提交记录与 PR 讨论，有理有据地还原当初的设计考量与权衡。 |
| **`arcus-correct`** | 杜绝重复犯错 | 摆脱反复向助手纠正同一个错误的疲劳感。找出高频错误模式，优先通过架构约束、类型系统、Lint 报错提示或行为测试从根本上封堵错误，而非仅靠文档口头提醒。 |
| **`arcus-automate-me`** | 个人风格定制 | 不用在每次新建会话时重新解释你的代码偏好与回复风格。通过分析近期对话记录并进行简短的多选访谈，为你生成或更新专属的 `*-mode` 技能。 |
| **`arcus-skill-maker`** | 技能转换与制作 | 让原本只能在单一工具中使用的外部技能在五大助手中通用。分析外部技能或提示词，将其转换为跨工具兼容的 `arcus-*` 标准技能。 |

---

## 🏗️ 架构设计：双层技能封装结构

如果把几十个细粒度技能直接平铺在顶层 `skills/` 目录下，会导致斜杠命令（`/`）列表过度臃肿并占用上下文预算。`arcus-stack` 采用 **双层封装结构** 解决了这一问题：

1. **面向用户的核心技能（12 个）**：位于顶层 `skills/arcus-*/SKILL.md`。你的技能菜单中只会清爽地展示这 12 个高频入口。
2. **内部封装模块（60+ 个文件）**：收纳在 `skills/arcus-mode/` 子目录（`principles/`、`playbooks/`、`internal/`、`references/`）中。由于各助手的技能扫描器仅扫描 `skills/` 下一级目录，24 条工程原则、22 个任务剧本和 14 个内部辅助技能（`unslop`、`bro`、`architect`、`swarm`、`arena`、`interrogate` 等）不会污染用户菜单，而是由助手在执行过程中按需通过相对路径读取。

---

## 🚀 安装与更新方法

### 方法 1. 使用 `npx skills` CLI（推荐 — 全局或按项目安装）

```bash
# 在当前电脑的五大助手全局环境中一次性安装所有技能
npx skills add sacru2red/arcus-stack -g -y

# 仅在当前项目中按需安装指定技能
npx skills add sacru2red/arcus-stack --skill arcus-mode --skill arcus-plan --skill arcus-work
```

#### 🔄 使用 `npx skills` 更新至最新版本
当仓库新增或改进了技能时，重新运行安装命令（或运行 `npx skills update`）即可覆盖更新：
```bash
npx skills add sacru2red/arcus-stack -g -y
# 或
npx skills update
```

### 方法 2. 使用助手自带的插件管理器

- **Antigravity (`agy`)**：
  ```bash
  # 安装及更新（重新执行即可拉取最新更改）
  agy plugin install https://github.com/sacru2red/arcus-stack
  ```
- **Claude Code**：
  ```bash
  # 安装
  /plugin marketplace add https://github.com/sacru2red/arcus-stack
  /plugin install arcus-stack

  # 更新
  /plugin update arcus-stack
  ```

### 方法 3. 本地克隆 + 全局符号链接 (`scripts/install-global.ps1` / `.sh`)

将本仓库克隆到本地并运行脚本，即可将所有技能直接链接到五大助手（包括 T3 Code 内置的 Antigravity 隔离目录）的全局技能路径。

```powershell
# Windows (PowerShell)
.\scripts\install-global.ps1
```

```bash
# macOS / Linux
./scripts/install-global.sh
```

#### 🔄 本地克隆方式如何更新
由于符号链接直接指向本地仓库目录，执行 `git pull` 即可在所有助手中实时生效（仅在新增了顶层技能文件夹时需重新运行一次脚本）：
```bash
git pull && ./scripts/install-global.sh   # (Windows 请运行 .\scripts\install-global.ps1)
```
