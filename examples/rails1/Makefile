
all = list.rhtml show.rhtml new.rhtml edit.rhtml

all:	${all}

%.rhtml:   %.html recipes.html recipes.plogic
	kwartz -Rails -p recipes.plogic -e -i $< recipes.html > $@

clean:
	rm -f ${all}

