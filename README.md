# ReNovo

<p align="center">
  <img src="app/assets/images/ogp.png" alt="ReNovoロゴ" width="480">
</p>

## 概要

ReNovoは、考えすぎて行動に移せない人のためのタスク分解サービスです。

現在の状況・問題・目標を入力すると、AIが5〜15分程度で取り組める5つの具体的なタスクに分解します。

## URL

[https://renovoapp.net](https://renovoapp.net)

## 使い方

### 現在の状況を入力

「現在の状況」「解決したい問題」「達成したい目標」を3ステップで入力し、今の状況を整理します。

<img src="app/assets/images/readme/situation.png" alt="状況整理の入力画面" width="480">

### AIが生成したタスクを編集

入力内容をもとに、AIが5つのタスクを提案します。<br>
生成後は、タスクの追加・編集・削除・並べ替えができます。<br>
並べ替えはドラッグまたは上下ボタンで行い、変更した順番は自動で保存されます。

<img src="app/assets/images/readme/tasks.png" alt="タスク編集画面" width="640">

### コピーして行動

タスクをマークダウン形式でコピーできます。<br>
作成したタスクや入力した情報は履歴画面からいつでも確認できます。

<img src="app/assets/images/readme/copy.png" alt="コピー用ボックス" width="640">

## 技術スタック

| 分類           | 技術                  |
| -------------- | --------------------- |
| Backend        | Ruby 4.0.5            |
|                | Ruby on Rails 8.1.3.1 |
|                | PostgreSQL 18         |
| Frontend       | Hotwire               |
|                | Turbo                 |
|                | Stimulus              |
|                | Tailwind CSS 4.3.1    |
|                | SortableJS            |
| Infrastructure | Render                |
|                | GitHub Actions        |
| Testing / Lint | RSpec                 |
|                | RuboCop               |
|                | ESLint                |
|                | ERB Lint              |
| External API   | OpenAI API            |

## ローカル開発環境

### 前提条件

ローカル環境で起動するには、以下が必要です。

- Ruby 4.0.5
- Docker Desktop、またはDocker Engine + Docker Compose v2
- Node.js
- npm
- OpenAI APIキー
- Google OAuthのクライアントIDとクライアントシークレット

### 認証情報の設定

OpenAI APIとGoogle OAuthの認証情報は、Rails Credentialsで管理します。
以下のコマンドで、ローカル開発用のCredentialsを編集してください。

```bash
bin/rails credentials:edit --environment development
```

次の形式で認証情報を設定します。

```yaml
openai:
  api_key: your_openai_api_key

google:
  client_id: your_google_client_id
  client_secret: your_google_client_secret
```

Google Cloud Consoleでは、承認済みのリダイレクトURIに以下を登録してください。

```text
http://localhost:3000/auth/google_oauth2/callback
```

`config/master.key`やAPIキーなどの秘密情報は、Gitにコミットしないでください。

## インストールと起動

ローカル開発では、PostgreSQL 18をDockerで起動します。
事前にDocker Compose v2を利用できるDocker環境を用意し、起動してください。

```bash
git clone https://github.com/koguchi-e/ReNovo.git
cd ReNovo
bin/setup
```

## Lint/Test

### Lintを実行する

```bash
bin/lint
```

### テストを実行する

```bash
bundle exec rspec
```

## 設計資料

- [ユビキタス言語](docs/ubiquitous-language.md)

## 概要

ローカル開発環境で使用していたPostgreSQL 15を、本番のRender環境と同じPostgreSQL 18に揃えました。

PostgreSQL 18はDocker Composeで起動し、Rails自体はこれまでどおりWSL上で実行します。

## 変更内容

- `compose.yaml`を追加

  - PostgreSQL公式イメージの`postgres:18`を使用
  - 既存のPostgreSQLとポートが重複しないよう、ホスト側の`5433`番ポートを使用
  - 名前付きVolumeを使用してDBデータを永続化
  - `healthcheck`でPostgreSQLの接続可能状態を確認

- `config/database.yml`を変更

  - development・test環境の接続先をDocker上のPostgreSQLへ変更
  - ユーザー名とパスワードを環境変数から変更可能に設定

- production環境の`DATABASE_URL`設定は変更していません

## 開発環境の起動方法

PostgreSQLを起動します。

```bash
docker compose up -d db
```

初回は開発・テスト用DBを準備します。

```bash
bin/rails db:prepare
RAILS_ENV=test bin/rails db:prepare
```

Railsはこれまでどおり起動します。

```bash
bin/dev
```

## 動作確認

- `docker compose ps`でDBコンテナが`healthy`になること
- RailsがPostgreSQL 18へ接続していること

```bash
bin/rails runner \
  'puts ActiveRecord::Base.connection.select_value("SHOW server_version")'
```

- RSpecが通ること

```bash
bundle exec rspec
```

## 補足

Docker上のPostgreSQLは`127.0.0.1:5433`で公開しています。WSLに既存のPostgreSQLがインストールされていても、ポートが重複しない構成です。
