---
name: create-pr
description: ReNovoの変更を確認し、承認後にコミット、push、GitHub Pull Requestを作成する。Pull Request作成を依頼されたときに使用する。
---

# Create GitHub Pull Request

ReNovoリポジトリの変更を確認し、安全にPull Requestを作成する。

## 事前確認

1. 現在のブランチ、`git status`、コミット履歴、差分を確認する。
2. リポジトリルートの`AGENTS.md`を読み、プロジェクト固有の開発・GitHub運用ルールに従う。
3. 変更に関係するIssueを確認する。Issue番号がユーザーから明示されていない場合は、Pull Request作成前にユーザーへ確認する。
4. 既存のPull Requestを確認し、同一または重複する変更のPull Requestを作成しない。
5. `main`ブランチ上ではコミットまたはpushを行わない。1 Issueにつき1作業ブランチを基本とし、1 Pull Requestでは1つの目的だけを扱う。

## 品質確認

- 変更内容に対応するRSpecを実行する。必要に応じて`bundle exec rspec`を実行する。
- `bin/lint`を実行する。実行できない場合や失敗した場合は、原因と実行結果を報告する。
- 実行したテスト・Lint、結果、未実行の確認項目をPull Request作成前にまとめる。

## 承認とGit操作

- コミット前に、コミット対象ファイル、日本語のコミットメッセージ、変更概要を提示し、ユーザーの明示的な承認を得る。
- push前に、push先のリモートとブランチ、pushするコミットを提示し、ユーザーの明示的な承認を得る。
- Pull Request作成前に、タイトル、本文、baseブランチ、headブランチ、関連Issue、テスト・Lint結果を提示し、ユーザーの明示的な承認を得る。
- 関係のないファイルをコミットに含めない。ステージング内容を確認してからコミットする。
- `main`への直接push、force push、ユーザーの指示なしのPull Requestマージを行わない。

## Pull Request本文

- タイトルと本文は日本語で記述する。
- 本文には`## Issue`、`## 概要`、`## 作業内容`、`## 変更理由`のMarkdown見出しをこの順で設ける。
- `## Issue`配下には、対応するIssue番号を`- #番号`の形式で記載する。
- コマンド、コード、テストログまたはテスト結果を本文へ記載する場合は、内容全体をMarkdownのコードブロックで囲む。
- 作業ブランチでコミットした変更には、対応するPull Requestを必ず作成して共有する。

## 完了報告

- 作成したPull RequestのURLを報告する。
- コミット、push、Pull Request作成で実行した内容を報告する。
- テスト・Lint結果と、承認待ちまたは未実行の項目を明記する。
