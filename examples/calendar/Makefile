
SCRIPT = ../../kwartz.php

result.html:  calendar.php calendar-page.view calendar-month.view
	php -q calendar.php > result.html

%.view:  %.html %.plogic
	php -q $(SCRIPT) -p $*.plogic $< > $@

clean:
	rm -f result.html calendar-page.view calendar-month.view
