#!/usr/bin/ruby

## set breadcrumbs
breadcrumbs = [
   { :name => 'HOME',        :path => '/', },
   { :name => 'Kwartz',      :path => '/kwartz/', },
   { :name => 'Examples',    :path => '/kwartz/examples/', },
   { :name => 'Breadcrumbs', :path => '/kwartz/examples/breadcrumbs/', },
]

## set title
title = 'Result';

## display view
require 'erb'
str = File.open('breadcrumbs.view') { |f| f.read }
trim_mode = 2
ERB.new(str, $SAFE, trim_mode).run(binding())
