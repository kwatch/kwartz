
result.html:  calendar.rbx calendar-page.view calendar-month.view
	ruby calendar.rbx > result.html

%.view:  %.html %.plogic
	kwartz -p $*.plogic $< > $@

clean:
	rm -f result.html calendar-page.view calendar-month.view


## --------------------

P = calendar-page
M = calendar-month

_test:
	kwartz -l php      -p $P.plogic $P.html > $P.php
	kwartz -l php      -p $M.plogic $M.html > $M.php
#	kwartz -l jstl11   -p $P.plogic $P.html > $P.jstl11
#	kwartz -l jstl11   -p $M.plogic $M.html > $M.jstl11
#	kwartz -l jstl10   -p $P.plogic $P.html > $P.jstl10
#	kwartz -l jstl10   -p $M.plogic $M.html > $M.jstl10
#	kwartz -l velocity -p $P.plogic $P.html > $P.velocity
#	kwartz -l velocity -p $M.plogic $M.html > $M.velocity

_clean:
	rm -f $P.php $M.php
#	rm -f $P.php $M.php $P.jstl11 $M.jstl11 $P.jstl10 $M.jstl10 $P.velocity $M.velocity
