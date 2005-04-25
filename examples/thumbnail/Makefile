
result.html:	thumbnail.rbx thumbnail.view
	ruby $< > $@

thumbnail.view: thumbnail.html thumbnail.plogic
	kwartz -l eruby -p thumbnail.plogic $< > $@

clean:
	rm -f result.html thumbnail.view
