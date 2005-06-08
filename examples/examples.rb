#!/usr/bin/env ruby

while line = gets()
   line.gsub!(/&/, '&amp;')
   line.gsub!(/</, '&lt;')
   line.gsub!(/>/, '&gt;')
   line.gsub!(/id=".*?"/, '<b>\&</b>')
   line.gsub!(/@\{.*\}@/, '<b>\&</b>')
   print line
end
