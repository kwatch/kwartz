###
### $Rev$
### $Release$
### $Copyright$
###

unless defined?(TESTDIR)
  TESTDIR = File.dirname(File.expand_path(__FILE__))
  basedir = File.dirname(TESTDIR)
  libdir  = basedir + "/lib"
  $LOAD_PATH << libdir << TESTDIR
end

require 'test/unit'
require 'yaml'
require 'kwartz/util/test-util'
require 'kwartz/util/assert-text-equal'
require 'kwartz/parser'


class RubyStyleParserTest < Test::Unit::TestCase

  ## define test methods
  #filename = __FILE__.sub(/\.rb$/, '.yaml')
  filename = __FILE__
  load_yaml_testdata(filename)

  #
  #str = File.read(__FILE__)
  #str.gsub!(/.*^__END__$/m, '')
  #
  #@@ydocs = {}
  #YAML.load_documents(str) do |ydoc|
  #  name = ydoc['name']
  #  raise "*** test name '#{name}' is duplicated." if @@ydocs[name]
  #  ydoc.each do |key, val|
  #    if key[-1] == ?*
  #      key = key.sub(/\*\z/, '')
  #      val = val[$target]
  #      ydoc[key] = val
  #    end
  #  end
  #  @@ydocs[name] = ydoc
  #  s = <<-END
  #    def test_#{name}
  #      @name    = #{name.dump}
  #      _test()
  #    end
  #  END
  #  eval s
  #end


  def _test
    parser = Kwartz::RubyStyleParser.new()
    if @name =~ /scan/
      actual = ''
      parser._initialize(@input)
      while parser.scan() != nil
        actual << "#{parser.linenum}:#{parser.column}:"
        actual << " token=#{parser.token.inspect}, value=#{parser.value.inspect}\n"
      end
    else
      rulesets = parser.parse(@input)
      actual = ''
      rulesets.each do |ruleset|
        s = ruleset._inspect(1)
        s[0] = '-'
        actual << s
      end if rulesets
    end
    assert_text_equal(@expected, actual)
  end

  

end

__END__
---
name:  scanner1
input: |
  element "list" {
    value
    attrs
    append
    plogic {
    }
  }
expected: |
  1:8: token=:element, value="element"
  1:15: token=:string, value="list"
  1:17: token=:"{", value="{"
  2:8: token=:value, value="value"
  3:8: token=:attrs, value="attrs"
  4:9: token=:append, value="append"
  5:9: token=:plogic, value="plogic"
  5:11: token=:"{", value="{"
  6:4: token=:"}", value="}"
  7:2: token=:"}", value="}"
#
---
name:  parse_elem1
input: |
  element "list" {
  }
expected: |
  - name: "list"
    value: 
    attrs: 
    append: 
    remove: 
    tagname: 
    plogic: 
#
---
name:  parse_value_part1
desc:  value part
input: |
  element "list" {
    value @user['name']
  }
expected: |
  - name: "list"
    value: "@user['name']"
    attrs: 
    append: 
    remove: 
    tagname: 
    plogic: 
#
---
name:  parse_attrs_part1
input: |
  element "list" {
    attrs  "class"=>@class, 'color' => @prop[:color]
  }
expected: |
  - name: "list"
    value: 
    attrs: 
      - name:  "class"
        value: "@class"
      - name:  "color"
        value: "@prop[:color]"
    append: 
    remove: 
    tagname: 
    plogic: 
---
name:  parse_append_part1
input: |
  element "list" {
    append  @name==item['name'] ? " checked='checked'" : '', chk(@name)
  }
expected: |
  - name: "list"
    value: 
    attrs: 
    append: 
      - "@name==item['name'] ? \" checked='checked'\" : ''"
      - "chk(@name)"
    remove: 
    tagname: 
    plogic: 
#
---
name:  parse_remove_part1
input: |
  element "list" {
    remove "foo", "bar", 'baz'
  }
expected: |
  - name: "list"
    value: 
    attrs: 
    append: 
      - "foo"
      - "bar"
      - "baz"
    remove: 
    tagname: 
    plogic: 
#
---
name:  parse_tag_part1
input: |
  element "list" {
    tag   'html:html'
  }
expected: |
  - name: "list"
    value: 
    attrs: 
    append: 
    remove: 
    tagname: "'html:html'"
    plogic: 
#
---
name:  parse_plogic_part1
input: |
  element "list" {
    plogic {
      @list.each { |item|
        _stag
        _cont
        _etag
      }
    }
  }
expected: |
  - name: "list"
    value: 
    attrs: 
    append: 
    remove: 
    tagname: 
    plogic: 
      - "    @list.each { |item|\n"
      - _stag
      - _cont
      - _etag
      - "    }\n"
#
---
name:  parse_plogic_part2
input: |
  element "list" {
    plogic {
      @list.each_with_index { |item, i|
        if i % 2 == 0
          _element("foo")
        else
          _content('foo')
        end
      }
    }
  }
expected: |
  - name: "list"
    value: 
    attrs: 
    append: 
    remove: 
    tagname: 
    plogic: 
      - "    @list.each_with_index { |item, i|\n"
      - "      if i % 2 == 0\n"
      - _element("foo")
      - "      else\n"
      - _content("foo")
      - "      end\n"
      - "    }\n"
#
---
name:  parse_element_all1
input: |
  element "list" {
    value   item.name
    attrs   'class'=>klass, 'title'=>item.desc
    append  item==current_item ? ' checked="checked"' : ''
    plogic  {
      @list.each_with_index { |item, i|
        klass = i % 2 == 0 ? 'even' : 'odd'
        _stag     # start tag
        _cont     # content
        _etag     # end tag
      }
    }
  }
expected: |
  - name: "list"
    value: "item.name"
    attrs: 
      - name:  "class"
        value: "klass"
      - name:  "title"
        value: "item.desc"
    append: 
      - "item==current_item ? ' checked=\"checked\"' : ''"
    remove: 
    tagname: 
    plogic: 
      - "    @list.each_with_index { |item, i|\n"
      - "      klass = i % 2 == 0 ? 'even' : 'odd'\n"
      - _stag
      - _cont
      - _etag
      - "    }\n"
