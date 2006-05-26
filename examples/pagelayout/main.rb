#!/usr/bin/env ruby

## menu
menulist = [
  { :label => 'Mail',     :url => '/cgi-bin/mail.cgi' },
  { :label => 'Calnedar', :url => '/cgi-bin/calendar.cgi' },
  { :label => 'Todo',     :url => '/cgi-bin/todo.cgi' },
  { :label => 'Stock',    :url => '/cgi-bin/stock.cgi' },
]
#table = [
#  ["Mail"     , "/cgi-bin/mail.cgi"],
#  ["Calendar" , "/cgi-bin/calendar.cgi"],
#  ["Todo"     , "/cgi-bin/todo.cgi"],
#  ["Stock"    , "/cgi-bin/stock.cgi"],
#]
#@menulist = table.collect do |label, url|
#  { :label=>label, :url=>url }
#end


## contents data
stocks = [
  { :symbol => "AAPL", :price => 62.94, :rate => -0.23,
    :company => "Apple Computer, Inc." },
  { :symbol => "MSFT", :price => 22.53, :rate => 0.64,
    :company => "Microsoft Corp." },
  { :symbol => "ORCL", :price => 12.89, :rate => -2.02,
    :company => "Oracle Corporation" },
  { :symbol => "SUNW", :price =>  4.12, :rate => 0.28,
    :company => "Sun Microsystems, Inc." },
  { :symbol => "INTC", :price => 18.61, :rate => 1.01,
    :company => "Intel Corporation" },
]
#table = [
#  ["AAPL", 62.94,  1.23, "Apple Computer, Inc."  ],
#  ["MSFT", 22.53,  0.44, "Microsoft Corp."       ],
#  ["ORCL", 12.89, -2.02, "Oracle Corporation"    ],
#  ["SUNW",  4.12,  0.28, "Sun Microsystems, Inc."],
#]
#@stocks = table.collect do |symbol, price, rate, company|
#  { :symbol=>symbol, :price=>price, :rate=>rate, :company=>company }
#end


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
  filename = 'content2.rhtml'
else
  filename = 'content1.rhtml'
end


## context object
context = Object.new
context.instance_variable_set("@menulist", menulist)
context.instance_variable_set("@stocks", stocks)
context.instance_variable_set("@stock", stock) if stock
require 'erb'
context.extend ERB::Util


## output
str = File.open(filename) { |f| f.read() }
trim_mode = 1
erb = ERB.new(str, $SAFE, trim_mode)
print cgi.header if cgi
print context.instance_eval(erb.src, filename)
