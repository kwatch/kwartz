###
### $Rev$
### $Release$
### $Copyright$
###



def load_yaml_documents(filename, options={}, &block)
  
  s = File.read(filename)
  if filename =~ /\.rb$/
    s =~ /^__END__$/   or raise "*** error: __END__ is not found in '#{filename}'."
    s = $'
  end
  unless options[:tabify] == false
    sb = ''
    s.each_line do |line|
      sb << line.gsub(/([^\t]{8})|([^\t]*)\t/n) { [$+].pack("A8") }
    end
    s = sb
  end
  
  identkey = options[:identkey] || 'name'
  ydoc_table = {}
  YAML.load_documents(s) do |ydoc|
    ident = ydoc[identkey]
    ident               or  raise "*** #{identkey} is not found."
    ydoc_table[ident]   and raise "*** #{identkey} '#{ident}' is duplicated."
    ydoc_table[ident] = ydoc
    yield(ydoc)
  end
  
  return ydoc_table

end



def load_yaml_testdata(filename, options={})
  identkey   = options[:identkey]   || 'name'
  testmethod = options[:testmethod] || '_test'
  load_yaml_documents(filename, options) do |ydoc|
    ident = ydoc[identkey]
    s  =   "def test_#{ident}\n"
    ydoc.each do |key, val|
      code = "  @#{key} = #{val.inspect}\n"
      s << "  @#{key} = #{val.inspect}\n"
    end
    s  <<  "  #{testmethod}\n"
    s  <<  "end\n"
    $stderr.puts "*** load_yaml_testdata(): eval_str=<<'END'\n#{s}END" if $DEBUG
    eval s
  end
end
