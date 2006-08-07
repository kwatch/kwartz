###
### $Rev$
### $Release$
### $Copyright$
###

module Kwartz


  module Util


    module_function



    ##
    ## expand tab characters to spaces
    ##
    def untabify(str, width=8)
      list = str.split(/\t/)
      last = list.pop
      buf = []
      list.each do |s|
        column = (pos = s.rindex(?\n)) ? s.length - pos - 1 : s.length
        n = width - (column % width)
        buf << s << (" " * n)
      end
      buf << last
      return buf.join
    end
    #--
    #def untabify(str, width=8)
    #  sb = ''
    #  str.scan(/(.*?)\t/m) do |s, |
    #    len = (n = s.rindex(?\n)) ? s.length - n - 1 : s.length
    #    sb << s << (" " * (width - len % width))
    #  end
    #  return $' ? (sb << $') : str
    #end
    #++


    ##
    ## convert hash's key string into symbol.
    ##
    ## ex.
    ##   hash = YAML.load_file('foo.yaml')
    ##   intern_hash_keys(hash)
    ##
    def intern_hash_keys(obj, done={})
      return if done.key?(obj.__id__)
      case obj
      when Hash
        done[obj.__id__] = obj
        obj.keys.each do |key|
          obj[key.intern] = obj.delete(key) if key.is_a?(String)
        end
        obj.values.each do |val|
          intern_hash_keys(val, done) if val.is_a?(Hash) || val.is_a?(Array)
        end
      when Array
        done[obj.__id__] = obj
        obj.each do |val|
          intern_hash_keys(val, done) if val.is_a?(Hash) || val.is_a?(Array)
        end
      end
    end


    ##
    ## convert string pattern into regexp.
    ## metacharacter '*' and '?' are available.
    ##
    ## ex.
    ##   pattern_to_regexp('*.html')    #=> /\A(.*)\.html\z/
    ##
    def pattern_to_regexp(pattern)
      i = 0
      len = pattern.length
      s = '\A'
      while i < len
        case ch = pattern[i]
        when ?\\  ;  s << Regexp.escape(pattern[i+=1].chr)
        when ?*   ;  s << '(.*)'
        when ??   ;  s << '(.)'
        else      ;  s << Regexp.escape(ch.chr)
        end
        i += 1
      end
      s << '\z'
      return Regexp.compile(s)
    end


    ##
    ## select items from list with patterns.
    ##
    ## ex.
    ##   patterns = %w[user_*]
    ##   names = %w[user_name user_age error_msg]
    ##   select_with_patterns(list, patterns)   #=> ['user_name', 'user_age']
    ##
    def select_with_patterns(list, patterns)
      regexp_list = patterns.collect { |pattern| pattern_to_regexp(pattern) }
      return list.select { |item| regexp_list.any? { |rexp| rexp =~ item } }
    end


  end


end
