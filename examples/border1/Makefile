
result.html:  border1.rb border1.view
	ruby border1.rb > result.html

border1.view:	border1.html border1.plogic
	kwartz -l eruby -p border1.plogic border1.html > border1.view

clean:
	rm -f result.html border1.view
