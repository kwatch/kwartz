
SCRIPT = ../../kwartz.php

all:	register.view finish.view

%.view:	%.html
	php -q $(SCRIPT) -l php -s $< > $@

#register.view: register.html
#	php -q $(SCRIPT) -l php -s $< > $@

#finish.view: finish.html
#	php -q $(SCRIPT) -l php -s $< > $@

clean:
	rm -f register.view finish.view
