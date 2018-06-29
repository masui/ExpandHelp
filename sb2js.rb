# -*- coding: utf-8 -*-
# -*- ruby -*-
#
# Scrapbox.io/GyazoなどのExpandHelp記述を取得してJSに変換
#

require './lib/get'

require 'uri'

name = 'Gyazo'
name = ARGV[0] if ARGV[0]

#
# Glossaryの定義を取得
#
keywords = {}
defs = {}
get("https://scrapbox.io/api/pages/#{name}/glossary/text").split(/\n/).each { |line|
  if line =~ /\[(\S+)\]:\s+(.*)$/
    k = $1
    s = $2
    while s =~ /^(.*)\[([^\]]+)\](.*)$/
      ss = $2
      if defs[ss]
        ss = defs[ss]
      else
        keywords[ss] = true
      end
      s = "#{$1}#{ss}#{$3}"
    end
    defs[k] = s
  end
}

#
# 各ページを取得、'##' の行をさがす
#
entries = []
s = JSON.parse(get("https://scrapbox.io/api/pages/#{name}"))
s['pages'].each { |page|
  title = page['title']
  STDERR.puts "https://scrapbox.io/api/pages/#{name}/#{title}/text"
  get("https://scrapbox.io/api/pages/#{name}/#{title}/text").split(/\n/).each { |line|
    if line =~ /^\s*##\s+(.*)$/
      desc = $1
      while desc =~ /^(.*)\[([^\]]+)\](.*)$/
        ss = $2
        if defs[ss]
          ss = defs[ss]
        else
          keywords[ss] = true
        end
        desc = "#{$1}#{ss}#{$3}"
      end
      while desc =~ /^(.*)#(\w+)(.*)$/
        ss = $2
        # keywords[ss] = true
        ss = defs[ss] if defs[ss]
        desc = "#{$1}#{ss}#{$3}"
      end
      entries.push([desc.force_encoding("utf-8"),title.force_encoding("utf-8")])
    end
  }
}

#
# 結果出力
#

require 'kakasi'

class String
  def yomi
    Kakasi.kakasi('-JH -KH', self).upcase
  end
end

puts "keywords = ["

keywordlist = keywords.keys.map { |key|
  key.dup.force_encoding("utf-8")
}.sort { |a,b|
  a.yomi <=> b.yomi
}
keywordlist.each_with_index { |keyword,ind|
  print "  '#{keyword}'"
  print "," if ind < keywordlist.length-1
  print "\n"
}
puts "];"

require "re_expand"

out = []
entries.each { |entry|
  entry[0].expand.each { |s|
    out << [s, "https://scrapbox.io/Gyazo/#{entry[1]}"]
  }
}
puts "faqs = ["
out.each_with_index { |entry,ind|
  print "  { title:'#{entry[0]}', url:'#{entry[1]}'}"
  print "," if ind < out.length-1
  print "\n"
}
puts "];"

