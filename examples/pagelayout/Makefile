ALL = content1.rhtml content2.rhtml content1.php content2.php content1.jsp content2.jsp

all:	${ALL}

clean:
	rm -f ${ALL}

##

result1.eruby.html:  main.rb content1.rhtml
	ruby main.rb > result1.eruby.html

result2.eruby.html:  main.rb content2.rhtml
	ruby main.rb AAPL > result2.eruby.html

result1.php.html:  main.php content1.php
	php main.php > result1.php.html

result2.php.html:  main.php content2.php
	php main.php AAPL > result2.php.html

##

content1.rhtml: content.eruby.plogic content1.html \
              menu.eruby.plogic menu.html layout.html
	kwartz-php -l eruby -p content.eruby,menu.eruby -i menu.html -L layout.html content1.html > content1.rhtml

content2.rhtml: content.eruby.plogic content2.html \
              menu.eruby.plogic menu.html layout.html
	kwartz-php -l eruby -p content.eruby,menu.eruby -i menu.html -L layout.html content2.html > content2.rhtml

content1.php: content.php.plogic content1.html \
              menu.php.plogic menu.html layout.html
	kwartz-php -l php -p content.php,menu.php -i menu.html -L layout.html content1.html > content1.php

content2.php: content.php.plogic content2.html \
              menu.php.plogic menu.html layout.html
	kwartz-php -l php -p content.php,menu.php -i menu.html -L layout.html content2.html > content2.php

content1.jsp: content.jstl.plogic content1.html \
              menu.jstl.plogic menu.html layout.html
	kwartz-php -l jstl -p content.jstl,menu.jstl -i menu.html -L layout.html content1.html > content1.jsp

content2.jsp: content.jstl.plogic content2.html \
              menu.jstl.plogic menu.html layout.html
	kwartz-php -l jstl -p content.jstl,menu.jstl -i menu.html -L layout.html content2.html > content2.jsp

