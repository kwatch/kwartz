##
## variables
##
langs     = %w[eruby php jstl]
suffixes  = %w[rhtml php jsp ]
commands  = %w[ruby  php]
suffixes2 = %w[rb    php]



##
## target files
##
all = []
suffixes.each do |suffix|
  all << "content1.#{suffix}" << "content2.#{suffix}"
end



##
## recipes
##
recipe :all		, all

recipe :default,	'Makefile'			do
	sys "make clean"
	sys "make"
    end

recipe :clean						do
	rm_rf all
    end

recipe :clear						do
	rm_rf all, 'Makefile'
    end


langs.zip(suffixes).each do |lang, suffix|
  recipe "content?.#{suffix}",
		"content.#{lang}.plogic", "content$(1).html",
		"menu.#{lang}.plogic", "menu.html", "layout.html"	do
	n = @matches[1]
	sys "kwartz -l #{lang} -p content.#{lang},menu.#{lang} -i menu.html -L layout.html content#{n}.html > #{@product}"
    end
end

results = []
langs.zip(suffixes, commands, suffixes2).each do |lang, suffix, command, suffix2|
  next unless command
  recipe "result1.#{lang}.html", "main.#{suffix2}", "content1.#{suffix}"	do
        sys "#{command} #{@ingred} > #{@product}"
    end
  recipe "result2.#{lang}.html", "main.#{suffix2}", "content2.#{suffix}"	do
        sys "#{command} #{@ingred} AAPL > #{@product}"
    end
  results << "result1.#{lang}.html" << "result2.#{lang}.html"
end

recipe :results		, results




##
## Makefile
##
s = <<END
ALL = #{all.join(' ')}

all:	${ALL}

clean:
	rm -f ${ALL}

##

result1.eruby.html:  main.rb result1.rhtml
	ruby main.rb > result1.eruby.html

result2.eruby.html:  main.rb result2.rhtml
	ruby main.rb AAPL > result2.eruby.html

result1.php.html:  main.php result1.rhtml
	ruby main.php > result1.php.html

result2.php.html:  main.php result2.rhtml
	ruby main.php AAPL > result2.php.html

##

END

langs.zip(suffixes).each do |lang, suffix|
  [1, 2].each do |n|
    s << "content#{n}.#{suffix}: content.#{lang}.plogic content#{n}.html \\\n"
    s << "              menu.#{lang}.plogic menu.html layout.html\n"
    s << "\tkwartz -l #{lang} -p content.#{lang},menu.#{lang} -i menu.html -L layout.html content#{n}.html > content#{n}.#{suffix}\n"
    s << "\n"
  end
end

makefile_content = s

recipe 'Makefile'					do
	File.open('Makefile', 'w') { |f| f.write(makefile_content) }
	puts "File.open('Makefile', 'w') { |f| f.write(makefile_content) }"
    end

