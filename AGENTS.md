# ReNovo 開発ガイド

## プロジェクト概要

ReNovoは、現在の状況・解決したい問題・達成したい目標を整理し、AIが次に取り組める具体的なタスクを提案するRailsアプリケーションである。

## 技術スタック

- Ruby 4.0.9 / Ruby on Rails 8.1
- PostgreSQL 18
- Hotwire（Turbo、Stimulus）
- Tailwind CSS
- RSpec、RuboCop、ESLint、Prettier、ERB Lint
- Render、GitHub Actions
- OpenAI API、Google OAuth

依存関係の正確なバージョンは`Gemfile`、`Gemfile.lock`、`package.json`を参照すること。

## デプロイ

- 本番環境はRenderを使用する。Kamalは使用しない。
- Render用の`bin/render-build.sh`およびDocker関連ファイルは、Renderで利用する設定として維持する。

## リポジトリ構成

- `app/`: Railsアプリケーション本体。モデル、コントローラ、ビュー、ジョブ、Stimulusコントローラなどを配置する。
- `spec/`: RSpecのテスト。リクエスト、モデル、ジョブ、システムテストなどを配置する。
- `config/`: Rails設定、ルーティング、環境別設定、Credentials関連設定を配置する。
- `docs/`: 設計資料。用語は`docs/ubiquitous-language.md`を正とする。
- `.github/`: CI、Dependabot、PRテンプレートを配置する。

## 調査・実装方針

- 実装前に`README.md`、関連する設計資料、既存実装、既存テストを確認すること。
- Railsの慣例と既存の責務分割に従い、変更範囲を必要最小限にすること。
- UIの変更では、TurboおよびStimulusコントローラとの連携を確認すること。
- 新しい依存関係、外部サービス、設定変更は、既存の構成との整合性と影響範囲を確認してから追加すること。

## テスト・Lint

- コード変更後は、変更に関連するRSpecを実行すること。
- RSpecおよびLintは、原則として事前承認なしで実行してよい。
- 全体確認には`bundle exec rspec`と`bin/lint`を使用する。
- `bin/lint`はRuboCop、ESLint、Prettier、ERB Lintを実行する。
- テストまたはLintが失敗した場合は原因を調査し、実行コマンドと結果を報告すること。
- 実行環境のサンドボックス、ネットワーク、権限に関する制約には従うこと。

## Git・GitHub運用

- `main`ブランチへ直接pushしないこと。
- 関係のないファイルをコミットに含めないこと。
- force pushを行わないこと。
- 既存のIssueおよびPull Requestを確認し、重複作成を避けること。
- コミット、push、Pull Request作成、Issue作成、GitHub Projectへの追加、Status・Labelの変更は、ユーザーの承認を得てから行うこと。
- ユーザーの指示なしにPull Requestをマージしないこと。
- Issueのタイトル・本文、Pull Requestのタイトル・本文、コミットメッセージは日本語で記述すること。
- Issue本文には`## 概要`、`## 作業内容`、`## 完了条件`の見出しを設け、各項目はMarkdownのリストで記述すること。`## 概要`には、作業が必要な理由とIssue作成に至った経緯を含めること。
- Pull Request本文には`## Issue`、`## 概要`、`## 作業内容`、`## 変更理由`の見出しを設けること。対応Issueは`## Issue`配下に`- #番号`の形式で記載すること。
- Issue・Pull Request本文でコマンド、コード、テストログまたはテスト結果を記載する場合は、内容全体をMarkdownのコードブロックで囲むこと。
- Issue番号が明示されていない場合は、Pull Request作成前にユーザーへ確認すること。
- 1 Issueにつき1作業ブランチを基本とし、1 Pull Requestでは1つの目的だけを扱うこと。
- 作業ブランチでコミットした変更は、対応するPull Requestを作成して共有すること。

## セキュリティ

- `config/master.key`、Credentialsの復号キー、APIキー、OAuthクライアントシークレット、トークンその他の秘密情報をコミット・表示・ログ出力しないこと。
- 本番データに影響する操作、データ削除、履歴改変などの破壊的な操作は、ユーザーの明示的な承認なしに実行しないこと。
- 認証情報はRails Credentialsなど既存の安全な管理方法を使用し、ソースコードやドキュメントに直接記載しないこと。
