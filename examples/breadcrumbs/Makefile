
result.html:	breadcrumbs.rb breadcrumbs.view
	ruby $< > $@

breadcrumbs.view: breadcrumbs.html breadcrumbs.plogic
	kwartz -p breadcrumbs.plogic $< > $@

clean:
	rm -f result.html breadcrumbs.view


## --------------------

_test:
	kwartz -l php      -p breadcrumbs.plogic breadcrumbs.html > breadcrumbs.php
	kwartz -l jstl11   -p breadcrumbs.plogic breadcrumbs.html > breadcrumbs.jstl11
	kwartz -l jstl10   -p breadcrumbs.plogic breadcrumbs.html > breadcrumbs.jstl10
	kwartz -l velocity -p breadcrumbs.plogic breadcrumbs.html > breadcrumbs.velocity


_clean:
	rm -f breadcrumbs.php breadcrumbs.jstl11 breadcrumbs.jstl10 breadcrumbs.velocity
