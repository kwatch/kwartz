
result.html:  border3.rb border3.view
	ruby border3.rb > result.html

border3.view:	border3.plogic border3.html
	kwartz -l eruby -p border3.plogic border3.html > border3.view

clean:
	rm -f result.html border3.view
