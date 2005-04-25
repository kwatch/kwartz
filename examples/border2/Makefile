
result.html:  border2.rb border2.view
	ruby $< > $@

border2.view:	border2.html border2.plogic
	kwartz -l eruby -p border2.plogic $< > $@

clean:
	rm -f result.html border2.view

