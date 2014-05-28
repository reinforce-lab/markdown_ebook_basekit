#!/usr/bin/ruby
# -*- coding: utf-8 -*-

require 'getoptlong.rb'

# 入出力ファイルの取得
inputFileName  = ""
outputFileName = ""

# 引数のパース
parser = GetoptLong.new
parser.set_options(
    ['--input', '-i', GetoptLong::REQUIRED_ARGUMENT],
    ['--output','-o', GetoptLong::REQUIRED_ARGUMENT])
#    ['--help',                     GetoptLong::NO_ARGUMENT],
#    ['--version',                  GetoptLong::NO_ARGUMENT])
begin
   parser.each_option do |name, arg|   	
   	if name == "--input"
   		inputFileName = arg
   	else 
   		if name == "--output"
   			outputFileName = arg
   		end
   	end
#      eval "$OPT_#{name.sub(/^--/, '').gsub(/-/, '_').upcase} = '#{arg}'"   	
   end
rescue
   exit(1)
end

# 引数の値チェック
if inputFileName == "" || outputFileName == "" 
	print "入出力ファイル名がオプション指定されていません。\n"
	print "usage: postprocessor-pdf.rb --input (-i) inputFileName --output (-o) outputFileName \n"
	exit(0)
end

## 表のCaptionを上に持ち上げる
interText          = ""
taghash            = Hash::new
tableCaptionTagkey = ""
sequence           = 0
putTocFlag         = false

open( inputFileName ) {|f|
	f.each_line {|line|
		line.chomp!
		# tableofcontents周りの処理。"はじめに"は目次に出さない		
		unless putTocFlag 
			if /^\\putTableofcontents/ =~ line
				putTocFlag = true				
				interText.concat("\\tableofcontents\n")				
				next
			end
			#目次に出さない部分は除去
			if /\\addcontentsline/ =~ line || /\\tableofcontents/ =~ line
				next
			end
		end
		
		# \begin{longtable}[c]{@{}lll@{}} を検出
		if /^\s*\\begin\{longtable\}/ =~ line
			#プレースホルダーを設置
			sequence += 1
			tableCaptionTagkey = "TABLE_CAPTION:%d" % sequence
			interText.concat("%s\n" % line)
			interText.concat("%s\n" % tableCaptionTagkey)
			next
		end
		# \caption{[#tagname] キャプション文字列  )、タグは省略可能を検出
		if /^\s*\\caption\{\s*(\\#\S+)?(.+)\}/ =~ line
			tagname   = $1
			caption   = $2
			#テーブルのCaption
			unless tableCaptionTagkey.empty?
				tcapstr = "\\caption{%s}" % caption
				unless tagname.nil?
					tcapstr.concat(" \\label{%s}" % tagname.gsub(/(\#|\\)/, ""))
				end
				taghash[tableCaptionTagkey] = tcapstr + " \\\\"
				tableCaptionTagkey = ""
				next
			end
		end		
		# 索引出力の追加
		if /\\end\{document\}/ =~ line
			interText.concat("\\newpage\n")			
			interText.concat("\\printindex\n")
		end

		# 書き出し。			
		interText.concat("%s\n" % line)
	}
}
# 出力ファイルを作る
outText = ""
interText.each_line {|line|
	line.chomp!
	#キーに登録された行を置換
	if taghash.has_key?(line)
		outText.concat("%s\n" % taghash[line])
		next
	end
	# 書き出し。
	outText.concat("%s\n" % line)
}

# 本文書き出し
f = File::open(outputFileName, "w")
f.write(outText)
f.close
