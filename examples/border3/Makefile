
result.html:  border3.rb border3.view
	ruby border3.rb > result.html

border3.view:	border3.plogic border3.html
	kwartz -l eruby -p border3.plogic border3.html > border3.view

clean:
	rm -f result.html border3.view


## --------------------

_test:
	kwartz -l php      -p border3.plogic border3.html > border3.php
	kwartz -l jstl11   -p border3.plogic border3.html > border3.jstl11
	kwartz -l jstl10   -p border3.plogic border3.html > border3.jstl10
	kwartz -l velocity -p border3.plogic border3.html > border3.velocity

_clean:
	rm -f border3.php border3.jstl11 border3.jstl10 border3.velocity
