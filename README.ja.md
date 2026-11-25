# 🏹 ARCUS-STACK (`arcus-stack`)

<p align="center">
  <a href="./README.md">English</a> |
  <a href="./README.ko.md">한국어</a> |
  <strong>日本語</strong> |
  <a href="./README.zh-CN.md">简体中文</a> |
  <a href="./README.es.md">Español</a>
</p>

> **A**gent **R**ules, **C**ommands & **U**niversal **S**kills  
> *(**SACRU**のアナグラム — 5大コーディングエージェント対応の汎用スキル＆ワークフロースタック)*

**`arcus-stack`** は、**Antigravity (`agy`)、Claude Code、Codex、Cursor、OpenCode** の5大AIコーディングエージェントすべてでそのまま動作する汎用スキル＆ワークフロースタックです。

---

## 💡 なぜ作ったのか？

**T3 Code** や **Orca** のようなマルチエージェント環境で開発していると、タスクに応じて複数のエージェント（`agy`、Claude Code、Codex、Cursor、OpenCode）を切り替えたり並列に呼び出したりします。しかし、ツールごとにスキルの配置パスやフロントマターの仕様が異なるため、**「あるエージェントで愛用しているスキルを、別のエージェントを呼び出したときにそのまま使えない」** という大きな不便さがありました。

**`arcus-stack` はこの分断を解消するために作られました。** 重いMCPサーバーへの依存を持たず、5つのツールすべてが共通して認識できる標準の `SKILL.md` と `AGENTS.md` 仕様のみで構成されているため、どの環境からどのエージェントを呼び出しても全く同じスキルと原則で作業できます。

