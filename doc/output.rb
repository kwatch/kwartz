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
KWARTZ_NOEXEC = true
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
    'erb'    => 'ERB',
    'jstl'   => 'JSTL',
    'jstl11' => 'JSTL 1.1',
    'jstl10' => 'JSTL 1.0',
}

nl = nil
lang_list.each do |lang|
   print nl if nl
   name = names[lang]
   print "### for #{name}\n"
   argv = args.dup
   if pos
      argv[pos] = lang
   else
      argv[0,0] = '-l'
      argv[1,0] = lang
   end
   argv[0,0] = '--header=false' if lang == 'jstl'
   kwartz = Kwartz::MainCommand.new(argv)
   output = kwartz.main()
   print output
   nl = output[-1] == ?\n ? "\n" : "\n\n"
end
