SCRIPT = ../../kwartz.php

result.html:	breadcrumbs.php breadcrumbs.view
	php -q $< > $@

breadcrumbs.view: breadcrumbs.html breadcrumbs.plogic
	$(SCRIPT) -p breadcrumbs.plogic $< > $@

clean:
	rm -f result.html breadcrumbs.view
