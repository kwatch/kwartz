result.html:  main.rb page.view
	ruby main.rb > result.html

page.view: layout.html contents.html contents.plogic
	kwartz -i contents.html -p contents.plogic layout.html > page.view

clean:
	rm -f result.html page.view


## --------------------

_test:
	kwartz -l php      -i contents.html -p contents.plogic layout.html > page.php
	kwartz -l jstl11   -i contents.html -p contents.plogic layout.html > page.jstl11
	kwartz -l jstl10   -i contents.html -p contents.plogic layout.html > page.jstl10
	kwartz -l velocity -i contents.html -p contents.plogic layout.html > page.velocity

_clean:
	rm -f page.php page.jstl11 page.jstl10 page.velocity
