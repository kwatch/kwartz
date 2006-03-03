#!/usr/local/bin/ruby

require 'yaml'

help = false
lang = 'erb'
while !ARGV.empty? && !ARGV[0].empty? && ARGV[0][0] == ?-
  option = ARGV.shift
  case option
  when '-l'
    lang = ARGV.shift
    raise "-l: argument required." unless lang
  when '-h'
    help = true
  end
end

if help
  command = File.basename($0)
  puts <<END
Usage: #{command} [-h] [-l lang] [datafile.yaml]
END
  exit 0
end


filename = !ARGV.empty? ? ARGV[0] : 'directives.yaml'
sb = ''
YAML.load_documents(File.read(filename)) do |ydoc|
  subject = ydoc['subject']
  pdata   = ydoc['pdata*'][lang]
  sb << "<!-- #{subject} -->\n"
  sb << pdata if pdata
  sb << "\n"
end
print sb

#filename = !ARGV.empty? ? ARGV[0] : 'directives.yaml'
#ydoc = YAML.load_file(filename)
#sb = ''
#ydoc['directives'].each do |hash|
#  subject = hash['subject']
#  pdata   = hash['pdata*'][lang]
#  sb << "<!-- #{subject} -->\n"
#  sb << pdata
#  sb << "\n"
#end
#
#print sb
