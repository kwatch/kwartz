#!/usr/bin/env ruby

## menu
menulist = [
  { :label => 'Mail',     :url => '/cgi-bin/mail.cgi' },
  { :label => 'Calnedar', :url => '/cgi-bin/calendar.cgi' },
  { :label => 'Todo',     :url => '/cgi-bin/todo.cgi' },
  { :label => 'Stock',    :url => '/cgi-bin/stock.cgi' },
]

## contents data
stocks = [
  { :symbol => "AAPL", :price => 36.49, :rate => -0.32,
    :company => "Apple Computer, Inc."},
  { :symbol => "MSFT", :price => 26.53, :rate => 1.44,
    :company => "Microsoft Corp."},
  { :symbol => "ORCL", :price => 12.59, :rate => -2.02,
    :company => "Oracle Corporation"},
  { :symbol => "SUNW", :price =>  3.62, :rate => 0.28,
    :company => "Sun Microsystems, Inc." },
  { :symbol => "INTC", :price => 19.51, :rate => 2.90,
    :company => "Interl Corporation" },
]

## page filename
cgi = nil
symbol = nil
if ENV['SCRIPT_NAME']
  require 'cgi'
  cgi = CGI.new
  symbol = cgi.params['symbol'].first
elsif ARGV[0]
  symbol = ARGV[0]
end
if symbol
  stock = stocks.find { |hash| hash[:symbol] == symbol }
  filename = 'page2.view'
else
  filename = 'page1.view'
end

## output
require 'erb'
str = File.open(filename) { |f| f.read() }
trim_mode = 1
erb = ERB.new(str, $SAFE, trim_mode)
print cgi.header if cgi
print erb.result(binding())
