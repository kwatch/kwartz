
result.html:	thumbnail.rbx thumbnail.view
	ruby $< > $@

thumbnail.view: thumbnail.html thumbnail.plogic
	kwartz -l eruby -p thumbnail.plogic $< > $@

clean:
	rm -f result.html thumbnail.view


## --------------------

_test:
	kwartz -l php      -p thumbnail.plogic thumbnail.html > thumbnail.php
	kwartz -l jstl11   -p thumbnail.plogic thumbnail.html > thumbnail.jstl11
	kwartz -l jstl10   -p thumbnail.plogic thumbnail.html > thumbnail.jstl10
	kwartz -l velocity -p thumbnail.plogic thumbnail.html > thumbnail.velocity

_clean:
	rm -f thumbnail.php thumbnail.jstl11 thumbnail.jstl10 thumbnail.velocity
