result.html:  main.rb page.view
	ruby main.rb > result.html

page.view: layout.html contents.html contents.plogic
	kwartz -o contents.html -p contents.plogic layout.html > page.view

clean:
	rm -f result.html page.view
