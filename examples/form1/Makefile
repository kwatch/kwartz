
all:	register.view finish.view

register.view: register.html register.plogic
	kwartz -l eruby -e -p register.plogic $< > $@

finish.view: finish.html
	kwartz -l eruby -e $< > $@

clean:
	rm -f register.view finish.view


## --------------------

R = register
F = finish

_test:
	kwartz -l php      -e -p $R.plogic $R.html > $R.php
	kwartz -l php      -e              $F.html > $F.php
	kwartz -l jstl11   -e -p $R.plogic $R.html > $R.jstl11
	kwartz -l jstl11   -e              $F.html > $F.jstl11
	kwartz -l jstl10   -e -p $R.plogic $R.html > $R.jstl10
	kwartz -l jstl10   -e              $F.html > $F.jstl10
	kwartz -l velocity -e -p $R.plogic $R.html > $R.velocity
	kwartz -l velocity -e              $F.html > $F.velocity
	
_clean:
	rm -f $R.php $F.php $R.jstl11 $F.jstl11 $R.jstl10 $F.jstl10 $R.velocity $F.velocity
