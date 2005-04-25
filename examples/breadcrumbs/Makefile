
result.html:	breadcrumbs.rb breadcrumbs.view
	ruby $< > $@

breadcrumbs.view: breadcrumbs.html breadcrumbs.plogic
	kwartz -p breadcrumbs.plogic $< > $@

clean:
	rm -f result.html breadcrumbs.view
