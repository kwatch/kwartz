#!/usr/bin/ruby

###
### RubyGems Specification file for Kwartz-ruby
###
### $Rev$
### $Release$
### $Copyright$
###

require 'rubygems'

spec = Gem::Specification.new do |s|
  ## package information
  s.name        = 'kwartz-ruby'
  s.author      = 'Makoto Kuwata'
  s.version     = ("$Release: 3.0.0 $" =~ /[\.\d]+/) && $&
  s.platform    = Gem::Platform::RUBY
  s.homepage    = 'http://www.kuwata-lab.com/kwartz'
  s.summary     = "a template system for Ruby, PHP, and Java"
  s.description = <<-'END'
  Kwartz is a template system which realized the concept
  'Independence of Presentation Logic'(IoPL).
  It separates presentation logic (loop, branch, etc) from
  presentation data (typically HTML file), thus HTML design
  is not breaked at all.
  In addition, Kwartz supports Ruby, PHP, and Java.
  END
  
  ## files
  files = []
  files += Dir.glob('lib/**/*')
  files += Dir.glob('bin/**/*')
  files += Dir.glob('examples/**/*')
  files += Dir.glob('test/**/*')
  #files += Dir.glob('man/**/*')
  files += [ "doc/users-guide.html",
             "doc/reference.html",
             "doc/p-pattern.html",
             "doc/docstyle.css",
             "doc/design.css", "doc/design.html", ]
  files += Dir.glob('doc-api/**/*')
  files += %w[README.en.txt README.ja.txt ChangeLog.txt COPYING setup.rb todo.txt]
  s.files       = files
  s.executables = ["kwartz"]
  s.bindir      = "bin"
  s.test_file   = 'test/test.rb'
  s.add_dependency('abstract', ['>= 1.0.0'])
end

if $0 == __FILE__
  Gem::manage_gems
  Gem::Builder.new(spec).build
end
