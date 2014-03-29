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
	print "usage: preprocessor.rb --input (-i) inputFileName --output (-o) outputFileName \n"
	exit(0)
end

# 1行づつ読み込み、テーブルと図表の番号振り。
sectionNum    = -1
figureNum     = 1
tableNum      = 1
referenceText = ""
interText     = ""
taghash       = Hash::new

open( inputFileName ) {|f|
	f.each {|line|
		# Table: を検出 (Table: [#tagname] キャプション文字列  )、タグは省略可能
		if /^Table:\s*(#\S+)?(.+)/ =~ line
			captionheader = "表 %d.%d" % [sectionNum, tableNum]
			tagname   = $1
			caption   = $2
#print "tagname:" + tagname + "\n"
			unless tagname.nil?
				taghash[tagname] = captionheader
#				interText.concat( "[%s]: %s \"%s\"\n" % [tagname, tagname, captionheader])
#				interText.concat( "<a href=\"%s\"/>\n\n" % tagname)			
			end
			interText.concat( "Table: %s %s\n" % [captionheader, caption])
			tableNum += 1
			next
		end
		# ![ #tagname caption](filepath) を検出。タグは省略可能
		if /^!\[\s*(.+)\s*\]\s*\((.+)\)/ =~ line
			captionheader = "図 %d.%d" % [sectionNum, figureNum]
			tagname = nil
			caption = $1
			linktext= $2
			if /(#\S+)(.+)/ =~ $1
				tagname = $1
				caption = $2
			end
			interText.concat("<div class=\"figure\">")
			unless tagname.nil?
				taghash[tagname] = captionheader
#				interText.concat( "[%s]: %s \"%s\"\n" % [tagname, tagname, captionheader])
#				interText.concat( "<a href=\"%s\"/>\n" % tagname)
			end
			captiontext = "%s %s" % [captionheader, caption]
			interText.concat( "![%s](%s)\n" % [captiontext, linktext])
			interText.concat("<div class=\"figure-caption\">%s</div>" % captiontext)	
			interText.concat("</div>")			
			figureNum += 1
			next
		end	

		# 見出し(行頭が#1つで始まる)を検出
		if /^#\s/ =~ line
#print line
			sectionNum  = sectionNum + 1
			figureNum   = 1
			tableNum    = 1
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
#		outText.concat("%s [%s](%s) %s\n" % [$`, taghash[$1], $1 ,$'])
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
