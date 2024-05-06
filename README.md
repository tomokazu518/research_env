# RStudioとLatexの研究環境

## イメージに含まれているもの

- ベースイメージはrocker/rstudio
  - R本体
  - RStudio Server
  - Pandoc
- Rのrenvパッケージ
- tidyverseとsfをインストールするのに必要なパッケージ  
  (足りないものがあればDockerfileに追記してください)
- RStudioでgithub copilotを利用可能に
- Tex Liveのフルスキーム  
  (イメージを小さくしたい場合はスキームを変更してください)
- Pandocフィルター
  - [Pandoc-crosreff](https://github.com/lierdakil/pandoc-crossref)
  - [Pandoc-plot](https://laurentrdc.github.io/pandoc-plot/) (HaskellでビルドしたバイナリをGoogle Driveからコピー)
  - 授業資料用のテンプレートとコンパイルするためのスクリプト
- IPAフォント，Notoフォント
- Gnuplot

## 導入の準備

以下，Windowsの場合はPowerShellかコマンドプロンプト，Macの場合はターミナルでの操作

### Open SSHのインストール (Windowsの場合のみ)

Windowsの場合は，OpenSSHに不具合があるので，不具合が解消されたBeta版をインストール
```{cmd}
winget install Microsoft.OpenSSH.Beta
```

### 秘密鍵を作成してGithubに登録

githubにアクセスするための秘密鍵を作成
```{shell}
ssh-keygen -t ed25519
```
- 保存場所とパスフレーズを聞かれる
  - 保存場所はデフォルト(~/.ssh)でOkなので何も入力せずにEnter
  - パスフレーズも必要なければそのままEnter
- ~/.sshフォルダにid_ed255119とid_ed25519.pubという2つのファイルができる
  - id_ed25519.pubの方をテキスト・エディタなどで開いて，内容をコピー
  - Githubのアカウント設定から，コピーしたSSH keyを追加

接続できることを確認
```
ssh git@github.com
```
次のように表示されればOk
```
Hi tomokazu518! You've successfully authenticated, but GitHub does not provide shell access.
Connection to github.com closed.
```
SSH Agentに秘密鍵を登録 (これでコンテナからも設定不要でssh可能)
```
ssh-add
```

## Dockerでビルドする準備

### Docker Desktopのインストール

Windowsであればwinget
```
winget install Docker.DockerDesktop
```
Macであればhomebrew
```
brew install DockerDesktop
```
Dockerのホームページからインストーラをダウンロードして実行してもOk
- Windowsの場合はWSL2も同時にインストールされる
- インストール後には再起動が必要

### レポジトリのクローン

gitが使える場合には，レポジトリをクローン (Windowsの場合wsl上に)
```
git clone git@github.com:tomokazu518/research_env.git
```
gitが使えない場合は，githubからzipファイルをダウンロードして展開 (環境構築後，gitはコンテナ内のものを使えるので，ここでインストールする必要はない)

フォルダ構成は以下

<pre>
research_env
├── Dockerfile
├── README.md
├── docker-compose.yml
├── font.sh
└── pandoc
    ├── script
    │   ├── lecture_beamer.sh
    │   └── lecture_beamer_blank.sh
    └── templates
        ├── beamer-with-notes.latex
        ├── beamer-without-notes.latex
        └── lecture_beamer.latex
</pre>

### TexLiveレポジトリのクローン

research_envフォルダ内にtexliveというフォルダを作成して，CTANからTexLiveのレポジトリをダウンロード

```
cd research_env
mkdir texlive
rsync -a --delete rsync://ftp.jaist.ac.jp/pub/CTAN/systems/texlive/tlnet/ texlive/
```

- TexLiveをまるごと (5GB以上)ダウンロードするので，そこそこ時間がかかる
- 一度ダウンロードした後で，上記のrsyncコマンドを実行すればレポジトリがアップデートされる (追加されたファイルや変更があったファイルだけをダウンロードできる)

TexLiveはネットワークインストールも可能
- ファイルを保持する必要がないので，ディスク領域は節約できる
- ただし，ビルドをやり直すときにはすべてのファイルをダウンロードするので時間がかかる

## Dockerイメージのビルドと起動

`docker-compose.yml`と`Dockerfile`のあるフォルダ (research_env)に入ってdocker composeを実行
```
cd research_env
docker compose up -d
```
ビルドには数十分かかるが，終わればコンテナが起動する (再起動後も自動起動する)

## 使い方

### 基本的な使い方

research_envフォルダはコンテナにマウントされるので，その中に`projects`というサブ・フォルダを作成し，さらにその中でプロジェクトごとのフォルダを作って使うことを想定している

### RStudio Server

RStudio Serverにはブラウザからアクセスできる (Chromeなどでアプリ化すると，Desktop版RStudioとほぼ同一の操作感)

http://localhost:8787

- Rのパッケージはrenvを使って管理
- パッケージはresearch_env/.cache/R/renvにキャッシュされる

RStudioの表示フォントとして，HackGenフォントを使いたい場合には，research_envフォルダで以下を実行すればインストールされる
```
./font.sh
```

### Latex

Visual Studio Codeの場合，使い方は2パターン
- コンテナにアタッチして使う
  - ファイルのパーミションの問題 (とくにWindows)があるので，コンテナにはrstudioユーザーで入る
  - コンテナ構成ファイルに以下を追加
  ```
	"remoteUser": "rstudio"
  ```
- ローカルでソースを編集し，コンパイルはコンテナで行う
  - LaTex Workshopの設定で，Docker Enabledにチェックを入れ，Imageにイメージ名を設定するだけで使える
  - この場合，コンテナを起動させておく必要はない (コンパイルで呼び出したときにだけ起動される)
  - Latexのコンパイルだけ使う(Rは使わない)なら，専用のコンテナを作るのも良い

### Python

pipでpythonのパッケージをインストールできる
- research_env/.pipにインストールされる


## 参考

- Yanagimotoさんの[VSCode + Dockerでよりミニマルでポータブルな研究環境を](https://zenn.dev/nicetak/articles/vscode-docker-2023)，[VSCode + Docker + Rstudio + DVC でポータブルな研究環境を作る](https://zenn.dev/nicetak/articles/vscode-docker-rstudio?redirected=1)
- yetanothersuさんの[RStudio Serverで好きなフォントを使う](https://qiita.com/yetanothersu/items/18e098989cade90ee687)