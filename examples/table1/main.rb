list = [
  { :name=>"Nomo",    :mail=>"hideo@mail.com" },
  { :name=>"Ichiro",  :mail=>"ichiro@mail.net" },
  { :name=>"Matsui",  :mail=>"hideki@mail.org" },
]

require 'erb'
str = File.read('table1.rhtml')
trim_mode = 1
erb = ERB.new(str, $SAFE, trim_mode)
print erb.result(binding())
