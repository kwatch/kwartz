all:	result1.html result2.html

%.view:	%.html page.plogic layout.html menu.html menu.plogic
	kwartz -p menu.plogic,page.plogic -i menu.html,$*.html layout.html > $*.view

result1.html:	main.rb page1.view
	ruby main.rb > result1.html

result2.html:	main.rb page2.view
	ruby main.rb AAPL > result2.html

clean:
	rm -rf result*.html page*.view

