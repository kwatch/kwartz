
all:	register.view finish.view

register.view: register.html register.plogic
	kwartz -l eruby -s -p register.plogic $< > $@

finish.view: finish.html
	kwartz -l eruby -s $< > $@

clean:
	rm -f register.view finish.view
