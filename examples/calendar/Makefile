
result.html:  calendar.rbx calendar-page.view calendar-month.view
	ruby calendar.rbx > result.html

%.view:  %.html %.plogic
	kwartz -p $*.plogic $< > $@

clean:
	rm -f result.html calendar-page.view calendar-month.view
