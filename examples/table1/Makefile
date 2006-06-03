ALL = table1.rhtml table1.php table1.jsp
COMMAND = kwartz-php

all:    ${ALL}

clean:
	rm -f ${ALL}

table1.rhtml:     table1.eruby.plogic table1.html
	$(COMMAND) -l eruby -p table1.eruby.plogic table1.html > table1.rhtml

table1.php:       table1.php.plogic table1.html
	$(COMMAND) -l php -p table1.php.plogic table1.html > table1.php

table1.jsp:       table1.jstl.plogic table1.html
	$(COMMAND) -l jstl -p table1.jstl.plogic table1.html > table1.jsp
