#!/usr/bin/env ruby

##
## $Rev$
## $Release$
## $Copyright$
##

## help
script = File.basename($0)
help_msg = <<END
Usage: ruby #{script} [-h] [-f template.eruby] testdata.yaml
END

## parse command-line options
template = nil
flag_help = false
while ARGV[0] && ARGV[0][0] == ?-
  opt = ARGV.shift
  case opt
  when '-f'
    template = ARGV.shift
    raise "-f: template filename required." unless template
  when '-h'
    flag_help = true
  else
    raise "#{opt}: invalid option."
  end
end

## help message
if flag_help
  $stdout.print help_msg
  exit 0
end

## testdata check
testdata = ARGV[0]
raise "testdata filename not specified." unless testdata
raise "#{testdata}: testadata file not found." unless test(?f, testdata)

## template check
#raise "you must specify template filename with '-f' option." unless template
template = testdata.sub(/\.yaml\z/, '') + ".eruby" unless template
raise "#{options[:template]}: template file not found." unless test(?f, template)

## read test data
#s = ""
#ARGF.read().each_line do |line|
#  s << line.gsub(/([^\t]{8})|([^\t]*)\t/n) { [$+].pack("A8") }
#end
s = ARGF.read()

## parse test data
require 'yaml'
docs = []
doc_table = {}
YAML.load_documents(s) do |doc|
  ## duplicate check
  name = doc['name']
  raise "name is empty." unless name
  raise "name '#{name}' is duplicated." if doc_table[name]
  doc_table[name] = doc
  ## doc['expected*'] => doc['expected']
  doc.each do |key, value|
    if key =~ /(.*)\*\z/
      raise "value should be a hash" unless value.is_a?(Hash)
      doc[$1] = value["java"]
    end
  end
  ##
  #doc['expected'].gsub!(/\n\z/, '') if doc['expected']
  docs << doc
end

## load template
require 'erb'
def eval_erb(_erb, context)
  return _erb.result(binding())
end
context = { :docs => docs }
trim_mode = '<>'
erb = ERB.new(File.read(template), $SAFE, trim_mode)
result = eval_erb(erb, context)
print result
