# task-register

右クリックからファイルを送るだけで、タスクスケジューラに管理者権限タスクとして登録するツール。  
登録後は UAC プロンプトなしでデスクトップショートカットから起動できる。

## セットアップ（初回のみ）

`setup.cmd` を実行する（UAC プロンプトが 1 回出る）

SendTo へのショートカット登録とタスクスケジューラへの登録を自動で行う。

## 対応ファイル

| 拡張子 | 動作 |
|---|---|
| `.cmd` / `.bat` | そのまま登録 |
| `.exe` | そのまま登録 |
| `.lnk` | ターゲットを解決して登録 |

## 使い方

### タスクを登録する

登録したいファイルを右クリック →「送る」→「reg_admin_task」

- タスクスケジューラ `\task-register\<ファイル名>` にタスクが登録される
- デスクトップに起動用ショートカット（UAC なし）が作成される
- `delete-cmds\<ファイル名>.cmd` が自動生成される

### タスクを削除する

`delete-cmds\<タスク名>.cmd` を実行する

- タスクスケジューラからタスクを削除する
- 削除成功後、自身（削除用 cmd）も自動的に消える

## ファイル構成

```
task-register/
├── setup.cmd                  # 初回セットアップ
├── reg_admin_task.cmd          # SendTo エントリ（ドロップ先）
├── delete-cmds/                # 登録時に自動生成される削除 cmd の置き場
└── data/
    ├── setup_task.ps1          # reg_admin_task 自体をタスク登録する
    ├── register.ps1            # タスク登録・ショートカット作成・削除 cmd 生成
    ├── unregister.ps1          # タスク削除・削除 cmd 自己消去
    └── run_from_temp.ps1       # SendTo 経由の起動を中継する（temp ファイル経由）
```

## 仕組み

SendTo から直接 UAC を出さないために、一時ファイルを中継してタスク経由で実行する。

```
「送る」でドロップ
  → reg_admin_task.cmd がパスを %TEMP% に書き出し
  → schtasks /run で \task-register\reg_admin_task を起動（UAC なし）
  → run_from_temp.ps1 が %TEMP% を読んで register.ps1 を呼ぶ
```
