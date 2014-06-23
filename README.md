## PandocをつかったKindle出版のサンプル

[Pandoc](http://johnmacfarlane.net/pandoc/README.html) を使いiBeaconハンドブックをMacな環境で書くのに使った、プリプロセッサとビルドスクリプトです。epub形式とPDF形式を1ソースから生成します。

このフォルダにある、book.epub, book.pdfのような電子書籍が生成できます。

## とりあえず使ってみる
EPUB形式のファイル生成であれば、[pandoc](http://johnmacfarlane.net/pandoc/)をインストールするだけです。PDFファイルを生成するには、次のLaTeX環境構築の手順に従いLuaLaTeXをインストールしてください。

適当な作業フォルダで次のシェルスクリプトを実行すれば、電子書籍が生成されます。ファイル名はbook.epubもしくはbook.pdfです。とりあえず動作を確かめてみたいときは、このプロジェクトの次のシェルスクリプトを実行すれば、サンプルドキュメント(docs/ fig/ にあるファイルから)電子書籍ファイルが生成されます。

~~~~
$ build-epub.sh
$ build-pdf.sh
~~~~

## プロジェクトの作成とサブモジュールとして読み込み
このプロジェクト自体はサブモジュールとして利用すればよいでしょう。

~~~~.csh
$ mkdir 適当な作業フォルダ
$ cd 作業フォルダ; mkdir docs; mkdir fig
$ (本文や図表ファイルを作る。epub形式の場合は、必ず表紙画像ファイル fig/cover.jpg を用意する。)
$ git init; git add *; 
$ git submodule add https://github.com/reinforce-lab/markdown_ebook_basekit
$ markdown_ebook_basekit/build-epub.sh もしくは markdown_ebook_basekitbuild-pdf.sh を実行してファイル生成
~~~~

## 設定ファイル
タイトルや著者名など書籍ごとの設定はUTF-8の settings.txt に記述します。これはsedのコマンドファイルです。"実行時のフォルダにある" settings.txt を読み込みます。このプロジェクトにある settings.txt を元にして編集するのがよいです。

~~~~
# タイトル
s/\$title/iBeaconハンドブック/g
# 著者名
s/\$author/上原 昭宏/g
# 発行日
s/\$publication_date/2014年3月15日/g
~~~~

### PDFを生成するためのLaTeX環境構築
Lualatexを使います。 http://oku.edu.mie-u.ac.jp/~okumura/texwiki/?Mac の手順どおりです:

1. パッケージ MacTeX.pkg をインストール。
2. コマンドラインから更新。 $ sudo tlmgr update --self --all

次に、 http://oku.edu.mie-u.ac.jp/~okumura/texwiki/?Mac#i9febc9b の手順でフォント設定をします。Macを利用しているので:

~~~~.csh
$ sudo mkdir -p /usr/local/texlive/texmf-local/fonts/opentype/hiragino/
$ cd /usr/local/texlive/texmf-local/fonts/opentype/hiragino/
$ sudo ln -fs "/Library/Fonts/ヒラギノ明朝 Pro W3.otf" ./HiraMinPro-W3.otf
$ sudo ln -fs "/Library/Fonts/ヒラギノ明朝 Pro W6.otf" ./HiraMinPro-W6.otf
$ sudo ln -fs "/Library/Fonts/ヒラギノ丸ゴ Pro W4.otf" ./HiraMaruPro-W4.otf
$ sudo ln -fs "/Library/Fonts/ヒラギノ角ゴ Pro W3.otf" ./HiraKakuPro-W3.otf
$ sudo ln -fs "/Library/Fonts/ヒラギノ角ゴ Pro W6.otf" ./HiraKakuPro-W6.otf
$ sudo ln -fs "/Library/Fonts/ヒラギノ角ゴ Std W8.otf" ./HiraKakuStd-W8.otf
$ sudo mktexlsr
~~~~

#### PDFファイルへのフォント埋め込み
このスクリプトで生成したPDFファイルにはフォントが埋め込まれていません。プレビューappでPDFファイルを開き、適当なプリンタを選択して、必要があればカスタム設定をしてターゲットの用紙サイズを選択して、解像度を600/1200dpiに設定して、左下のPDFを生成を選択します。

## テキストの作成
まずテキストを、フォルダ docs/ 以下にMarkdown記法で記述します。
ソースは章単位などの適当なかたまりでファイルに分割記述できます。スクリプトが、docs/ フォルダ以下にある拡張子 "md" のファイルを降順ソートして1つのファイルにまとめます。図はpng形式で、fig/ 以下に置きます。

## フォルダ構成
フォルダ名は決め打ちです。本文および図表は以下のフォルダに置きます。

- docs/
	- markdown形式の本文テキストファイルを置きます。拡張子は .md です。ファイル分割している場合は、sortしたファイル順で読み込みます。
- fig/
	- 図表を起きます。

### epub形式
EPUB形式のタイトルや著者情報は、epub/title.txt で設定します。表紙画像ファイルは fig/cover.jpg に置きます。表紙画像がないとEPUB生成時にエラーになります。

### PDF形式
PDF形式のタイトルや著者情報は、latex/header.txt で設定します。冒頭のタイトルと、hyperrefのPDFのタイトルをそれぞれ設定します。latex/index_dic.txt は索引の辞書です。

### 図表の参照
Pandocには図表やテーブル番号の参照機能がないため、プリプロセッサで補っています。

図表は、このように#につづけてタグ名を入れておきます。タイトルの前には"図1.1"や"表1.1"のような図表番号が入れられます。
```
![ #fig_ibeacon_intro ビーコンとiPhone](fig/ch01_beacon.png)

Table: #table_ble_spec Bluetooth Low Energyの物理層の特性
```

タグをかっこで囲むことで、、その図表番号を文中で参照できます。"図1.1"や"表1.1"といった図表番号のテキストに置換されます。リンクはしません。

```
[#fig_ibeacon_intro]

[#table_ble_spec]
```
