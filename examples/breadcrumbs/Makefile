
result.html:	breadcrumbs.php breadcrumbs.view
	php -q $< > $@

breadcrumbs.view: breadcrumbs.html breadcrumbs.plogic
	kwartz-php -p breadcrumbs.plogic $< > $@

clean:
	rm -f result.html breadcrumbs.view
