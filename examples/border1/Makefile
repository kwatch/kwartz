
result.html:  border1.rb border1.view
	ruby border1.rb > result.html

border1.view:	border1.html border1.plogic
	kwartz -l eruby -p border1.plogic border1.html > border1.view

clean:
	rm -f result.html border1.view


## --------------------

_test:
	kwartz -l php      -p border1.plogic border1.html > border1.php
	kwartz -l jstl11   -p border1.plogic border1.html > border1.jstl11
	kwartz -l jstl10   -p border1.plogic border1.html > border1.jstl10
	kwartz -l velocity -p border1.plogic border1.html > border1.velocity

_clean:
	rm -rf border1.php border1.jstl11 border1.jstl10 border1.velocity

