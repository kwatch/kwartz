ALL = breadcrumbs.rhtml breadcrumbs.php breadcrumbs.jsp

all:    ${ALL}

clean:
	rm -f ${ALL}

breadcrumbs.rhtml:     breadcrumbs.eruby.plogic breadcrumbs.html
	kwartz -l eruby -p breadcrumbs.eruby.plogic breadcrumbs.html > breadcrumbs.rhtml

breadcrumbs.php:       breadcrumbs.php.plogic breadcrumbs.html
	kwartz -l php -p breadcrumbs.php.plogic breadcrumbs.html > breadcrumbs.php

breadcrumbs.jsp:       breadcrumbs.jstl.plogic breadcrumbs.html
	kwartz -l jstl -p breadcrumbs.jstl.plogic breadcrumbs.html > breadcrumbs.jsp
