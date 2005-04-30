#!/usr/bin/ruby

###
### RubyGems Specification file for Kwartz-ruby
###
### $Id$
### $Release$
###

require 'rubygems'

spec = Gem::Specification.new do |s|
  ## package information
  s.name        = 'kwartz-ruby'
  s.author      = 'Makoto Kuwata'
  s.version     = ("$Release: 2.0.0-beta3 $" =~ /Release: ([\.\d]+)/) && $1
  s.platform    = Gem::Platform::RUBY
  s.homepage    = 'http://www.kuwata-lab.com/kwartz'
  s.summary     = "a template system for Ruby, PHP, and Java"
  s.description = <<-'END'
  Kwartz is a template system which realized the concept
  'Separation of Presentation Logic and Presentation Data'(SoPL/PD)
  or 'Independence of Presentation Logic'(IoPL).
  Kwartz generates eRuby, PHP, JSP, and Velocity script from presentation
  data file (tipically HTML file) and presentation logic file.
  Kwartz runs very fast and doesn't break HTML design at all.
  END
  
  ## files
  files = []
  files += Dir.glob('lib/**/*')
  files += Dir.glob('bin/**/*')
  files += Dir.glob('examples/**/*')
  files += Dir.glob('test/**/*')
  files += Dir.glob('man/**/*')
  files += [ "doc/users-guide.en.html", "doc/users-guide.ja.html", 
             "doc/reference.en.html",   "doc/reference.ja.html", 
             "doc/p-pattern.en.html",   "doc/p-pattern.ja.html", 
             "doc/docstyle.css",
             "doc/design.css", "doc/design.html", ]
  files += %w(README.en.txt README.ja.txt ChangeLog.txt COPYING setup.rb todo.txt)
  #s.files       = files.delete_if { |path| path =~ /\.svn/ }
  s.files       = files
  s.executables = ["kwartz", "kwartz-ruby"]
  s.bindir      = "bin"
  s.test_file   = 'test/test.rb'
end

if $0 == __FILE__
  Gem::manage_gems
  Gem::Builder.new(spec).build
end
