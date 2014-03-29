#!/bin/sh

#ソースファイル
#source_files="./docs/ch02_phyasical.md" #debug
source_files=`find ./ -name "*md" | grep docs | sort`

#epub設定ファイル
epub_metadata=".//epub/metadata.xml"
epub_style=".//epub/style.css"
epub_title=".//epub/title.txt"
epub_files="$epub_metadata $epub_style $epub_title"

# 作業変数
tmp_dir=$TMPDIR/com.reinforce-lab.com.ibeaconbook/
tmp_file1="$tmp_dir/ibeaconbook1.md"
tmp_file2="$tmp_dir/ibeaconbook2.md"
out_file="./ibeaconbook.epub"

#作業ディレクトリを準備
rm -Rf $tmp_dir
mkdir -p $tmp_dir

#ソースファイルがあるかを確認, ターゲットにコピー
for source_file in $source_files $epub_files
do
	if [ ! -f $source_file ]; then
		echo "$source_file does not exist."
		exit
	fi
done
cat $source_files > $tmp_file1
./preprocesser.rb -i $tmp_file1 -o $tmp_file2
#cp $tmp_file1 $tmp_file2
#cp $epub_files $tmp_dir

#整形
/usr/local/bin/pandoc \
--number-sections --epub-metadata=$epub_metadata --epub-stylesheet=$epub_style \
-t epub3 --mathml --toc-depth=3 \
--highlight-style=monochrome \
--epub-cover-image=fig/IMG_0180.jpg \
$epub_title $tmp_file2 -o $out_file

#--no-highlight \
#--highlight-style=kate \
#Specifies the coloring style to be used in highlighted source code. 
#Options are pygments (the default), kate, monochrome, espresso, zenburn, haddock, and tango.

#オプション
#* --epub-stylesheet=FILE
#* --epub-cover-image=FILE
#* --epub-metadata=FILE	

#デバッグ出力
#cat $tmp_file
#ls -alF $tmp_file

#ファイルを結合
#echo "cat $source_files $tmp_file"

# cat $tmp_file
#	cp $source_file $tmp_dir


#echo $source_files
#echo $tmp_dir
