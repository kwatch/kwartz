#!/usr/bin/env ruby

while line = gets()
   line.gsub!(/&/, '&amp;')
   line.gsub!(/</, '&lt;')
   line.gsub!(/>/, '&gt;')
   line.gsub!(/id=".*?"/, '<strong>\&</strong>')
   line.gsub!(/@\{.*\}@/, '<strong>\&</strong>')
   print line
end
