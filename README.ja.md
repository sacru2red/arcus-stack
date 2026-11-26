# 🏹 ARCUS-STACK (`arcus-stack`)

<p align="center">
  <a href="./README.md">English</a> |
  <a href="./README.ko.md">한국어</a> |
  <strong>日本語</strong> |
  <a href="./README.zh-CN.md">简体中文</a> |
  <a href="./README.es.md">Español</a>
</p>

> **A**gent **R**ules, **C**ommands & **U**niversal **S**kills  
> *(**SACRU**のアナグラム — 5つのコーディングエージェント対応の汎用スキル＆ワークフロースタック)*

**`arcus-stack`** は、**`Antigravity` (`agy`)、`Claude Code`、`Codex`、`Cursor`、`OpenCode`** の5つのAIコーディングエージェントすべてでそのまま動作する汎用スキル＆ワークフロースタックです。

---

## 💡 なぜ作ったのか？

**T3 Code** や **Orca** のようなマルチエージェント環境で開発していると、タスクに応じて複数のエージェント（`agy`、`Claude Code`、`Codex`、`Cursor`、`OpenCode`）を切り替えたり並列に呼び出したりします。しかし、ツールごとにスキルの配置パスやフロントマターの仕様が異なるため、**「あるエージェントで愛用しているスキルを、別のエージェントを呼び出したときにそのまま使えない」** という大きな不便さがありました。

**`arcus-stack` はこの分断を解消するために作られました。** 重いMCPサーバーへの依存を持たず、5つのツールすべてが共通して認識できる標準の `SKILL.md` と `AGENTS.md` 仕様のみで構成されているため、どの環境からどのエージェントを呼び出しても全く同じスキルと原則で作業できます。

