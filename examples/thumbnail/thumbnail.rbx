#!/usr/bin/ruby

## get parameters
params = {}
cgi = nil
if ENV['REQUEST_METHOD']
   require 'cgi'
   cgi = CGI.new
   cgi.params.each do |key, value|
      params[key] = value.first
   end
end

## set url format of images
base_url  = "http://www.kuwata-lab.com/kwartz/kwartz-overview/images";
image_url_format = "#{base_url}/image%02d.png";

## get parameters
first = 1
last  = 20
page = params['page']
if (!page || page.empty?)
   page = 0
else
   page = page.to_i
   page = 0 unless first <= page && page <= last
end

## set URLs of previous, next, first, last, and index page
script = cgi ? cgi.script_name : File::basename(__FILE__)
prev_url  = page > first ? "#{script}?page=#{page-1}" : nil
next_url  = page < last  ? "#{script}?page=#{page+1}" : nil
first_url = page > first ? "#{script}?page=#{first}"  : nil
last_url  = page < last  ? "#{script}?page=#{last}"   : nil
index_url = page != 0    ? "#{script}?page=0"         : nil

##
if page > 0
   image_url = image_url_format % page
elsif page == 0
   thumb_list = []
   (first..last).each do |i|
      image_url = image_url_format % i
      link_url  = "#{script}?page=#{i}"
      thumb_list << { :image_url => image_url, :link_url => link_url }
   end
else
   # internal error
end

## load view
require 'erb'
str = File.open('thumbnail.view') { |f| f.read() }
str.untaint
trim_mode = 2
print cgi.header if cgi
ERB.new(str, $SAFE, trim_mode).run(binding())
