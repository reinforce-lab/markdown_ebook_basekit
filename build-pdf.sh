#!/bin/sh

#ソースファイル
source_files=`find ./ -name "*md" | grep docs | sort`

#出力ファイル名
pdf_file="ibeaconbook.pdf"

#lualatex用のファイル
latex_header_file="./latex/header.txt"
latex_ist_file="./latex/dot.ist"

# 作業変数
tmp_dir="./tmp_pdf_working/"
tmp_file1="ibeaconbook1.md"
tmp_file2="ibeaconbook2.md"
latex_file1="ibeaconbook1.tex"
latex_file2="ibeaconbook2.tex"
latex_idx_file2="ibeaconbook2.idx"
latex_file2_pdf="ibeaconbook2.pdf"

#作業ディレクトリを準備
rm -Rf $tmp_dir
mkdir -p $tmp_dir

#ソースファイルがあるかを確認, ターゲットにコピー
for source_file in $source_files $latex_header_file $latex_ist_file
do
	if [ ! -f $source_file ]; then
		echo "$source_file does not exist."
		exit
	fi
done
# スタイルファイルをコピー
cp $latex_header_file $tmp_dir
cp $latex_ist_file    $tmp_dir

# ソースファイルを1つに結合
cat $source_files > $tmp_dir/$tmp_file1

#図表をコピー
cp -Rf ./fig $tmp_dir

# Markdown to lualatex
cd $tmp_dir
../preprocesser-pdf.rb -i $tmp_file1 -o $tmp_file2

/usr/local/bin/pandoc $tmp_file2 -s \
-V documentclass=ltjbook -V classoption=luatexja \
-V urlcolor=black -V citecolor=black -V linkcolor=black \
-V "fontsize:10pt" \
--chapters --table-of-contents --toc-depth=3 \
-H header.txt --listings \
--latex-engine=lualatex \
-o $latex_file1

../postprocesser-pdf.rb -i $latex_file1 -o $latex_file2

# 参照解決のために2回実行
lualatex $latex_file2
lualatex $latex_file2
# 索引作成
makeindex -r -c  -p any $latex_idx_file2
lualatex $latex_file2
lualatex $latex_file2

# 生成ファイルの移動とワーキングディレクトリの削除
mv $latex_file2_pdf ../$pdf_file
cd ../
rm -Rf $tmp_dir
