#!/usr/bin/env ruby

## menu
menu_list = [
  { :name => 'Mail',     :url => '/cgi-bin/mail.cgi' },
  { :name => 'Calnedar', :url => '/cgi-bin/calendar.cgi' },
  { :name => 'Todo',     :url => '/cgi-bin/todo.cgi' },
]

## title
title = "My Homepage"

## output
require 'erb'
filename = 'page.view'
str = File.open(filename) { |f| f.read() }
trim_mode = 1
erb = ERB.new(str, $SAFE, trim_mode)
print erb.result(binding())
