
SCRIPT = ../../kwartz.php

result.html:  border2.php border2.view
	php -q $< > $@

border2.view:	border2.html border2.plogic
	php -q $(SCRIPT) -l php -p border2.plogic $< > $@

clean:
	rm -f result.html border2.view
