
result.html:  border1.php border1.view
	php -q border1.php > result.html

border1.view:	border1.html border1.plogic
	kwartz-php -l php -p border1.plogic border1.html > border1.view

clean:
	rm -f result.html border1.view
