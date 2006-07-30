ALL = table1.rhtml table1.php table1.jsp

all:    ${ALL}

clean:
	rm -f ${ALL}

table1.rhtml:     table1.eruby.plogic table1.html
	kwartz-php -l eruby -p table1.eruby.plogic table1.html > table1.rhtml

table1.php:       table1.php.plogic table1.html
	kwartz-php -l php -p table1.php.plogic table1.html > table1.php

table1.jsp:       table1.jstl.plogic table1.html
	kwartz-php -l jstl -p table1.jstl.plogic table1.html > table1.jsp