以下の6つのオープンソースプロジェクトのコア思想を1つに統合しています：
- **[`pstack`](https://github.com/cursor/plugins/tree/main/pstack)**: *「速く進みたいなら、まず深く潜れ」*（根本原因の特定、変更範囲の最小化、検証可能なコード）
- **[`oh-my-openagent`](https://github.com/code-yeongyu/oh-my-openagent)**: 完了まで自律的に走り切る `ultrawork` ループと戦略・実行の分離
- **[`oh-my-claudecode`](https://github.com/yeachan-heo/oh-my-claudecode)**: 設計・実装・検証の役割分担とオートパイロット実行
- **[`oh-my-antigravity`](https://github.com/Joonghyun-Lee-Frieren/oh-my-antigravity)**: 段階的な品質ガードレールと実際の実行結果（証拠）に基づく完了検証
- **[`GoogleChrome/modern-web-guidance`](https://github.com/GoogleChrome/modern-web-guidance)**: HTML、CSS、クライアントJS作業時に最新のWeb標準ベストプラクティスを動的に照会（`npx -y modern-web-guidance@latest`）する仕組み（Apache-2.0）
- **[`tt-a1i/archify`](https://github.com/tt-a1i/archify)**: アーキテクチャ、ワークフロー、シーケンス、ERDなど10種類のインタラクティブHTML/SVGダイアグラムと1ページExplainer生成エンジン（可視化リクエスト時に最優先で検討、Apache-2.0）

さらに、`arcus-stack` を使うべき理由はエージェント間の互換性だけではありません。従来のAIコーディングが抱える2つの構造的な死角を解決します：

### 1. 思い込みに騙されないコンテキスト隔離レビューと指摘台帳（`arcus-review`）

設計や実装を行った同じセッションでレビューまで行うと、前提を選んだ経緯や捨てた代替案のバイアスをそのまま引き継いでしまいます。**文脈を共有するレビュアーは死角も共有します。** `arcus-review` はこれを防ぐため、**コンテキスト隔離** と **指摘台帳（Review Ledger）** を導入しています：

- **実装コンテキストから隔離されたレビュー**: 対象コミットやスナップショットを固定し、作成者の対話履歴に汚染されていない新規サブエージェントが設計書とコードをゼロベースで検証します。リポジトリ内にとどまらず外部の公式リファレンスも参照し、前提知識のない読者が設計書だけで理解できるか（コールドリーダーテスト）を試験します。
- **指摘台帳（Review Ledger — `F-01`, `F-02`, ...）**: レビューごとに指摘事項を台帳テーブルで管理し、指摘一覧と作成者の返信セクションを物理的に分離します。
- **コード優先のブラインド判定（2回目以降）**: 2回目以降のレビューでは、新しいコードを見る前、かつ **作成者の返信や釈明を開く前に、まず最新のコード・文書スナップショットだけを見て** 台帳の各指摘が解決されたか（`RESOLVED`）、未解決か（`UNRESOLVED`）、反論が妥当か（`VALID_PUSHBACK`）、見解が分かれるか（`DISPUTED`）を先に判定します：

| ID | 回次 | 固定スナップショット | 重大度 | 対象箇所 | 問題シナリオと必要な修正 | 状態 |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `F-01` | R1 | `4e058ee` | `CRITICAL` | `worker.md:7` | 自律サブエージェント実行中の質問呼び出しによる停止リスク。最上位ターンへの委譲が必要。 | `RESOLVED` |
| `F-02` | R1 | `4e058ee` | `HIGH` | `SKILL.md:44` | 部分インストール時の相対パス参照切れ。フォールバック規則の内蔵。 | `VALID_PUSHBACK` |

*(判定ステータス: `OPEN` · `RESOLVED` · `UNRESOLVED` · `VALID_PUSHBACK` · `DISPUTED`)*

### 2. 最新Web標準とブラウザ互換性の自動適用（`modern-web-guidance`）

AIモデルは学習データの時期の制約により、最新のCSSやWeb標準APIでシンプルに解決できる処理でも古いJSのハックで書いてしまうことがよくあります。`arcus-stack` を使えば、HTML、CSS、クライアントサイドJS（React、Vue、Svelteなどのフレームワーク内を含む）の作業で専用スキルを手動で呼び出したり、毎回 `caniuse.com` でブラウザ対応状況を確認したりする必要はありません。設計（`arcus-plan`）、実装（`arcus-work-loop`）、レビュー（`arcus-review`）の各段階で、内部的に `modern-web-guidance` が自動実行されます：

1. **最新Web標準ガイドのリアルタイム照会**: エージェントの古い学習知識に頼る代わりに、`npx -y modern-web-guidance@latest search "<機能>"` と `retrieve "<ID>"` を自動実行し、Google Chromeチームの最新ガイドラインを参照します。
2. **Baselineとブラウザ対応状況の自動判定**: 取得したガイドには **Web Platform Baseline** のステータスと主要4ブラウザ（Chrome、Edge、Firefox、Safari）の対応バージョンが含まれています。
3. **適切なフォールバックの自動実装**: 広く普及した機能（`Widely available`）は余計なポリフィルなしでシンプルに実装し、一部ブラウザで未対応の最新機能にはガイド推奨の `@supports` やプログレッシブエンハンスメント用フォールバックを自動的に適用します。

---

## 📦 コアスキル (`arcus-*`)

| スキル名 | カテゴリ | メリットと役割 |
| :--- | :--- | :--- |
| ⭐ **`arcus-mode`** | **核心 · マスターモード** | 余計な前置きを省き、簡潔な回答と検証済みのコードだけを得られるようエージェントの基準を引き上げます。状況に応じて24の設計原則、23のプレイブック、サブエージェント委譲ルールを自動適用します。 |
| ⭐ **`arcus-plan`** | **核心 · 設計・チェックリスト** | いきなりコードを書き始めて手戻りしたり要件が漏れたりするのを防ぎます。実装前に根本原因と影響範囲を特定し、現在のタスク目標に合わせた実行・検証チェックリスト（`- [ ]`）を作成します。 |
| ⭐ **`arcus-work-loop`** | **核心 · 自律実行ループ** | 途中で止まったり未完成のコードを残したりせず、タスクを最後まで完遂します。チェックリストを1項目ずつ実行し、実際のテスト・ビルド検証を通過した項目のみを完了（`- [x]`）に更新しながら反復実行します。 |
| ⭐ **`arcus-review`** | **核心 · 隔離された計画・コードレビュー** | 作成者の文脈や思い込みを引き継がないよう、隔離されたサブエージェント上で固定スナップショットを基準に設計とコードを検証します。前提知識なしでの文書理解度テスト、外部仕様との照合、指摘台帳に基づくコード優先の判定を行います。 |
| ⭐ **`arcus-explain`** | **核心 · 目標すり合わせ＆CS卒業生目線の解説** | 要件、設計計画、完了したコード変更、複雑な概念を**20代の情報系・CS学部卒業生（ジュニアエンジニア）に説明する明快なトーン**で解説します（幼稚な比喩や曖昧な美辞麗句を排し、CSのメンタルモデル・仕組み・トレードオフで翻訳）。`arcus-plan`、`arcus-work-loop`、`arcus-mode` の完了直後に自動で要点ブリーフィングを提供します。 |
| **`arcus-ui-propose`** | UI 4枚スクリーンショット比較提案 | UI作業でエージェントが勝手に1つのデザインに決め打ちして書き換えるのを防ぎます。現在の作業ブランチ上で **作業前（Before）のスクリーンショット1枚** と **異なる3つの提案（Option A, B, C）のスクリーンショット** を「順次適用 ➔ 撮影 ➔ パッチ（`.patch`）保存 ➔ `git checkout` 復元」の手順で安全に取得して比較提示し、ユーザーが選んだ案だけを即座に再適用します。 |
| **`arcus-create-verification`** | アプリ検証スキル作成 | 変更のたびに人間が手動でアプリを起動して動作確認する手間を省きます。実際のユーザーのようにアプリを操作して動作証拠を残すプロジェクト専用の検証スキル（`verify-<app>`）を作成・実証します。 |
| **`arcus-maintain-verification`** | アプリ検証スキル保守 | コード変更に伴って既存の検証手順が古くなり動かなくなる問題を防ぎます。最新のソースコードと実際のアプリの挙動を照合し、検証スキルと機能一覧を最新の状態に保ちます。 |
| **`arcus-ketchup`** | 進捗サマリー | 長いチャット履歴を読み返さなくても、今自分が何を判断すべきか一目で把握できます。最後のメッセージ以降の変更点とユーザーの判断待ち項目を平易な言葉と図解で要約します。 |
| **`arcus-why`** | 変更履歴の追跡 | 既存のコードがなぜそのように書かれたのか推測して迷う時間を節約します。現在のコードだけで憶測せず、`DECISIONS.md` やGitのコミット履歴、PRの議論を辿って当時の設計理由とトレードオフを根拠付きで回答します。 |
| **`arcus-correct`** | 繰り返しミス防止・ルール整理 | エージェントに同じ指摘を繰り返す徒労感をなくし、ルールファイルの肥大化を防ぎます。繰り返し違反されるルールは構造・型・Lint・テストで強制し、使われないルールや自明なルール、陳腐化しやすいAPIの事実記述を整理します。 |
| **`arcus-automate-me`** | 個人スタイルの学習 | 新しいセッションのたびに自分のコーディングの好みや回答スタイルを説明し直す必要がなくなります。最近の対話履歴の分析と簡単な選択式の質問を通じて、自分専用の `*-mode` スキルを作成・更新します。 |
| **`arcus-onboard`** | ドメイン・地雷原オンボーディング | エージェントがドメイン仕様を推測して実装したり、触れてはいけないレガシー領域を壊したりする事故を防ぎます。スキーマやルーターを自動走査した上で要点をヒアリングし、1〜2ページの `ONBOARDING.md`（システム境界、ドメイン用語とコード/DB識別子の対応、ビジネス計算式・不変条件、認可・プラン制限、レガシー地雷原、信頼できるデータ原典、エラー・文体規約）を日付・出典タグ（`[as of YYYY-MM-DD \| Source: ...]`）付きで構築・維持します。 |
| **`arcus-skill-maker`** | スキル変換・作成 | 特定のツール専用の外部スキルを5つのエージェントすべてで使えるようにします。外部のスキルやプロンプトを解析し、全エージェント互換の `arcus-*` 形式に変換します。 |

---

## 🎯 使い方ガイド：`arcus-mode` と `arcus-work-loop` の違い＆推奨ワークフロー

### 1. `arcus-mode` と `arcus-work-loop` の違いは？

| 比較項目 | 👑 **`arcus-mode`（マスター動作モード / OS）** | 🔄 **`arcus-work-loop`（チェックリスト実行エンジン）** |
| :--- | :--- | :--- |
| **役割** | セッション全体の設計判断基準、簡潔な文体、サブエージェント委譲を統括する上位オペレーティングモードです。 | 確定したチェックリスト（`- [ ]`）を受け取り、**実装 ➔ テスト検証 ➔ 修正 ➔ 完了（`[x]`）** を全項目クリアまで反復する実行特化エンジンです。 |
| **適用範囲** | 広範：24の設計原則と23のプレイブック（調査、バグ修正、リファクタリング、設計比較、PR管理など）から状況に合う手順を自動選択します。 | 集中：`arcus-plan` で作成したチェックリストを引き継ぎ、実際のビルド・テスト証拠が確認できた項目のみを `- [x]` に更新しながら最後まで完走します。 |
| **使い分け** | セッション開始時にシニアエンジニア基準の規律を適用したいとき、または調査・設計・性能改善など複合的な判断が必要なとき。 | `$arcus-plan` で計画とチェックリストが固まった後、途中で止まらず最後まで実装と検証をやり切らせたいとき。 |

### 2. 推奨ステップバイステップ・パイプライン

1. **設計とチェックリスト作成 (`$arcus-plan`)**: 実装前に根本原因と影響範囲を特定して検証条件付きのチェックリスト（`- [ ]`）を作成し、完了直後に **`arcus-explain`**（20代CS卒業生目線のメンタルモデル＆トレードオフ解説）で設計の要点をブリーフィングします。
2. **隔離された計画クリティカルレビュー (`$arcus-review`)**: 作成者のバイアスを持たない隔離サブエージェントで計画の前提や抜け漏れを事前監査します。
3. **チェックリスト自律実行 (`$arcus-work-loop`)**: 承認されたチェックリストを1項目ずつ実装・検証してすべて `- [x]` になるまで完遂し、最後に **`arcus-explain`** で変更の仕組みをブリーフィングします。
4. **最終コードレビューと意思決定記録 (`$arcus-review` / `DECISIONS.md`)**: 指摘台帳（Review Ledger）に基づいて変更差分を隔離レビューします。重要な設計判断やルール昇格（`$arcus-correct`）があった場合は、ユーザーの明示的な認可を得て `DECISIONS.md` に記録するか、不要な場合はプロジェクト単位のオプトアウト設定（`.git/config`、`AGENTS.md`、`.agents/settings.json`）を記憶します。

---

## 🏗️ アーキテクチャ：2階層スキルカプセル化構造

数十個の細かいスキルを最上位の `skills/` フォルダにそのまま並べると、スラッシュコマンド（`/`）の候補が溢れかえり、コンテキストも圧迫します。`arcus-stack` はこれを **2階層カプセル化構造** で解決しています。

1. **ユーザー呼び出し用コアスキル（14種）**: `skills/arcus-*/SKILL.md` に配置。メニューにはこの14個の主要スキルだけがすっきり表示されます。
2. **内部カプセル化モジュール（60ファイル以上）**: `skills/arcus-mode/` 配下（`principles/`、`playbooks/`、`internal/`、`references/`）に格納。各エージェントのスキルスキャナーは `skills/` の直下1階層のみを登録するため、24の原則、23のプレイブック、19の内部補助スキル（`unslop`、`bro`、`architect`、`swarm`、`arena`、`interrogate`、`checklist`、`decisions`、`modern-web-guidance`、`archify-visualization`、`typescript-best-practices` など）はメニューを汚さず、エージェントが必要に応じて相対リンク経由で読み込みます。

---

## 🚀 インストールとアップデート方法

### 方法 1. `npx skills` CLI を使う（推奨 — グローバルまたはプロジェクト単位）

```bash
# PC内の5つのエージェントすべてにグローバルインストール
npx skills add sacru2red/arcus-stack -g -y

# 現在のプロジェクトに必要なスキルだけを選択してインストール
npx skills add sacru2red/arcus-stack --skill arcus-mode --skill arcus-plan --skill arcus-work-loop
```

#### 🔄 `npx skills` でのアップデート
新しいスキルが追加されたり更新されたりした場合は、同じコマンドを再実行（または `npx skills update`）するだけで最新版に更新されます：
```bash
npx skills add sacru2red/arcus-stack -g -y
# または
npx skills update
```

> **名前が変更・削除されたスキルの整理について:** `npx skills` の `add`/`update` は、リポジトリ側で名前が変わったり削除されたりした旧スキル（例：`arcus-work` → `arcus-work-loop`、`arcus-in-your-own-words` → `arcus-explain`）を自動では削除しません。アップデート後に旧スキルが残っている場合は、以下のコマンドで削除してください：
> ```bash
> npx skills remove arcus-work arcus-in-your-own-words -g -y
> ```

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

リポジトリをローカルにクローンしてスクリプトを実行すると、5つのエージェントのグローバルスキルパス（T3 Code内のAntigravity環境を含む）へ即座にリンクされます。

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

---

## 🗂️ ディレクトリ構造

```text
arcus-stack/
├── README.md                    # 英語メインドキュメント (English)
├── README.ko.md                 # 韓国語ドキュメント (Korean)
├── README.ja.md                 # 日本語ドキュメント (Japanese)
├── README.zh-CN.md              # 中国語（簡体字）ドキュメント (Simplified Chinese)
├── README.es.md                 # スペイン語ドキュメント (Spanish)
├── DECISIONS.md                 # アーキテクチャ意思決定記録 (D-001..D-011)
├── plugin.json                  # Antigravity (agy) プラグインマニフェスト
├── .claude-plugin/
│   └── plugin.json              # Claude Code プラグインマニフェスト
├── .agents/
│   └── skills.json              # ワークスペーススキル検出マニフェスト
├── AGENTS.md                    # ルートルールブリッジ
├── CLAUDE.md                    # Claude Code ルールブリッジ
├── rules/
│   └── AGENTS.md                # 5つのエージェント共通のコアエンジニアリング原則
├── scripts/
│   ├── install-global.ps1       # Windows用グローバルシンボリックリンクインストーラー (5エージェント + T3 Code)
│   └── install-global.sh        # macOS/Linux用グローバルシンボリックリンクインストーラー (5エージェント + T3 Code)
└── skills/                      # ⭐ ユーザー呼び出し用 14個のコアスキル
    ├── arcus-mode/              # マスターモード + 内部カプセル化モジュール
    │   ├── SKILL.md
    │   ├── worker.md
    │   ├── playbooks/           # [内部専用] 23のタスクプレイブック
    │   ├── principles/          # [内部専用] 24の設計原則
    │   ├── internal/            # [内部専用] 19の補助スキル (unslop, bro, modern-web-guidance, archify-visualization, typescript-best-practices など)
    │   └── references/          # [内部専用] bugbot-triage.md
    ├── arcus-plan/
    ├── arcus-work-loop/
    ├── arcus-review/
    ├── arcus-explain/
    ├── arcus-ui-propose/
    ├── arcus-create-verification/
    ├── arcus-maintain-verification/
    ├── arcus-ketchup/
    ├── arcus-why/
    ├── arcus-correct/
    ├── arcus-automate-me/
    ├── arcus-onboard/
    └── arcus-skill-maker/
```
