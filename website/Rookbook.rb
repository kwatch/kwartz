property :release, '0.0.0'

U = 'users-guide' unless defined?(U)
R = 'reference'   unless defined?(R)
P = 'p-pattern'   unless defined?(P)

docdir = '../doc'
tagfile = 'xhtml-css'
tmpdir = 'd'


##
##  recipes for kuwata-lab.com
##
products = %W[kwartz3-#{P}.xhtml kwartz3-#{U}.xhtml kwartz3-#{R}.xhtml 
              kwartz3-ruby-README.txt kwartz3-ruby-ChangeLog
	      index.xhtml p-pattern/design.html img]


recipe  :all			, products


recipe  :clean								do |r|
	rm_rf '*.toc.html', "kwartz3-*.txt"
    end


recipe  :clear								do |r|
	rm_rf "kwartz3-*", 'index.xhtml', 'img', 'p-pattern'
    end


recipe	'kwartz3-*.xhtml'	, 'kwartz3-$(1).txt', :byprods=>['$(1).toc.html']  do |r|
	sys "kwaser -t #{tagfile} -bsn -T2 #{@ingred} > #{@byprod}"
	sys "kwaser -t #{tagfile} -bsn     #{@ingred}"
	rm_f @byprod
	m = @matches
	files = Dir.glob("kwartz3-#{m[1]}*.html")
	edit files do |content|
	  content.gsub!(/"(p-pattern|reference|users-guide).html"/, '"kwartz3-\1.html"')
	end
	files.each do |old|
	  new = old.sub(/\.html$/, '.xhtml')
	  mv old, new if old != new
	end
    end


recipe	/^kwartz3-ruby-(README.txt|ChangeLog)$/	, '../$(1)'	do |r|
	cp @ingred, @product
    end


recipe 'kwartz3-*.txt'	, '../doc/$(1).txt'			do |r|
	cp @ingred, @product
    end


recipe '../doc/*.txt'	, '../doc/$(1).eruby'				do |r|
	chdir '../doc' do sys "rook #{@matches[1]}.txt" end
    end


recipe 'p-pattern/design.html'	, "kwartz3-#{P}.txt", :coprods=>['p-pattern/design.css'] do |r|
	mkdir_p tmpdir
	sys "retrieve -d #{tmpdir} #{@ingred}"
	mkdir_p 'p-pattern'
	cp "#{tmpdir}/design.*", 'p-pattern'
	rm_rf tmpdir
    end


recipe 'img'		, '../doc/img'				do |r|
        mkdir_p 'img'
	cp '../doc/img/*.png', 'img'
    end


recipe	'index.xhtml'		, 'index.txt'			do |r|
        sys "kwaser -t #{tagfile} -b #{@ingred} > #{@product}"
    end



