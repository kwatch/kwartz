
all =  recipes.rhtml list.rhtml show.rhtml new.rhtml edit.rhtml

all:	${all}

%.rhtml:   %.html %.plogic
	kwartz -Rails -e -p $*.plogic --extract=content $*.html > $@

recipes.rhtml: recipes.html recipes.plogic
	kwartz -Rails -e -p recipes.plogic recipes.html > recipes.rhtml

clean:
	rm -f ${all}

