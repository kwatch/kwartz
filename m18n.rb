#!/usr/bin/ruby

###
### usage:  ruby m18n.rb -l lang [file.txt]
###   -l lang:  JA, EN, etc..
###


## parse command-line options
options = {}
while ARGV[0][0] == ?-
   opt = ARGV.shift
   case opt
   when '-h'
      options[opt] = true
   when '-l'
      optarg = ARGV.shift
      unless optarg
	 raise "#{opt}: argument required."
      end
      options[opt] = optarg
   else
      raise "#{opt}: invalid option."
   end
end

## print help
if options['-h']
   command = File::basename($0)
   s =  <<END
Usage: #{command} [-h] [-l lang] [file.txt ...]
  -h      : help
  -l lang : JA, EN, etc...
END
   $stderr.puts s
   exit 0
end

## set lang
lang = options['-l']
unless lang
   raise "lang is not specified."
end

## main loop
while line = gets()
   case line
   when /^\.([a-zA-Z]+)\t/
      line = $1 == lang ? $' : nil
   when /^\.\t/
      line = $'
   end
   print line if line
end

#[EOF]
