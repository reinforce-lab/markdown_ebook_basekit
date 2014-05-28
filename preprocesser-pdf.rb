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
	print "usage: preprocessor-pdf.rb --input (-i) inputFileName --output (-o) outputFileName \n"
	exit(0)
end

referenceText = ""
interText     = ""
taghash       = Hash::new

open( inputFileName ) {|f|
	f.each {|line|
		# Table: を検出 (Table: [#tagname] キャプション文字列  )、タグは省略可能
		if /^Table:\s*(#\S+)?(.+)/ =~ line
#			captionheader = "表 %d.%d" % [sectionNum, tableNum]
			tagname   = $1
			caption   = $2
			unless tagname.nil?
				tagwosharp       = tagname.gsub(/\#/, "")
				taghash[tagname] = "表 \\ref{%s}" % tagwosharp
			end
			interText.concat( "Table: %s %s\n" % [tagname, caption])
#			tableNum += 1
			next
		end
		# ![ #tagname caption](filepath) を検出。タグは省略可能
		if /^!\[\s*(.+)\s*\]\s*\((.+)\)/ =~ line
			tagname = nil
			caption = $1
			linktext= $2
			if /(#\S+)(.+)/ =~ $1
				tagname = $1
				caption = $2
			end
			# 図表の開始コマンドを出力
			interText.concat("\\begin{figure}[htbp]\n\\centering\n")
			interText.concat( "\\includegraphics{%s}\n" % linktext)
			interText.concat("\\caption{%s}\n" % caption)
			unless tagname.nil?
				tagwosharp = tagname.gsub(/\#/, "")
				taghash[tagname] = "図 \\ref{%s}" % tagwosharp
				interText.concat("\\label{%s}\n" % tagwosharp)
			end			
			# 図表の終了コマンドを出力
			interText.concat("\\end{figure}\n")
			next
		end	

		# 書き出し。
		interText.concat("%s" % line)
	}
}
# 出力ファイルを作る
outText = ""
interText.each_line {|line|
# Table: を検出 (Table: [#tagname] キャプション文字列  )、タグは省略可能
	if /\[\s*(#\S+)\s*\]/ =~ line
		if taghash[$1].nil?
			print "Warning: unknown tag, %s .\n" % $1
		end
		outText.concat("%s %s %s" % [$`, taghash[$1] ,$'])
	next
	end
	# 書き出し。
	outText.concat("%s" % line)
}

# 本文書き出し

f = File::open(outputFileName, "w")
f.write(outText)
f.close
