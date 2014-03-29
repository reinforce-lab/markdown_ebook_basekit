PandocをつかったKindle出版のサンプル
====================

この本を [Pandoc](http://johnmacfarlane.net/pandoc/README.html) をつかってMacな環境で書くのに使った、プリプロセッサとビルドスクリプトです。

<iframe src="http://rcm-fe.amazon-adsystem.com/e/cm?lt1=_blank&bc1=000000&IS2=1&bg1=FFFFFF&fc1=000000&lc1=0000FF&t=belkatype-22&o=9&p=8&l=as4&m=amazon&f=ifr&ref=ss_til&asins=B00J9MHG66" style="width:120px;height:240px;" scrolling="no" marginwidth="0" marginheight="0" frameborder="0"></iframe>

簡単な使い方
---
Markdown記法で記述します。docs/ フォルダ以下にある拡張子 "md" のファイルを降順ソートして1つのファイルにまとめて、epub形式のファイルを出力します。
出力ファイル名は build.sh にベタ書きしています。build.sh 先頭の変数を適当にいじってください。

build.sh を実行するとepub形式のファイルが出来上がります。Pandocには図表やテーブル番号の参照機能がないため、プリプロセッサで補っています。

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

