property :release, '0.0.0'

U = 'users-guide'      unless defined?(U)
R = 'reference'        unless defined?(R)
P = 'pattern-catalog'  unless defined?(P)
prefix = 'kwartz3ruby'

docdir = '../doc'
tagfile = 'site-design'
tmpdir = 'd'


##
##  recipes for kuwata-lab.com
##
products = %W[#{prefix}-#{P}.xhtml #{prefix}-#{U}.xhtml #{prefix}-#{R}.xhtml 
              #{prefix}-README.txt #{prefix}-ChangeLog
	      index.xhtml #{P}/design.html img]


recipe  :all			, products


recipe  :clean								do |r|
	rm_rf '*.toc.html', "#{prefix}-*.txt"
    end


recipe  :clear								do |r|
	rm_rf "#{prefix}-*", 'index.xhtml', 'img', "#{P}"
    end


recipe	"#{prefix}-*.xhtml"	, "#{prefix}-$(1).txt", :byprods=>['$(1).toc.html']  do |r|
	sys "kwaser -t #{tagfile} -bsn -T2 #{@ingred} > #{@byprod}"
	sys "kwaser -t #{tagfile} -bsn     #{@ingred}"
	rm_f @byprod
	files = Dir.glob("#{prefix}-#{@m[1]}*.html")
	edit files do |content|
	  content.gsub!(/"(pattern-catalog|reference|users-guide).html"/, "\"#{prefix}-\\1.html\"")
	  content.sub!(/"docstyle\.css"/, '"site-design.css"')
	end
	files.each do |old|
	  new = old.sub(/\.html$/, '.xhtml')
	  mv old, new if old != new
	end
    end


recipe	/^#{prefix}-(README.txt|ChangeLog)$/	, '../$(1)'	do |r|
	cp @ingred, @product
    end


recipe "#{prefix}-*.txt"	, '../doc/$(1).txt'			do |r|
	cp @ingred, @product
    end


recipe '../doc/*.txt'	, '../doc/$(1).eruby'				do |r|
	chdir '../doc' do sys "rook #{@m[1]}.txt" end
    end


recipe "#{P}/design.html"	, "#{prefix}-#{P}.txt", :coprods=>["#{P}/design.css"] do |r|
	mkdir_p tmpdir
	sys "retrieve -d #{tmpdir} #{@ingred}"
	mkdir_p "#{P}"
	cp "#{tmpdir}/design.*", "#{P}"
	rm_rf tmpdir
    end


recipe 'img'		, '../doc/img'				do |r|
        mkdir_p 'img'
	cp '../doc/img/*.png', 'img'
    end


recipe	'index.xhtml'		, 'index.txt'			do |r|
        sys "kwaser -t #{tagfile} -b #{@ingred} > #{@product}"
    end



