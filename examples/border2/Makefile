
result.html:  border2.rb border2.view
	ruby $< > $@

border2.view:	border2.html border2.plogic
	kwartz -l eruby -p border2.plogic $< > $@

clean:
	rm -f result.html border2.view


## --------------------

_test:
	kwartz -l php      -p border2.plogic border2.html > border2.php
	kwartz -l jstl11   -p border2.plogic border2.html > border2.jstl11
	kwartz -l jstl10   -p border2.plogic border2.html > border2.jstl10
	kwartz -l velocity -p border2.plogic border2.html > border2.velocity

_clean:
	rm -f border2.php border2.jstl11 border2.jstl10 border2.velocity

