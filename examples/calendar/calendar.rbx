#!/usr/bin/ruby

require 'cgi'
require 'erb'

## set year
cgi = nil
if ENV['REQUEST_METHOD']
   cgi = CGI.new
   year = cgi.params['year'].first
   if year && !year.empty?
      year = year.to_i
   else
      year = Time.new.year
   end
else
   year = Time.new.year
end

## create erb
trim_mode = 1
str = File.open('calendar-month.view') { |f| f.read() }
str.untaint
erb_cal_month = ERB.new(str, $SAFE, trim_mode)
str = File.open('calendar-page.view') { |f| f.read() }
str.untaint
erb_cal_page  = ERB.new(str, $SAFE, trim_mode)

## set calendar_list
calendar_list = []
(1..12).each do |i|
    t = Time.local(year, i, 1)
    month = t.strftime("%B")
    next_month = i == 12 ? Time.local(year+1, 1, 1) : Time.local(year, i+1, 1)
    last_day = next_month - 60*60*24
    num_days = last_day.day
    first_weekday = t.strftime("%w").to_i + 1
    #puts "year=#{year}, month=#{month}, num_days=#{num_days}, first_weekday=#{first_weekday}"
    calendar_list << erb_cal_month.result(binding())
end
#calendar_list.each do |s| print s end

## include main page, with $calendar_list[]
prev_link = "calendar.rbx?year=#{year-1}"
next_link = "calendar.rbx?year=#{year+1}"
column = 4
print cgi.header if cgi
print erb_cal_page.result(binding())
