
breadcrumbs = [
  { :title=>'TOP',          :path=>'/' },
  { :title=>'Kwartz',       :path=>'/kwartz' },
  { :title=>'Examples',     :path=>'/kwartz/examples' },
  { :title=>'breadcrumbs2', :path=>nil },
]
require 'stringio'

_out = StringIO.new; _out << '<html>
  <body>

';     last_index = breadcrumbs.length - 1 
     breadcrumbs.each_with_index do |item, i| 
       if i < last_index 
 _out << '        <a href="'; _out << ( item[:path] ).to_s; _out << '">'; _out << ( item[:title] ).to_s; _out << '</a> &lt;
';       else 
 _out << ( item[:title] ).to_s;       end ; _out << '
';     end 
 _out << '
  </body>
</html>
';
print _out.string
