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

本项目融合了以下五个开源项目的核心优势：
- **[`pstack`](https://github.com/cursor/plugins/tree/main/pstack)**：*“欲速则先深潜”*（深挖根本原因、最小化改动范围、编写可验证的代码）
- **[`oh-my-openagent`](https://github.com/code-yeongyu/oh-my-openagent)**：自主循环直至任务彻底完成的 `ultrawork` 模式与策略/执行分离
- **[`oh-my-claudecode`](https://github.com/yeachan-heo/oh-my-claudecode)**：规划、实现、审查角色分工与自动化工作流
- **[`oh-my-antigravity`](https://github.com/Joonghyun-Lee-Frieren/oh-my-antigravity)**：分阶段质量护栏与基于真实运行证据的完成校验
- **[`GoogleChrome/modern-web-guidance`](https://github.com/GoogleChrome/modern-web-guidance)**：在编写 HTML、CSS 与客户端 JS 时实时检索最新现代 Web 标准指南（`npx -y modern-web-guidance@latest`，Apache-2.0）

除了跨工具兼容之外，使用 `arcus-stack` 的核心理由在于它从架构上解决了传统单会话 AI 编程的两大痛点：

### 1. 摆脱自身偏见的上下文隔离审查与问题台账（`arcus-review`）

如果在完成设计或编写代码的同一个会话中进行审查，审查者会完全继承原有的决策路径与思维盲区——**共享上下文的审查者也会共享盲区。** `arcus-review` 通过 **上下文隔离** 与 **问题台账（Review Ledger）** 解决这一问题：

- **脱离实现上下文的隔离沙箱**：锁定待审查的提交或快照后，由不携带作者聊天记录的新子智能体从零审视设计文档与代码。不仅局限于仓库内部，还会主动查阅外部参考资料，并通过“冷读者测试”检验不了解背景的读者能否仅凭文档看懂设计。
- **持久化问题台账（Review Ledger — `F-01`, `F-02`, ...）**：每次审查都会维护结构化的问题台账表格，并将问题列表与作者的回复说明在结构上物理分离。
- **“先看代码、后看回复”的盲评机制（第 2 轮起）**：在后续轮次的审查中，审查者在浏览新改动或 **打开作者的回复解释之前，必须先仅凭最新代码/文档快照** 对台账中的遗留问题逐一作出裁定（已解决 `RESOLVED`、未解决 `UNRESOLVED`、反驳合理 `VALID_PUSHBACK` 或存在分歧 `DISPUTED`）：

| ID | 轮次 | 锁定快照 | 严重度 | 目标位置 | 故障场景与修复要求 | 状态 |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `F-01` | R1 | `4e058ee` | `CRITICAL` | `worker.md:7` | 自主子智能体运行中途弹窗提问会导致流程挂起，需移交顶层交互回合。 | `RESOLVED` |
| `F-02` | R1 | `4e058ee` | `HIGH` | `SKILL.md:44` | 部分安装时跨目录相对路径可能失效，需内联兜底规则。 | `VALID_PUSHBACK` |

*(裁定状态: `OPEN` · `RESOLVED` · `UNRESOLVED` · `VALID_PUSHBACK` · `DISPUTED`)*

### 2. 突破过时训练数据的现代 Web 标准与浏览器兼容性自动应用（`modern-web-guidance`）

受限于训练数据截止时间，AI 模型经常会用过时的 JS 补丁去实现早已被现代 CSS 或 Web 标准原生支持的功能。使用 `arcus-stack` 开发 HTML、CSS 或客户端 JS（包括 React、Vue、Svelte 等框架内部）时，你无需手动调用额外技能，也不必每次去 `caniuse.com` 查阅浏览器支持率。在规划（`arcus-plan`）、实现（`arcus-work-loop`）和审查（`arcus-review`）阶段，系统会在底层自动触发 `modern-web-guidance`：

1. **实时检索官方最新指南**：助手不会依赖模型训练权重中过时的旧写法，而是在动手前自动调用 `npx -y modern-web-guidance@latest search "<功能>"` 与 `retrieve "<ID>"`，获取 Google Chrome 团队维护的最新 Web 最佳实践。
2. **内置 Baseline 与浏览器兼容性判定**：检索出的每篇指南均附带 **Web Platform Baseline** 等级以及四大主流浏览器（Chrome、Edge、Firefox、Safari）的具体支持版本。
3. **自动编写降级与兜底代码（Fallback）**：对已广泛支持（`Widely available`）的特性直接采用原生简洁写法；对部分浏览器尚未支持的新特性，则严格按照指南自动补齐 `@supports` 或渐进增强兜底代码。

---

## 📦 核心技能 (`arcus-*`)

| 技能名称 | 类别 | 核心收益与功能说明 |
| :--- | :--- | :--- |
| **`arcus-mode`** | 主控模式 | 去除客套废话，直接获得简洁回答与经过验证的代码，全面提升助手的默认工程水准。根据任务自动应用 24 条工程原则、22 个任务剧本以及子智能体委派规范。 |
| **`arcus-plan`** | 规划与检查清单 | 避免一上来就改代码导致方向跑偏或遗漏需求。在写代码前先定位根本原因与改动影响范围，并围绕当前任务目标生成可逐项追踪的执行与验证检查清单（`- [ ]`）。 |
| **`arcus-work-loop`** | 自主执行循环 | 杜绝半途而废或留下未完成的占位代码，将任务一气呵成执行到底。按任务检查清单逐项推进，仅在真实测试与构建验证通过后才将条目勾选为完成（`- [x]`）。 |
| **`arcus-review`** | 上下文隔离的计划与代码审查 | 在不继承作者上下文与盲区的隔离子智能体中，基于固定快照审查设计方案与代码。涵盖无背景读者的文档可理解性测试、外部参考资料核对，以及基于问题台账的“先看代码、后看回复”多轮评审机制。 |
| **`arcus-in-your-own-words`** | 目标对齐 | 避免助手理解偏差写出南辕北辙的代码而浪费时间。在动手之前，让助手用自己的话复述你的目标与核心问题以确认理解一致。 |
| **`arcus-create-verification`** | 生成应用验证技能 | 免去每次改动后人工启动应用逐一点选测试的繁琐工作。自动生成并实测一个像真实用户一样启动并操作应用的项目专属验证技能（`verify-<app>`）。 |
| **`arcus-maintain-verification`** | 维护应用验证技能 | 防止业务代码更新后原有的验证流程过期失效。对比最新源码与真实运行表现，自动校准并更新项目的验证技能与功能清单。 |
| **`arcus-ketchup`** | 进度简报 | 无需从头翻阅冗长的聊天记录，一眼看清当前进展以及需要你拍板的事项。用大白话、流程图和带推荐理由的待决策清单总结你上一条消息以来的所有变化。 |
| **`arcus-why`** | 历史变更溯源 | 省去对着现有代码盲目猜测“当时为什么这么写”的时间。通过追溯 `DECISIONS.md`、Git 提交记录与 PR 讨论，有理有据地还原当初的设计考量与权衡。 |
| **`arcus-correct`** | 杜绝重复犯错与规则瘦身 | 摆脱反复纠正同一个错误的疲劳感，同时防止规则文件臃肿浪费 Token。将反复违反的规则升级为架构、类型、Lint 或测试约束，并清理从未读取、无需提醒的常识规则以及易过时的 API 事实断言。 |
| **`arcus-automate-me`** | 个人风格定制 | 不用在每次新建会话时重新解释你的代码偏好与回复风格。通过分析近期对话记录并进行简短的多选访谈，为你生成或更新专属的 `*-mode` 技能。 |
| **`arcus-onboard`** | 工程领域与雷区地图 | 防止助手靠猜测编写业务逻辑或误触不可修改的遗留代码雷区。先扫描数据库Schema与路由再针对盲区提问，生成 1–2 页的 `ONBOARDING.md`（涵盖系统边界、业务术语 ↔ 代码/DB 标识符映射、核心业务计算公式与不变量、权限与套餐门槛、遗留代码雷区与安全红线、权威数据源、错误响应与文风规范），并附带日期与代码来源标签（`[as of YYYY-MM-DD \| Source: ...]`）。 |
| **`arcus-skill-maker`** | 技能转换与制作 | 让原本只能在单一工具中使用的外部技能在五大助手中通用。分析外部技能或提示词，将其转换为跨工具兼容的 `arcus-*` 标准技能。 |

---

## 🎯 使用指南：`arcus-mode` 与 `arcus-work-loop` 的区别及推荐工作流

### 1. `arcus-mode` 与 `arcus-work-loop` 有什么区别？

| 对比维度 | 👑 **`arcus-mode`（主控操作系统模式 / OS）** | 🔄 **`arcus-work-loop`（检查清单执行引擎）** |
| :--- | :--- | :--- |
| **核心定位** | 统管整个会话的工程判断准则、精炼文风与子智能体协同的顶层主控模式。 | 围绕既定任务检查清单（`- [ ]`），专注循环执行 **实现 ➔ 验证 ➔ 修复 ➔ 勾选完成（`[x]`）** 的执行引擎。 |
| **覆盖范围** | 全局：根据场景从 24 条工程原则和 22 个任务剧本（根因调查、重构、方案竞技、性能调优、PR 照看等）中自动匹配最佳流程。 | 聚焦：接管 `arcus-plan` 生成的检查清单，逐项编写代码并运行真实测试/构建，仅在验证通过后勾选 `- [x]` 直至全部完成。 |
| **何时调用** | 会话刚开始希望开启高级工程师准则时，或面对需要深入调研、架构权衡与多智能体协作的复杂任务时。 | 在 `$arcus-plan` 确定好方案与检查清单后，希望助手不要中途停顿、一气呵成跑完所有实现与验证时。 |

### 2. 推荐分步流水线

1. **规划与生成检查清单 (`$arcus-plan`)**：动手写代码前先定位根本原因与影响范围，生成带验证条件的检查清单（`- [ ]`）。
2. **上下文隔离的方案评审 (`$arcus-review`)**：启动无历史偏见的隔离子智能体对方案进行冷读者测试与前提批判。
3. **检查清单自主执行循环 (`$arcus-work-loop`)**：按确认后的清单逐项实现与实测，直到所有条目均被验证勾选为 `- [x]`。
4. **最终代码审查与架构决策记录 (`$arcus-review` / `DECISIONS.md`)**：基于问题台账（Review Ledger）对代码变更进行隔离审查。当产生重要架构取舍或规则升级（`$arcus-correct`）时，会在获得用户明确授权后记录至 `DECISIONS.md`（若用户拒绝，则通过 `.git/config`、`AGENTS.md` 或 `.agents/settings.json` 持久记住不再打扰）。

---

## 🏗️ 架构设计：双层技能封装结构

如果把几十个细粒度技能直接平铺在顶层 `skills/` 目录下，会导致斜杠命令（`/`）列表过度臃肿并占用上下文预算。`arcus-stack` 采用 **双层封装结构** 解决了这一问题：

1. **面向用户的核心技能（13 个）**：位于顶层 `skills/arcus-*/SKILL.md`。你的技能菜单中只会清爽地展示这 13 个高频入口。
2. **内部封装模块（60+ 个文件）**：收纳在 `skills/arcus-mode/` 子目录（`principles/`、`playbooks/`、`internal/`、`references/`）中。由于各助手的技能扫描器仅扫描 `skills/` 下一级目录，24 条工程原则、22 个任务剧本和 17 个内部辅助技能（`unslop`、`bro`、`architect`、`swarm`、`arena`、`interrogate`、`checklist`、`decisions`、`modern-web-guidance` 等）不会污染用户菜单，而是由助手在执行过程中按需通过相对路径读取。

---

## 🚀 安装与更新方法

### 方法 1. 使用 `npx skills` CLI（推荐 — 全局或按项目安装）

```bash
# 在当前电脑的五大助手全局环境中一次性安装所有技能
npx skills add sacru2red/arcus-stack -g -y

# 仅在当前项目中按需安装指定技能
npx skills add sacru2red/arcus-stack --skill arcus-mode --skill arcus-plan --skill arcus-work-loop
```

#### 🔄 使用 `npx skills` 更新至最新版本
当仓库新增或改进了技能时，重新运行安装命令（或运行 `npx skills update`）即可覆盖更新：
```bash
npx skills add sacru2red/arcus-stack -g -y
# 或
npx skills update
```

> **关于重命名或已移除技能的清理说明：** `npx skills` 的 `add`/`update` 不会自动删除仓库中已重命名或移除的旧技能（例如 `arcus-work` 重命名为 `arcus-work-loop`）。如果更新后列表中仍显示旧技能，请运行以下命令将其移除：
> ```bash
> npx skills remove arcus-work -g -y
> ```

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

---

## 🗂️ 目录结构

```text
arcus-stack/
├── README.md                    # 英文主文档 (English)
├── README.ko.md                 # 韩文文档 (Korean)
├── README.ja.md                 # 日文文档 (Japanese)
├── README.zh-CN.md              # 简体中文文档 (Simplified Chinese)
├── README.es.md                 # 西班牙文文档 (Spanish)
├── DECISIONS.md                 # 按需架构决策记录 (D-001..D-008)
├── plugin.json                  # Antigravity (agy) 插件清单
├── .claude-plugin/
│   └── plugin.json              # Claude Code 插件清单
├── .agents/
│   └── skills.json              # 本地工作区技能发现清单
├── AGENTS.md                    # 根目录规则桥接文件
├── CLAUDE.md                    # Claude Code 规则桥接文件
├── rules/
│   └── AGENTS.md                # 五大助手共享的核心工程准则
├── scripts/
│   ├── install-global.ps1       # Windows 全局符号链接安装脚本 (5 大助手 + T3 Code)
│   └── install-global.sh        # macOS/Linux 全局符号链接安装脚本 (5 大助手 + T3 Code)
└── skills/                      # ⭐ 面向用户的 13 个核心技能
    ├── arcus-mode/              # 主控模式 + 内部封装模块
    │   ├── SKILL.md
    │   ├── worker.md
    │   ├── playbooks/           # [内部专用] 22 个任务剧本
    │   ├── principles/          # [内部专用] 24 条工程原则
    │   ├── internal/            # [内部专用] 17 个辅助子技能 (unslop, bro, modern-web-guidance 等)
    │   └── references/          # [内部专用] bugbot-triage.md
    ├── arcus-plan/
    ├── arcus-work-loop/
    ├── arcus-review/
    ├── arcus-in-your-own-words/
    ├── arcus-create-verification/
    ├── arcus-maintain-verification/
    ├── arcus-ketchup/
    ├── arcus-why/
    ├── arcus-correct/
    ├── arcus-automate-me/
    ├── arcus-onboard/
    └── arcus-skill-maker/
```
