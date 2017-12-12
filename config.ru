require 'sinatra'
  
require './expandhelp.rb'

Encoding.default_external = 'utf-8'

run Sinatra::Application
