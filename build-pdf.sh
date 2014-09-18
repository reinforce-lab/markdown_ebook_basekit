#!/bin/sh

#ソースファイル
source_files=`find ./docs -name "*md" | sort`
setting_file="settings.txt"
#source_files="./docs/ch00_preview.md"
#source_files="./docs/ch02_phyasical.md" 
#source_files=`find ./ -name "*01*md" | grep docs | sort`
#source_files=`find ./ -name "*02*md" | grep docs | sort`

CUR_DIR=`pwd`
DIR=`echo $(cd $(dirname $0);pwd)`

#出力ファイル名
pdf_file="book.pdf"

#lualatex用のファイル
latex_header_file="$DIR/latex/header.txt"
latex_ist_file="$DIR/latex/dot.ist"
#latex_template="./latex/default.latex"

# 作業変数
tmp_dir=$TMPDIR/com.reinforce-lab.com.book/
tmp_latex_header_file="$tmp_dir/header.txt"
tmp_file1="book1.md"
tmp_file2="book2.md"
latex_file1="book1.tex"
latex_file2="book2.tex"
latex_idx_file2="book2.idx"
latex_file2_pdf="book2.pdf"

#作業ディレクトリを準備
rm -Rf $tmp_dir
mkdir -p $tmp_dir

#設定ファイルがあるか確認
if [ ! -f $setting_file ]; then
	echo "$setting_file does not exist."
	exit
fi

#ソースファイルがあるかを確認, ターゲットにコピー
for source_file in $source_files $latex_header_file $latex_ist_file
do
	if [ ! -f $source_file ]; then
		echo "$source_file does not exist."
		exit
	fi
done
# スタイルファイルをコピー
sed -f $setting_file < $latex_header_file > $tmp_latex_header_file
#cp $latex_ist_file $tmp_dir
#cp $latex_template $tmp_dir
# ソースファイルを1つに結合
cat $source_files > $tmp_dir/$tmp_file1
#図表をコピー
cp -Rf ./fig $tmp_dir
#debug
#cp $epub_files $tmp_dir

# Markdown to lualatex
#/usr/local/bin/pandoc $tmp_file1 --latex-engine=lualatex -o $latex_file1
cd $tmp_dir
$DIR/preprocesser-pdf.rb -i $tmp_file1 -o $tmp_file2
#cp $tmp_file1 $tmp_file2

/usr/local/bin/pandoc $tmp_file2 -s \
-f markdown+grid_tables+multiline_tables \
-V documentclass=ltjbook -V classoption=luatexja \
-V urlcolor=black -V citecolor=black -V linkcolor=black \
-V "fontsize:10pt" \
--chapters --table-of-contents --toc-depth=3 \
-H $tmp_latex_header_file --listings \
--latex-engine=lualatex \
-o $latex_file1

$DIR/postprocesser-pdf.rb -i $latex_file1 -o $latex_file2

# 参照解決のために2回実行
lualatex $latex_file2
lualatex $latex_file2
# 索引作成
makeindex -r -c -s $latex_ist_file -p any $latex_idx_file2
#makeindex -r -c  -p any $latex_idx_file2
lualatex $latex_file2
lualatex $latex_file2

mv $latex_file2_pdf $CUR_DIR/$pdf_file

#rm -Rf $tmp_dir
#mendex -r -c -g -s dot.ist -p any foo.idx
