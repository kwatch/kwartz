
result.html:	thumbnail.php thumbnail.view
	php -q $< > $@

thumbnail.view: thumbnail.html thumbnail.plogic
	kwartz-php -p thumbnail.plogic $< > $@

clean:
	rm -f result.html thumbnail.view
