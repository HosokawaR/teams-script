# PowerShell を用いた Microsoft Teams のチームへの自動一括追加のやり方

本ドキュメントは PowerShell を用いた Microsoft Teams のチームへの自動一括追加のやり方について解説したものです。
学生・社員を特定のチームに一括で追加したい場合などに活用してください。  

## 共同著者


## 前提条件

 - Windows 11 (10) を使用している
   - 筆者が Windwos 11 Home で確認したというだけで Windows 10 でも動作すると思います
 - チームに追加したいメンバーのメールアドレスが分かっている
 - あなたが追加したいチームの管理者である
   - ご自身でチームを作成した場合はおそらく管理者になっているはずです

## 実行手順

### 全体方針

PowerShell から Microsoft Teams PowerShell モジュールを用いて、CSV に保存されたメールアドレスの情報をもとに任意のチームにメンバーを一括追加します。  
WEB API 経由で追加する方法などもありますが、今回 Microsoft Teams PowerSHell モジュールを用いる理由は、他の方法と比べて Teams との連携がスムーズなためです。

### Microsoft Teams PowerShell モジュールをインストール

Microsoft Teams PowerShell モジュールは PowerShell から Microsoft Teams と連携するためのツールです。PowerShell から連携できるので、今回のようにコマンドラインから色々な操作を自動化することができます。

#### スタートメニューから PowerShell を起動

（画像）

#### モジュールをインストール

以下のコマンドでインストールすることができます。
もし失敗する場合は PowerShell のバージョンが古い、適切な .NET Framework がインストールされていないなどが考えられます。[PowerShellGallery を使用したインストール](https://docs.microsoft.com/ja-jp/microsoftteams/teams-powershell-install#installing-using-the-powershellgallery)に詳しい情報がありますので参考にしてみてください。

```powershell
> Install-Module -Name PowerShellGet -Force -AllowClobber
> Install-Module -Name MicrosoftTeams -Force -AllowClobber
```

## メールアドレスを CSV 形式で保存

追加したいメンバーのメールアドレスを CSV 形式で保存します。場所はどこでもいいです。
先頭は`email`で始まり、一行ごとにメールアドレスを保存します。以下のような形式です。

```csv
email
s20xxxx1@u.tsukuba.ac.jp
s20xxxx2@u.tsukuba.ac.jp
s20xxxx3@u.tsukuba.ac.jp
```

## 自動追加スクリプトを作成

### チーム ID を調べる

PowerShell で以下のコマンドを入力することでチーム ID を調べることができます。  
`Connect-MicrosoftTeams`を入力するとポップアップが表示されるのでログインをします。

```powershell
> Connect-MicrosoftTeams  # Teams と接続し権限を取得
> Get-Team                # チーム名と ID の一覧を取得
```
 
### スクリプトをダウンロード、修正

以下のスクリプトを保存します。同じものが[ここ](https://exmaple.com)から取得できます。
ここではファイル名を`bulk-add-member.ps1`とします。 
Teams ID と CSV のフルパスを設定するのを忘れないでください。

```powershell

$teamId = "<TeamsID>"
$csvPath = "<CSV のフルパス>"

Import-Csv -Path $csvPath | foreach {
    Write-Output $_.email;
    Add-TeamUser -GroupId $teamId -user $_.email;
    Write-Output "Done"; 
    Start-Sleep 10
}
```

## スクリプトを実行

実行前に現在のユーザに適切な権限を付与する必要があります。
`Set-ExecutionPolicy`[^1]は PowerShell ポリシーを設定するコマンドです。  
このコマンドでは`-Scope CurrentUser`を指定しているため現在使用しているユーザに対して恒久的に権限を付与します。権限を現在のプロセスのみに絞りたい場合は`-Scope Process`と指定すればできます。この場合、PowerShell を一度閉じた場合は権限設定が無向になります。

```powershell
> Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser 
```

その後スクリプトを起動します。

```powershell
> powershell .\bulk-add-menber.ps1   
```

[:1] https://docs.microsoft.com/ja-jp/previous-versions/powershell/module/microsoft.powershell.security/set-executionpolicy?view=powershell-7.1


## 確認

Teams のメンバータブから確認できます。ただし手元で試したときには設定が反映されるまでラグがありました。
