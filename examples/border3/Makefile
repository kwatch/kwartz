
SCRIPT = ../../kwartz.php

result.html:  border3.php border3.view
	php -q border3.php > result.html

border3.view:	border3.html
	php -q $(SCRIPT) -l php border3.html > border3.view

clean:
	rm -f result.html border3.view
