#!/usr/bin/ruby

## get parameters
require 'cgi'
cgi = CGI.new
name   = cgi.params['name'].first
gender = cgi.params['gender'].first

## check parameters
view_name = 'register.view'
error_list = nil
if cgi.params.length > 0
    ## check input data
    error_list = []
    unless name && !name.empty?
        error_list << 'Name is empty.'
    end
    unless gender == 'M' || gender == 'W'
        error_list << 'Gender is not selected.'
    end

    ## if input parameter is valid then print the finished page.
    ## else print the registration page.
    if error_list.empty?
        error_list = nil
        view_name = 'finish.view'
    end
end

## print web page
require 'erb'
str = File.open(view_name) { |f| f.read }
str.untaint()
trim_mode = 1
print cgi.header
print ERB.new(str, $SAFE, trim_mode).result(binding())
