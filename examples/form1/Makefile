
all:	register.view finish.view

%.view:	%.html
	kwartz-php -l php -s $< > $@

#register.view: register.html
#	kwartz-php -l php -s $< > $@

#finish.view: finish.html
#	kwartz-php -l php -s $< > $@

clean:
	rm -f register.view finish.view
