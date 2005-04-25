
all:	register.view finish.view

register.view: register.html register.plogic
	kwartz -l eruby -e -p register.plogic $< > $@

finish.view: finish.html
	kwartz -l eruby -e $< > $@

clean:
	rm -f register.view finish.view
