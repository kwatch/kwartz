#!/usr/bin/ruby

###
### unit test for Converter
###

$: << 'lib'
$: << '../lib'
$: << 'test'

require 'test/unit'
require 'test/unit/ui/console/testrunner'
require 'assert-diff.rb'
require 'kwartz/converter'

class ConverterTest < Test::Unit::TestCase

    $flag_test = true		# do test or not


    ### --------------------
    ### fetch
    ### --------------------
    def _test_fetch(input, expected, flag_test=$flag_test)
	return unless flag_test
	input.gsub!(/^\t\t/, '')
	expected.gsub!(/^\t\t/, '')
	converter = Kwartz::Converter.new(input)
	actual = converter.fetch_all
	#assert_equal(expected, actual)
	assert_equal_with_diff(expected, actual)
    end

    def test_fetch1
	input = <<-END
		<html>
		 <body></body>
		</html>
	END
	expected = <<-'END'
		tag_name:     html
		line_num:     1
		before_text:  ""
		before_space: ""
		attr_str:     ""
		after_space:  "\n"
		
		tag_name:     body
		line_num:     2
		before_text:  ""
		before_space: " "
		attr_str:     ""
		after_space:  ""
		
		tag_name:     /body
		line_num:     2
		before_text:  ""
		before_space: ""
		attr_str:     ""
		after_space:  "\n"
		
		tag_name:     /html
		line_num:     3
		before_text:  ""
		before_space: ""
		attr_str:     ""
		after_space:  "\n"
		
		rest:         ""
		line_num:     4
	END
	_test_fetch(input, expected)
    end


    def test_fetch2
	input = <<-'END'
		<ul id="user">
		 <li kd="value:user">foo</li>
		</ul>
	END
	expected = <<-'END'
		tag_name:     ul
		line_num:     1
		before_text:  ""
		before_space: ""
		attr_str:     " id=\"user\""
		after_space:  "\n"
		
		tag_name:     li
		line_num:     2
		before_text:  ""
		before_space: " "
		attr_str:     " kd=\"value:user\""
		after_space:  ""
		
		tag_name:     /li
		line_num:     2
		before_text:  "foo"
		before_space: ""
		attr_str:     ""
		after_space:  "\n"
		
		tag_name:     /ul
		line_num:     3
		before_text:  ""
		before_space: ""
		attr_str:     ""
		after_space:  "\n"
		
		rest:         ""
		line_num:     4
	END
	_test_fetch(input, expected)
    end


    def test_fetch3
	input = <<-'END'
		aaa
		bbb
		ccc
	END
	expected = <<-'END'
		rest:         "aaa\nbbb\nccc\n"
		line_num:     1
	END
	_test_fetch(input, expected)
    end
    


    def test_fetch4
	input = <<-'END'
		aaa
		bbb
		ccc<b>foo</b>
		ddd<i
		  kd="bar">
		BAR
		</i>
		eee
	END
	expected = <<-'END'
		tag_name:     b
		line_num:     3
		before_text:  "aaa\nbbb\nccc"
		before_space: ""
		attr_str:     ""
		after_space:  ""
		
		tag_name:     /b
		line_num:     3
		before_text:  "foo"
		before_space: ""
		attr_str:     ""
		after_space:  "\n"
		
		tag_name:     i
		line_num:     4
		before_text:  "ddd"
		before_space: ""
		attr_str:     "\n  kd=\"bar\""
		after_space:  "\n"
		
		tag_name:     /i
		line_num:     7
		before_text:  "BAR\n"
		before_space: ""
		attr_str:     ""
		after_space:  "\n"
		
		rest:         "eee\n"
		line_num:     8
	END
	_test_fetch(input, expected)
    end




    ### --------------------
    ### parse_attr_str
    ### --------------------

    def _test_attr(input, expected, flag_test=$flag_test)
    	return unless flag_test
	input.gsub!(/^\t\t/, '')
	expected.gsub!(/^\t\t/, '')
	converter = Kwartz::Converter.new(input)
	converter.fetch()
	converter.parse_attr_str()
	actual = converter.attr_str
	#assert_equal(expected, actual)
	assert_equal_with_diff(expected, actual)
    end


    def test_attr1	# attr
	input = <<-'END'
		<tr id="foo" kd="attr:bgcolor=color;attr:class:klass" class="even">
		</tr>
	END
	expected = ' id="foo" class="#{klass}#" bgcolor="#{color}#"'
	_test_attr(input, expected)
    end

    def test_attr2	# Attr,ATTR
	input = <<-'END'
		<tr id="foo" kd="Attr:bgcolor=color;ATTR:class:klass" class="even">
		</tr>
	END
	expected = ' id="foo" class="#{X(klass)}#" bgcolor="#{E(color)}#"'
	_test_attr(input, expected)
    end


    def test_attr3	# embed,Embed,EMBED
	input = <<-'END'
		<tr id="foo" kd="embed:foo;Embed:bar;EMBED:baz"  class="even">
		</tr>
	END
	expected = ' id="foo"  class="even" #{foo}# #{E(bar)}# #{X(baz)}#'
	_test_attr(input, expected)
    end




    ### --------------------
    ### Converter#convert()
    ### --------------------
    def _test_convert(input, expected, flag_test=$flag_test)
    	return if !flag_test
	input.gsub!(/^\t\t/, '')
	expected.gsub!(/^\t\t/, '')
	converter = Kwartz::Converter.new(input)
	actual = converter.convert()
	#assert_equal(expected, actual)
	assert_equal_with_diff(expected, actual)
    end




    def test_convert01	# text only
    	input = <<-'END'
		aaa
		bbb
		ccc
	END
	expected = <<-'END'
		:print("aaa\n")
		:print("bbb\n")
		:print("ccc\n")
	END
	_test_convert(input, expected)
    end

    def test_convert02	# '#{...}#'
    	input = <<-'END'
		aaa#{expr1}##{expr2}#bbb
		<foo #{checked}#>
	END
	expected = <<-'END'
		:print("aaa", expr1, expr2, "bbb\n")
		:print("<foo ", checked, ">\n")
	END
	_test_convert(input, expected)
    end

    def test_convert03	# tag without directive
    	input = <<-'END'
		<div>
		 <div>
		  <div>hoge</div>
	END
	expected = <<-'END'
		:print("<div>\n")
		:print(" <div>\n")
		:print("  <div>")
		:print("hoge")
		:print("</div>\n")
	END
	_test_convert(input, expected)
    end

    def test_convert04	# attr
    	input = <<-'END'
		<tr class="odd" kd="attr:class:klass;Attr:bgcolor=color;ATTR:align=align">
		</tr>
	END
	expected = <<-'END'
		:print("<tr class=\"", klass, "\" bgcolor=\"", E(color), "\" align=\"", X(align), "\">\n")
		:print("</tr>\n")
	END
	_test_convert(input, expected)
    end

    def test_convert05	# embed
    	input = <<-'END'
		<input type="radio" kd="attr:value:val;embed:checked?'checked':''" />
		<input type="radio" kd="Embed:checked;EMBED:selected"/>
	END
	expected = <<-'END'
		:print("<input type=\"radio\" value=\"", val, "\" ", checked?'checked':'', " />\n")
		:print("<input type=\"radio\" ", E(checked), " ", X(selected), "/>\n")
	END
	_test_convert(input, expected)
    end

    def test_convert06	# invalid directive
    	input = <<-'END'
		<div kd="foo=bar">foobar</div>
	END
	expected = <<-'END'
	END
	assert_raise(Kwartz::ConvertionError) {
	    _test_convert(input, expected)
	}
    end

    def test_convert11	# value
    	input = <<-'END'
		<td kd="value:user">foo</td>
	END
	expected = <<-'END'
		:print("<td>")
		:print(user)
		:print("</td>\n")
	END
	_test_convert(input, expected)
    end

    def test_convert12	# value,Value,VALUE
    	input = <<-'END'
		<td kd="value:user">foo</td>
		<td kd="Value:user">foo</td>
		<td kd="VALUE:user">foo</td>
	END
	expected = <<-'END'
		:print("<td>")
		:print(user)
		:print("</td>\n")
		:print("<td>")
		:print(E(user))
		:print("</td>\n")
		:print("<td>")
		:print(X(user))
		:print("</td>\n")
	END
	_test_convert(input, expected)
    end

    def test_convert13	# value with <span>
    	input = <<-'END'
		<span kd="value:user">foo</span>
	END
	expected = <<-'END'
		##:print("<span>")
		:print(user)
		##:print("</span>\n")
	END
	_test_convert(input, expected)
    end

    def test_convert14	# value with empty element
    	input = <<-'END'
		<span kd="value:user"/>
	END
	expected = ''
	assert_raise(Kwartz::ConvertionError) {
	   _test_convert(input, expected)
	}
    end


    def test_convert21	# foreach
    	input = <<-'END'
		<tr kd="foreach:user:list">
		  <td>#{user}#</td>
		</tr>
	END
	expected = <<-'END'
		:foreach(user=list)
		  :print("<tr>\n")
		  :print("  <td>")
		  :print(user)
		  :print("</td>\n")
		  :print("</tr>\n")
		:end
	END
	_test_convert(input, expected)
    end


    def test_convert22	# Foreach
    	input = <<-'END'
		<tr kd="Foreach:user=list">
		  <td>#{user}#</td>
		</tr>
	END
	expected = <<-'END'
		:set(user_ctr = 0)
		:foreach(user=list)
		  :set(user_ctr += 1)
		  :print("<tr>\n")
		  :print("  <td>")
		  :print(user)
		  :print("</td>\n")
		  :print("</tr>\n")
		:end
	END
	_test_convert(input, expected)
    end

    def test_convert23	# FOREACH
    	input = <<-'END'
		<tr kd="FOREACH:user:list">
		  <td>#{user}#</td>
		</tr>
	END
	expected = <<-'END'
		:set(user_ctr = 0)
		:foreach(user=list)
		  :set(user_ctr += 1)
		  :set(user_tgl = user_ctr%2==0 ? 'even' : 'odd')
		  :print("<tr>\n")
		  :print("  <td>")
		  :print(user)
		  :print("</td>\n")
		  :print("</tr>\n")
		:end
	END
	_test_convert(input, expected)
    end

    def test_convert24	# loop
    	input = <<-'END'
		<tr kd="loop:user=list">
		  <td>#{user}#</td>
		</tr>
	END
	expected = <<-'END'
		:print("<tr>\n")
		:foreach(user=list)
		  :print("  <td>")
		  :print(user)
		  :print("</td>\n")
		:end
		:print("</tr>\n")
	END
	_test_convert(input, expected)
    end

    def test_convert25	# Loop
    	input = <<-'END'
		<tr kd="Loop:user=list">
		  <td>#{user}#</td>
		</tr>
	END
	expected = <<-'END'
		:print("<tr>\n")
		:set(user_ctr = 0)
		:foreach(user=list)
		  :set(user_ctr += 1)
		  :print("  <td>")
		  :print(user)
		  :print("</td>\n")
		:end
		:print("</tr>\n")
	END
	_test_convert(input, expected)
    end

    def test_convert26	# LOOP
    	input = <<-'END'
		<tr kd="LOOP:user:list">
		  <td>#{user}#</td>
		</tr>
	END
	expected = <<-'END'
		:print("<tr>\n")
		:set(user_ctr = 0)
		:foreach(user=list)
		  :set(user_ctr += 1)
		  :set(user_tgl = user_ctr%2==0 ? 'even' : 'odd')
		  :print("  <td>")
		  :print(user)
		  :print("</td>\n")
		:end
		:print("</tr>\n")
	END
	_test_convert(input, expected)
    end


    def test_convert27	# invalid foreach
    	input = <<-'END'
		<tr kd="foreach:user in list">
		  <td>#{user}#</td>
		</tr>
	END
	expected = ''
	assert_raise(Kwartz::ConvertionError) {
	    _test_convert(input, expected)
	}
    end

    def test_convert28	# invalid foreach
    	input = <<-'END'
		<tr kd="loop:user">
		  <td>#{user}#</td>
		</tr>
	END
	expected = ''
	assert_raise(Kwartz::ConvertionError) {
	    _test_convert(input, expected)
	}
    end

    def test_convert29	# loop with empty element
    	input = <<-'END'
		<li kd="loop:user=list"/>
	END
	expected = ''
	assert_raise(Kwartz::ConvertionError) {
	    _test_convert(input, expected)
	}
    end


    def test_convert31	# if
    	input = <<-'END'
		<font color="red" kd="if:error_msg!=null">
		  #{error_msg}#
		</font>
	END
	expected = <<-'END'
		:if(error_msg!=null)
		  :print("<font color=\"red\">\n")
		  :print("  ", error_msg, "\n")
		  :print("</font>\n")
		:end
	END
	_test_convert(input, expected)
    end

    def test_convert32	# else
    	input = <<-'END'
		<tr class="odd" kd="if:ctr%2==1">
		  <td>#{data}#</td>
		</tr>
		<tr class="even" kd="else:">
		  <td>#{data}#</td>
		</tr>
	END
	expected = <<-'END'
		:if(ctr%2==1)
		  :print("<tr class=\"odd\">\n")
		  :print("  <td>")
		  :print(data)
		  :print("</td>\n")
		  :print("</tr>\n")
		:else
		  :print("<tr class=\"even\">\n")
		  :print("  <td>")
		  :print(data)
		  :print("</td>\n")
		  :print("</tr>\n")
		:end
	END
	_test_convert(input, expected)
    end


    def test_convert33	# elseif
    	input = <<-'END'
		<div class="typeA" kd="if:type=='A'">#{message}#</div>
		<div class="typeB" kd="elseif:type=='B'">#{message}#</div>
		<div class="typeC" kd="elsif:type=='C'">#{message}#</div>
		<div class="typeD" kd="else:">#{message}#</div>
	END
	expected = <<-'END'
		:if(type=='A')
		  :print("<div class=\"typeA\">")
		  :print(message)
		  :print("</div>\n")
		:elseif(type=='B')
		  :print("<div class=\"typeB\">")
		  :print(message)
		  :print("</div>\n")
		:elseif(type=='C')
		  :print("<div class=\"typeC\">")
		  :print(message)
		  :print("</div>\n")
		:else
		  :print("<div class=\"typeD\">")
		  :print(message)
		  :print("</div>\n")
		:end
	END
	_test_convert(input, expected)
    end


    def test_convert34	# invalid else
    	input = <<-'END'
		<tr class="odd" kd="if:ctr%2==1">
		  <td>#{data}#</td>
		</tr>
		
		<tr class="even" kd="else:">
		  <td>#{data}#</td>
		</tr>
	END
	expected = ""
	assert_raise(Kwartz::ConvertionError) {
	    _test_convert(input, expected)
	}
    end


    def test_convert35	# nested if
    	input = <<-'END'
		<ul kd="if:type=='A'">
		  <ol kd="if:type=='B'">
		    <li kd="if:type=='C'">#{message}#</li>
		  </ol>
		</ul>
		<ul kd="else:">#{message}#</ul>
	END
	expected = <<-'END'
		:if(type=='A')
		  :print("<ul>\n")
		  :if(type=='B')
		    :print("  <ol>\n")
		    :if(type=='C')
		      :print("    <li>")
		      :print(message)
		      :print("</li>\n")
		    :end
		    :print("  </ol>\n")
		  :end
		  :print("</ul>\n")
		:else
		  :print("<ul>")
		  :print(message)
		  :print("</ul>\n")
		:end
	END
	_test_convert(input, expected)
    end


    def test_convert41	# mark
    	input = <<-'END'
		<table>
		  <tr kd="mark:user">
		    <td>foo</td>
		  </tr>
		</table>
	END
	expected = <<-'END'
		:macro(stag_user)
		  :print("  <tr>\n")
		:end
		:macro(etag_user)
		  :print("  </tr>\n")
		:end
		:macro(cont_user)
		  :print("    <td>")
		  :print("foo")
		  :print("</td>\n")
		:end
		:macro(element_user)
		  :expand(stag_user)
		  :expand(cont_user)
		  :expand(etag_user)
		:end
		
		:print("<table>\n")
		:expand(element_user)
		:print("</table>\n")
	END
	_test_convert(input, expected)
    end


    def test_convert42	# mark by id attr
    	input = <<-'END'
		<table>
		  <tr id="user">
		    <td>foo</td>
		  </tr>
		</table>
	END
	expected = <<-'END'
		:macro(stag_user)
		  :print("  <tr id=\"user\">\n")
		:end
		:macro(etag_user)
		  :print("  </tr>\n")
		:end
		:macro(cont_user)
		  :print("    <td>")
		  :print("foo")
		  :print("</td>\n")
		:end
		:macro(element_user)
		  :expand(stag_user)
		  :expand(cont_user)
		  :expand(etag_user)
		:end
		
		:print("<table>\n")
		:expand(element_user)
		:print("</table>\n")
	END
	_test_convert(input, expected)
    end


    def test_convert43	# id="user-list"
    	input = <<-'END'
		<table>
		  <tr id="user-list">
		    <td>foo</td>
		  </tr>
		</table>
	END
	expected = <<-'END'
		:print("<table>\n")
		:print("  <tr id=\"user-list\">\n")
		:print("    <td>")
		:print("foo")
		:print("</td>\n")
		:print("  </tr>\n")
		:print("</table>\n")
	END
	_test_convert(input, expected)
    end

    def test_convert44	# id and directive
    	input = <<-'END'
		<table>
		  <tr id="user" kd="foreach:user:list">
		    <td>foo</td>
		  </tr>
		</table>
	END
	expected = <<-'END'
		:print("<table>\n")
		:foreach(user=list)
		  :print("  <tr id=\"user\">\n")
		  :print("    <td>")
		  :print("foo")
		  :print("</td>\n")
		  :print("  </tr>\n")
		:end
		:print("</table>\n")
	END
	_test_convert(input, expected)
    end


    def test_convert45	# nested mark
    	input = <<-'END'
		<table>
		 <tbody id="loop">
		  <tr id="mark:user">
		   <td>foo</td>
		  </tr>
		 </tbody>
		</table>
	END
	expected = <<-'END'
		:macro(stag_user)
		    :print("  <tr>\n")
		:end
		:macro(etag_user)
		    :print("  </tr>\n")
		:end
		:macro(cont_user)
		    :print("   <td>")
		    :print("foo")
		    :print("</td>\n")
		:end
		:macro(element_user)
		  :expand(stag_user)
		  :expand(cont_user)
		  :expand(etag_user)
		:end
		:macro(stag_loop)
		  :print(" <tbody id=\"loop\">\n")
		:end
		:macro(etag_loop)
		  :print(" </tbody>\n")
		:end
		:macro(cont_loop)
		  :expand(element_user)
		:end
		:macro(element_loop)
		  :expand(stag_loop)
		  :expand(cont_loop)
		  :expand(etag_loop)
		:end
		
		:print("<table>\n")
		:expand(element_loop)
		:print("</table>\n")
	END
	_test_convert(input, expected)
    end


    def test_convert51	# while
    	input = <<-'END'
		<div kd="while:data=d.fetch">
		  #{data}#
		</div>
	END
	expected = <<-'END'
		:while(data=d.fetch)
		  :print("<div>\n")
		  :print("  ", data, "\n")
		  :print("</div>\n")
		:end
	END
	_test_convert(input, expected)
    end

    def test_convert52	# set
    	input = <<-'END'
		<div kd="set:ctr=0"/>
		<div kd="set:ctr+=1"/>
		<div id="set:ctr:-1"/>
	END
	expected = <<-'END'
		:set(ctr=0)
		:print("<div/>\n")
		:set(ctr+=1)
		:print("<div/>\n")
		:set(ctr = -1)
		:print("<div/>\n")
	END
	_test_convert(input, expected)
    end

    def test_convert53	# set with <span>
    	input = <<-'END'
		<span kd="set:ctr+=1"/>
	END
	expected = <<-'END'
		:set(ctr+=1)
		##:print("<span/>\n")
	END
	_test_convert(input, expected)
    end

    def test_convert54	# set & attr
    	input = <<-'END'
		<span kd="set:ctr+=1;attr:class=foo"/>
	END
	expected = <<-'END'
		:set(ctr+=1)
		:print("<span class=\"", foo, "\"/>\n")
	END
	_test_convert(input, expected)
    end

    def test_convert55	# dummy
    	input = <<-'END'
		<td id="dummy:d1">
		  foo
		</td>
	END
	expected = <<-'END'
		
	END
	_test_convert(input, expected)
    end

    def test_convert56	# replace
    	input = <<-'END'
		<div kd="replace:foo">
		foo
		</div>
	END
	expected = <<-'END'
		:expand(element_foo)
	END
	_test_convert(input, expected)
    end



    def test_convert91	# practical example
    	input = <<-'END'
		<table>
		 <tbody id="Loop:user:user_list">
		  <tr class="odd" id="if:user_ctr%2==1">
		   <td id="value:user[:name]">foo</td>
		   <td id="value:user[:mail]">foo</td>
		  </tr>
		  <tr class="even" id="else:">
		   <td id="value:user[:name]">foo</td>
		   <td id="value:user[:mail]">foo</td>
		  </tr>
		  <tr class="odd" id="dummy:">
		   <td id="value:user[:name]">foo</td>
		   <td id="value:user[:mail]">foo</td>
		  </tr>
		 </tbody>
		</table>
	END
	expected = <<-'END'
		:print("<table>\n")
		:print(" <tbody>\n")
		:set(user_ctr = 0)
		:foreach(user=user_list)
		  :set(user_ctr += 1)
		  :if(user_ctr%2==1)
		    :print("  <tr class=\"odd\">\n")
		    :print("   <td>")
		    :print(user[:name])
		    :print("</td>\n")
		    :print("   <td>")
		    :print(user[:mail])
		    :print("</td>\n")
		    :print("  </tr>\n")
		  :else
		    :print("  <tr class=\"even\">\n")
		    :print("   <td>")
		    :print(user[:name])
		    :print("</td>\n")
		    :print("   <td>")
		    :print(user[:mail])
		    :print("</td>\n")
		    :print("  </tr>\n")
		  :end
		:end
		:print(" </tbody>\n")
		:print("</table>\n")
	END
	_test_convert(input, expected)
    end


    def test_convert92	# practical example
    	input = <<-'END'
		<table>
		 <tbody id="LOOP:user:user_list">
		  <tr class="odd" id="attr:class:user_tgl">
		   <td id="value:user[:name]">foo</td>
		   <td id="value:user[:mail]">foo@mail.com</td>
		  </tr>
		  <tr class="even" id="dummy:d1">
		   <td>bar</td>
		   <td>bar@mail.org</td>
		  </tr>
		  <tr class="odd" id="dummy:d2">
		   <td>baz</td>
		   <td>baz@mail.net</td>
		  </tr>
		 </tbody>
		</table>
	END
	expected = <<-'END'
		:print("<table>\n")
		:print(" <tbody>\n")
		:set(user_ctr = 0)
		:foreach(user=user_list)
		  :set(user_ctr += 1)
		  :set(user_tgl = user_ctr%2==0 ? 'even' : 'odd')
		  :print("  <tr class=\"", user_tgl, "\">\n")
		  :print("   <td>")
		  :print(user[:name])
		  :print("</td>\n")
		  :print("   <td>")
		  :print(user[:mail])
		  :print("</td>\n")
		  :print("  </tr>\n")
		:end
		:print(" </tbody>\n")
		:print("</table>\n")
	END
	_test_convert(input, expected)
    end

end

if $0 == __FILE__
    Test::Unit::UI::Console::TestRunner.run(ConverterTest)
    #suite = Test::Unit::TestSuite.new()
    #suite << ConverterTest.suite()
    #Test::Unit::UI::Console::TestRunner.run(suite)
end
