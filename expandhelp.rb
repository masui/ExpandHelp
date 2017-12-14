# -*- coding: utf-8 -*-
# -*- ruby -*-

$:.unshift File.expand_path 'lib', File.dirname(__FILE__)

require 'sinatra'
# require 'sinatra/cross_origin'
require 'json'

require 'get'

require 'uri'

get '/Gyazo' do
  erb :gyazo
end

get '/:name' do |name|
  puts "GET name=#{name}"
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
	keywords[ss] = true
	ss = defs[ss] if defs[ss]
	s = "#{$1}#{ss}#{$3}"
      end
      defs[k] = s
    end
  }
  out = []
  s = JSON.parse(get("https://scrapbox.io/api/pages/#{name}"))
  s['pages'].each { |page|
    puts "https://scrapbox.io/api/pages/#{name}/#{page['title']}/text"
    get("https://scrapbox.io/api/pages/#{name}/#{page['title']}/text").split(/\n/).each { |line|
      if line =~ /^\s*##\s+(.*)$/
        desc = $1
        while desc =~ /^(.*)\[([^\]]+)\](.*)$/
          ss = $2
          keywords[ss] = true
          ss = defs[ss] if defs[ss]
          desc = "#{$1}#{ss}#{$3}"
        end
	while desc =~ /^(.*)#(\w+)(.*)$/
          ss = $2
          keywords[ss] = true
          ss = defs[ss] if defs[ss]
          desc = "#{$1}#{ss}#{$3}"
        end
        out.push desc.force_encoding("utf-8")
      end
    }
  }
  out.join("------")
end
