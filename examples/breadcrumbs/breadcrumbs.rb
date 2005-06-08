#!/usr/bin/ruby

## set breadcrumbs
breadcrumbs = [
   { :name => "HOME",        :path => "/", },
   { :name => "Kwartz",      :path => "/kwartz/", },
   { :name => "Examples",    :path => "/kwartz/examples/", },
   { :name => "Breadcrumbs", :path => "/kwartz/examples/breadcrumbs/", },
]

## set title
title = 'Result';

## display view
require 'erb'
filename = 'breadcrumbs.view'
str = File.open(filename) { |f| f.read }  ## or File.read(filename)
trim_mode = 2
ERB.new(str, $SAFE, trim_mode).run(binding())
