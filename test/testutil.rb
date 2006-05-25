###
### $Rev$
### $Release$
### $Copyright$
###

require 'yaml'


def load_yaml_documents(filename, options={}, &block)

  str = File.read(filename)
  if filename =~ /\.rb$/
    str =~ /^__END__$/   or raise "*** error: __END__ is not found in '#{filename}'."
    str = $'
  end
  unless options[:tabify] == false
    width=8
    sb = []
    str.scan(/(.*?)\t/m) do |s, |
      len = (n = s.rindex(?\n)) ? s.length - n - 1 : s.length
      sb << s << (" " * (width - len % width))
    end
    str = (sb << $').join if $'
  end

  identkey = options[:identkey] || 'name'
  list = []
  table = {}

  YAML.load_documents(str) do |ydoc|
    if ydoc.is_a?(Hash)
      list << ydoc
    elsif ydoc.is_a?(Array)
      list += ydoc
    else
      raise "*** invalid ydoc: #{ydoc.inspect}"
    end
  end

  list.each do |ydoc|
    ident = ydoc[identkey]
    ident         or  raise "*** #{identkey} is not found."
    table[ident]  and raise "*** #{identkey} '#{ident}' is duplicated."
    table[ident] = ydoc
    yield(ydoc) if block
  end

  return list

end



def load_yaml_testdata(filename, options={})

  $stderr.puts "*** debug: load_yaml_testdata(): self=#{self.inspect}" if $DEBUG
  identkey   = options[:identkey]   || 'name'
  testmethod = options[:testmethod] || '_test'
  load_yaml_documents(filename, options) do |ydoc|
    ident = ydoc[identkey]
    s  =   "def test_#{ident}\n"
    ydoc.each do |key, val|
      s << "  @#{key} = #{val.inspect}\n"
    end
    s  <<  "  #{testmethod}\n"
    s  <<  "end\n"
    $stderr.puts "*** load_yaml_testdata(): eval_str=<<'END'\n#{s}END" if $DEBUG
    module_eval s   # not eval!
  end

end
