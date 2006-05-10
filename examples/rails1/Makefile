
kwartz = kwartz -l rails

ALL = _form.rhtml layout.rhtml new.rhtml edit.rhtml show.rhtml list.rhtml

all:   $(ALL)

clean:
	rm -f $(ALL)

check:
	for i in $(ALL) ; do \
	  cmd="erb -xT - $$i | ruby -ne 'print \$$line; \$$line=\$$_' | ruby -wc" ; \
	  echo -n $$i ' ... '; \
	  eval $$cmd; \
	done
#	  echo $$cmd ; \

_form.rhtml:   form.plogic form.html
	$(kwartz) -x form_content -p form.plogic form.html > _form.rhtml

layout.rhtml:  form.plogic form.html
	$(kwartz) -p form.plogic form.html > layout.rhtml

new.rhtml:  new.html new.plogic form.html
	$(kwartz) -x page_content -p new.plogic -i form.html new.html > new.rhtml

edit.rhtml:  edit.html edit.plogic form.html
	$(kwartz) -x page_content -p edit.plogic -i form.html edit.html > edit.rhtml

show.rhtml:  show.html show.plogic
	$(kwartz) -x page_content -p show.plogic show.html > show.rhtml

list.rhtml:  list.html list.plogic
	$(kwartz) -x page_content -p list.plogic list.html > list.rhtml

