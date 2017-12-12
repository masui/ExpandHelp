# -*- coding: utf-8 -*-
# -*- ruby -*-

$:.unshift File.expand_path 'lib', File.dirname(__FILE__)

require 'sinatra'
# require 'sinatra/cross_origin'

require 'get'

get '/:name' do |name|
  get("https://scrapbox.io/api/pages/#{name}/glossary/text")
end
