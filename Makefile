# .PHONY: helpdata.js

gyazohelp.js:
	ruby sb2js.rb Gyazo > public/javascripts/gyazodata.js

run: compile
	ruby expandhelp.rb

compile:
	browserify -c -t coffee-reactify public/javascripts/gyazo.cjsx > public/javascripts/gyazo.js
