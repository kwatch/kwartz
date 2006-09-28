breadcrumbs = [
  { :title=>'TOP',          :path=>'/' },
  { :title=>'Kwartz',       :path=>'/kwartz' },
  { :title=>'Examples',     :path=>'/kwartz/examples' },
  { :title=>'breadcrumbs',  :path=>nil },
]

require 'erb'
str = File.read('breadcrumbs.rhtml')
trim_mode = 1
erb = ERB.new(str, $SAFE, trim_mode)
print erb.result(binding())
