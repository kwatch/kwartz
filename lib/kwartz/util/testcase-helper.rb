###
### $Rev$
### $Release$
### $Copyright$
###

require 'yaml'
require 'test/unit/testcase'


class Test::Unit::TestCase   # :nodoc:


  def self._untabify(str, width=8)         # :nodoc:
    list = str.split(/\t/, -1)
    return list.first if list.length == 1
    last = list.pop
    buf = []
    list.each do |s|
      column = (pos = s.rindex(?\n)) ? s.length - pos - 1 : s.length
      n = width - (column % width)
      buf << s << (" " * n)
    end
    buf << last
    return buf.join
    #sb = []
    #str.scan(/(.*?)\t/m) do |s, |
    #  len = (n = s.rindex(?\n)) ? s.length - n - 1 : s.length
    #  sb << s << (" " * (width - len % width))
    #end
    #str = (sb << $').join if $'
    #return str
  end


  def self.load_yaml_documents(filename, options={})   # :nodoc:
    str = File.read(filename)
    if filename =~ /\.rb$/
      str =~ /^__END__$/   or raise "*** error: __END__ is not found in '#{filename}'."
      str = $'
    end
    str = _untabify(str) unless options[:tabify] == false
    #
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
    #
    list.each do |ydoc|
      ident = ydoc[identkey]
      ident         or  raise "*** #{identkey} is not found."
      table[ident]  and raise "*** #{identkey} '#{ident}' is duplicated."
      table[ident] = ydoc
    end
    #
    target = $target || ENV['TEST']
    if target
       table[target] or raise "*** target '#{target}' not found."
       list = [ table[target] ]
    end
    #
    list.each do |ydoc| yield(ydoc) end if block_given?
    #
    return list
  end


  SPECIAL_KEYS = %[exception errormsg]

  def self.load_yaml_testdata(filename, options={})   # :nodoc:
    identkey   = options[:identkey]   || 'name'
    testmethod = options[:testmethod] || '_test'
    lang       = options[:lang]
    special_keys = options[:special_keys] || SPECIAL_KEYS
    load_yaml_documents(filename, options) do |ydoc|
      ident = ydoc[identkey]
      s  =   "def test_#{ident}\n"
      ydoc.each do |key, val|
        if key[-1] == ?*
          key = key[0, key.length-1]
          k = special_keys.include?(key) ? 'ruby' : lang
          val = val[k]
        end
        s << "  @#{key} = #{val.inspect}\n"
      end
      s  <<  "  #{testmethod}\n"
      s  <<  "end\n"
      #$stderr.puts "*** #{method_name()}(): eval_str=<<'END'\n#{s}END" if $DEBUG
      module_eval s   # not eval!
    end
  end


  def self.method_name   # :nodoc:
    return (caller[0] =~ /in `(.*?)'/) && $1
  end


  def self.load_yaml_testdata_with_each_lang(filename, options={})   # :nodoc:
    identkey   = options[:identkey]   || 'name'
    testmethod = options[:testmethod] || '_test'
    special_keys = options[:special_keys] || SPECIAL_KEYS
    langs = defined?($lang) && $lang ? [ $lang ] : options[:langs]
    langs or raise "*** #{method_name()}(): option ':langs' is required."

    load_yaml_documents(filename, options) do |ydoc|
      ident = ydoc[identkey]
      langs.each do |lang|
        s  =   "def test_#{ident}_#{lang}\n"
        s  <<  "  @lang = #{lang.inspect}\n"
        ydoc.each do |key, val|
          if key[-1] == ?*
            key = key[0, key.length-1]
            k = special_keys.include?(key) ? 'ruby' : lang
            val = val[k]
          end
          s << "  @#{key} = #{val.inspect}\n"
        end
        s  <<  "  #{testmethod}\n"
        s  <<  "end\n"
        #$stderr.puts "*** #{method_name()}(): eval_str=<<'END'\n#{s}END" if $DEBUG
        module_eval s   # not eval!
      end
    end
  end


end
