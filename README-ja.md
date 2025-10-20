# カスタム Bash 環境

## インストール手順
1. 本リポジトリを `~/.config/bash` にクローンします（別の場所に置く場合は以降のパスを読み替えてください）。
2. `~/.bashrc` が存在しない場合は作成し、以下の1行を追記します。
   ```bash
   source ~/.config/bash/bashrc
   ```
3. シェルを再起動するか、`source ~/.config/bash/bashrc` を実行して設定を反映させます。

マシン固有のトークンや秘密情報は `~/.config/bash/.env` に記述できます。ファイルが存在すれば自動的に読み込まれます。

## ディレクトリ構成
```
.
├── ai/                  # Gemini / OpenAI 向けプロンプト補助スクリプト
├── alias                # シェルエイリアス
├── bashrc               # エントリーポイント（各種設定を読み込む）
├── scripts/
│   ├── discord.sh       # Discord Webhook 送信補助
│   ├── git.sh           # 登録済みリポジトリの一括更新
│   ├── vnc.sh           # SSHトンネルに対応したVNCランチャー
│   ├── xrandr.sh        # 画面解像度プリセット
│   └── fzf/
│       ├── cd.sh        # fcd: 対話的ディレクトリブラウザ
│       └── rg.sh        # frg: ripgrep + fzf ジャンプ
└── settings/            # プロンプト、XDG、OS別設定など
```

## 機能別概要と依存関係
各機能は独立しています。依存ツールがインストールされていない場合、その機能だけが動作しませんが、他の機能には影響しません。

### `vnc` (`scripts/vnc.sh`)
- **目的**: `~/.ssh/config` に定義したホストへ RealVNC Viewer で接続。`ssh -J` 相当のジャンプホスト指定にも対応。
- **必須**: `ssh`、RealVNC Viewer（macOS: `/Applications/VNC Viewer.app/...`、Linux: `/usr/bin/vncviewer`）。
- **任意**: なし。

### `fcd` (`scripts/fzf/cd.sh`)
- **目的**: プレビュー付きのディレクトリ移動。`Ctrl-F` で下位へ、`Ctrl-U` で親ディレクトリへ移動できます。
- **必須**: `fzf`、標準の `find` コマンド。
- **任意**: なし。

### `frg` (`scripts/fzf/rg.sh`)
- **目的**: ripgrep と fzf を組み合わせた検索ジャンプ。`-k/--keyword` によるキーワード指定と、安全な除外設定を提供します。
- **必須**: `rg`、`fzf`。
- **任意**: `bat`（プレビュー時のシンタックスハイライト。未導入の場合は `nl` + `sed` にフォールバックします）。

### AI ヘルパー (`ai/`)
- **目的**: Gemini / OpenAI の API を使った翻訳・ドキュメント生成など。
- **必須**: ネットワークアクセスと、環境変数に設定した各プロバイダの API キー（`GEMINI_API_KEY`、`OPENAI_API_KEY` など）。
- **任意**: なし。

### `discord.sh`
- **目的**: 設定済み Webhook へメッセージを送信。
- **必須**: `curl`。
- **任意**: なし。

### `git.sh`
- **目的**: 登録済みの複数リポジトリに対し `git pull` を順次実行。
- **必須**: `git`。
- **任意**: なし。

### `xrandr.sh`
- **目的**: X11 環境向けの解像度プリセット。
- **必須**: `xrandr`（Linux）。
- **任意**: なし。

## 利用にあたって
- `bashrc` を読み込むと上記の各種関数が利用可能になります。動作中のシェルで再読み込みしたい場合は `source ~/.config/bash/bashrc` を実行してください。
- 任意ツールが存在しない場合でも、該当機能だけが警告を出すか利用不可になるだけで、他の機能はそのまま使えます。
- `scripts/` や `settings/` の内容は自由に拡張して、必要なツールに合わせてカスタマイズしてください。

