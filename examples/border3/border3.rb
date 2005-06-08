#!/usr/bin/ruby

## set user list
user_list = [
  { "name" => "sumire", "email" => "voilet@mail.com" },
  { "name" => "nana",   "email" => "seven@mail.com" },
  { "name" => "momoko", "email" => "peach@mail.com" },
  { "name" => "kasumi", "email" => "mist@mail.com" },
]

## display view
require 'erb'
filename = 'border3.view'
str = File.open(filename) { |f| f.read }  ## or File.read(filename)
trim_mode = 1
erb = ERB.new(str, $SAFE, trim_mode)
print erb.result(binding())
