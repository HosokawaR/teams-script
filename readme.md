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

#### スタートメニューから管理者権限で PowerShell を起動

後述するモジュールのインストールは管理者権限で行う必要があります。色々な方法がありますがここでは PowerShell 自体を管理者権限で起動する方法を取ります。

スタートメニューで PowerShell と検索  
「管理者として実行する」から PowerShell を管理者モードで起動
![PowerShell を管理者モードで起動する](https://user-images.githubusercontent.com/45098934/181064691-29e6700d-f8c5-4f47-9289-f1bc43c1a08e.png)

#### モジュールをインストール

以下のコマンドでインストールすることができます。
もし失敗する場合は PowerShell のバージョンが古い、適切な .NET Framework がインストールされていないなどが考えられます。[PowerShellGallery を使用したインストール](https://docs.microsoft.com/ja-jp/microsoftteams/teams-powershell-install#installing-using-the-powershellgallery)に詳しい情報がありますので参考にしてみてください。

```powershell
> Install-Module -Name PowerShellGet -Force -AllowClobber
> Install-Module -Name MicrosoftTeams -Force -AllowClobber
```

実行結果
![実行結果](https://user-images.githubusercontent.com/45098934/181065738-e42565fd-66ea-4396-8aea-29a189d8e3d1.png)

## メールアドレスを CSV 形式で保存

追加したいメンバーのメールアドレスを CSV 形式で保存します。ここでは`emails.csv`として保存します。
先頭は`email`で始まり、一行ごとにメールアドレスを保存します。以下のような形式です。

```csv
email
s20xxxx1@u.tsukuba.ac.jp
s20xxxx2@u.tsukuba.ac.jp
s20xxxx3@u.tsukuba.ac.jp
```

## 実行権限を設定

今後のスクリプトを実行するのには現在のユーザに権限を設定する必要があります。
`Set-ExecutionPolicy`[^1]は PowerShell ポリシーを設定するコマンドです。  
このコマンドでは`-Scope Process`を指定しているため現在のプロセスにいる間だけ権限が付与されます。**そのため PowerShell を途中で閉じた場合はこの作業をもう一度行う必要があります。**
それが面倒な場合は`-Scope CurrentUser`を使用して現在のユーザに対して恒久的に権限を与えてください。

```powershell
> Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process 
```

## Microsft Teams と連携

ここでは Microsoft Teams PowerShell モジュールと Microsoft Teams を連携する作業を行います。

`Connect-MicrosoftTeams`を入力するとポップアップが表示されるのでログインをします。

```powershell
> Connect-MicrosoftTeams  # Teams と接続し権限を取得
```

以下のようにポップアップが出てきて Microsoft Teams の連携をするためにサインインが求められるので、サインインします。
![ポップアップで表示されるログイン画面](https://user-images.githubusercontent.com/45098934/181068979-e9f51c88-922c-46aa-abc6-4681a1acf85b.png)

## 自動追加スクリプトを作成

### グループ ID を調べる

グループ ID とはチームに割り振られた ID のことです。

PowerShell で以下のコマンドを入力することでチーム ID を調べることができます。   
`-User`オプションには自分のアカウントのメールアドレスを入れてください。自分が所属しているチームのグループ ID が取得できます。

```powershell
> Get-Team -User s2xxxxxx@u.tsukuba.ac.jp  # チーム名と ID の一覧を取得
GroupId                              DisplayName       
-------                              -----------       
2ef068eb-dea5-476d-98dc-e6059874d59d 共通科目情報，...  
ce80767c-06de-4009-a4c4-c86f723efc01 フレッシュマン...  
432ca0b3-f219-4089-ba21-cf520bed18f8 微分積分B          
75f03c09-be9b-45d0-846d-a085f54916af GA13101_情報メ... 
87291ee5-608f-4ac0-9857-609f87dba60b GA12101_知能と... 
458d7f8b-4cc0-46f6-b9f2-e98bc7bf28cd 経済学の最前線...  
```

### スクリプトをダウンロード、修正

以下のスクリプトを作成します。
Teams ID と CSV のフルパスを設定するのを忘れないでください。

```powershell
$groupId = "<GroupID>"
$csvPath = "<CSV のフルパス>"

Import-Csv -Path $csvPath | foreach {
    Write-Output $_.email;
    Add-TeamUser -GroupId $groupId -user $_.email;
    Write-Output "Done"; 
    Start-Sleep 10
}
```

このスクリプトは以下のようにしてダウンロードすることもできます。

```powershell
> curl https://raw.githubusercontent.com/HosokawaR/teams-script/main/bulk-add-member.ps1
```

## スクリプトを実行

その後スクリプトを起動します。

```powershell
> powershell .\bulk-add-menber.ps1   
```

[:1] https://docs.microsoft.com/ja-jp/previous-versions/powershell/module/microsoft.powershell.security/set-executionpolicy?view=powershell-7.1


## 確認

Teams のメンバータブから確認できます。ただし手元で試したときには設定が反映されるまでラグがありました。