以下の4つのオープンソースプロジェクトの 강み（コア思想）を1つに統合しています：
- **[`pstack`](https://github.com/cursor/plugins/tree/main/pstack)**: *「速く進みたいなら、まず深く潜れ」*（根本原因の特定、変更範囲の最小化、検証可能なコード）
- **[`oh-my-openagent`](https://github.com/code-yeongyu/oh-my-openagent)**: 完了まで自律的に走り切る `ultrawork` ループと戦略・実行の分離
- **[`oh-my-claudecode`](https://github.com/yeachan-heo/oh-my-claudecode)**: 設計・実装・検証の役割分担とオートパイロット実行
- **[`oh-my-antigravity`](https://github.com/Joonghyun-Lee-Frieren/oh-my-antigravity)**: 段階的な品質ガードレールと実際の実行結果（証拠）に基づく完了検証

---

## 📦 コアスキル (`arcus-*`)

| スキル名 | カテゴリ | メリットと役割 |
| :--- | :--- | :--- |
| **`arcus-mode`** | マスターモード | 余計な前置きを省き、簡潔な回答と検証済みのコードだけを得られるようエージェントの基準を引き上げます。状況に応じて24の設計原則、22のプレイブック、サブエージェント委譲ルールを自動適用します。 |
| **`arcus-plan`** | 設計・計画 | いきなりコードを書き始めて手戻りするのを防ぎます。実装前に問題の根本原因と影響範囲を特定し、段階的な実装手順と検証計画を立てます。 |
| **`arcus-work`** | 自律実行 | 途中で止まったり未完成のコードを残したりせず、タスクを最後まで完遂します。調査から実装、自己診断、テスト・ビルド検証まで完了条件を満たすまで自律的に繰り返します。 |
| **`arcus-review`** | コードレビュー | 表面的なエラーだけを隠すその場しのぎの修正を見抜き、リリース後の障害を防ぎます。根本原因が解決されているか、境界違反や見落とした例外がないか、テスト証拠があるかを厳しく点検します。 |
| **`arcus-in-your-own-words`** | 目標のすり合わせ | エージェントが意図を誤解したまま見当違いのコードを書く時間浪費を減らします。作業に入る前に、ユーザーの目標と解決すべき課題をエージェント自身の言葉で要約して確認します。 |
| **`arcus-create-verification`** | アプリ検証スキル作成 | 変更のたびに人間が手動でアプリを起動して動作確認する手間を省きます。実際のユーザーのようにアプリを操作して動作証拠を残すプロジェクト専用の検証スキル（`verify-<app>`）を作成・実証します。 |
| **`arcus-maintain-verification`** | アプリ検証スキル保守 | コード変更に伴って既存の検証手順が古くなり動かなくなる問題を防ぎます。最新のソースコードと実際のアプリの挙動を照合し、検証スキルと機能一覧を最新の状態に保ちます。 |
| **`arcus-ketchup`** | 進捗サマリー | 長いチャット履歴を読み返さなくても、今自分が何を判断すべきか一目で把握できます。最後のメッセージ以降の変更点とユーザーの判断待ち項目を平易な言葉と図解で要約します。 |
| **`arcus-why`** | 変更履歴の追跡 | 既存のコードがなぜそのように書かれたのか推測して迷う時間を節約します。現在のコードだけで憶測せず、Gitのコミット履歴やPRの議論を辿って当時の設計理由とトレードオフを根拠付きで回答します。 |
| **`arcus-correct`** | 繰り返しミスの防止 | エージェントに同じ指摘を何度も繰り返す徒労感をなくします。頻発するミスを単なるドキュメントの注意書きではなく、アーキテクチャ、型、Lintルール、テストによって構造的に起こせないようにします。 |
| **`arcus-automate-me`** | 個人スタイルの学習 | 新しいセッションのたびに自分のコーディングの好みや回答スタイルを説明し直す必要がなくなります。最近の対話履歴の分析と簡単な選択式の質問を通じて、自分専用の `*-mode` スキルを作成・更新します。 |
| **`arcus-skill-maker`** | スキル変換・作成 | 特定のツール専用の外部スキルを5つのエージェントすべてで使えるようにします。外部のスキルやプロンプトを解析し、全エージェント互換の `arcus-*` 形式に変換します。 |

---

## 🏗️ アーキテクチャ：2階層スキルカプセル化構造

数十個の細かいスキルを最上位の `skills/` フォルダにそのまま並べると、スラッシュコマンド（`/`）の候補が溢れかえり、コンテキストも圧迫します。`arcus-stack` はこれを **2階層カプセル化構造** で解決しています。

1. **ユーザー呼び出し用コアスキル（12種）**: `skills/arcus-*/SKILL.md` に配置。メニューにはこの12個の主要スキルだけがすっきり表示されます。
2. **内部カプセル化モジュール（60ファイル以上）**: `skills/arcus-mode/` 配下（`principles/`、`playbooks/`、`internal/`、`references/`）に格納。各エージェントのスキルスキャナーは `skills/` の直下1階層のみを登録するため、24の原則、22のプレイブック、14の内部補助スキル（`unslop`、`bro`、`architect`、`swarm`、`arena`、`interrogate` など）はメニューを汚さず、エージェントが必要に応じて相対リンク経由で読み込みます。

---

## 🚀 インストールとアップデート方法

### 方法 1. `npx skills` CLI を使う（推奨 — グローバルまたはプロジェクト単位）

```bash
# PC内の5つのエージェントすべてにグローバルインストール
npx skills add sacru2red/arcus-stack -g -y

# 現在のプロジェクトに必要なスキルだけを選択してインストール
npx skills add sacru2red/arcus-stack --skill arcus-mode --skill arcus-plan --skill arcus-work
```

#### 🔄 `npx skills` でのアップデート
新しいスキルが追加されたり更新されたりした場合は、同じコマンドを再実行（または `npx skills update`）するだけで最新版に更新されます：
```bash
npx skills add sacru2red/arcus-stack -g -y
# または
npx skills update
```

### 方法 2. 各エージェントのネイティブプラグインマネージャーを使う

- **Antigravity (`agy`)**:
  ```bash
  # インストールおよびアップデート
  agy plugin install https://github.com/sacru2red/arcus-stack
  ```
- **Claude Code**:
  ```bash
  # インストール
  /plugin marketplace add https://github.com/sacru2red/arcus-stack
  /plugin install arcus-stack

  # アップデート
  /plugin update arcus-stack
  ```

### 方法 3. ローカルクローン + シンボリックリンク (`scripts/install-global.ps1` / `.sh`)

リポジトリをローカルにクローンしてスクリプトを実行すると、5大エージェントのグローバルスキルパス（T3 Code内のAntigravity環境を含む）へ即座にリンクされます。

```powershell
# Windows (PowerShell)
.\scripts\install-global.ps1
```

```bash
# macOS / Linux
./scripts/install-global.sh
```

#### 🔄 ローカルクローンでのアップデート
シンボリックリンクがローカルリポジトリを直接指しているため、`git pull` するだけで全エージェントに即時反映されます（新しいスキルフォルダが追加された場合のみスクリプトを再実行してください）：
```bash
git pull && ./scripts/install-global.sh   # (Windowsは .\scripts\install-global.ps1)
```
