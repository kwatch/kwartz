#!/usr/bin/ruby


filename = nil
ENV['PATH'].split(/:/).each do |path|
   filename = "#{path}/kwartz"
   break if test(?f, filename)
   filename = nil
end
unless filename
   $stderr.puts "*** kwartz command not found."
   exit(1)
end

script = File.open(filename) { |f| f.read }
eval script


args = []
langs = nil
pos = nil
ARGV.each_with_index do |arg, i|
   if arg == '-l'
      pos = i + 1
      langs = ARGV[pos]
   elsif i == pos
      arg = '**dummy**'
   end
   args << arg
end

lang_list = langs ? langs.split(/,/) : [ 'eruby', 'php', 'jstl' ]

names = {
    'php'    => 'PHP',
    'eruby'  => 'eRuby',
    'jstl'   => 'JSTL 1.1 & 1.0',
    'jstl11' => 'JSTL 1.1',
    'jstl10' => 'JSTL 1.0',
}

lang_list.each_with_index do |lang, i|
   print "\n" if i > 0
   name = names[lang]
   print "### for #{name}\n"
   argv = args.dup
   if pos
      argv[pos] = lang
   else
      argv[0,0] = '-l'
      argv[1,0] = lang
   end
   kwartz = Kwartz::MainCommand.new(argv)
   kwartz.main()
end
