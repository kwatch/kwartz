
result.html:  calendar.php calendar-page.view calendar-month.view
	php -q calendar.php > result.html

%.view:  %.html %.plogic
	kwartz-php -p $*.plogic $< > $@

clean:
	rm -f result.html calendar-page.view calendar-month.view
