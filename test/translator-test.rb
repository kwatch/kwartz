#!/usr/bin/ruby

###
### unit test for Translator
###
### $Id$
###

$: << 'lib'
$: << '../lib'
$: << 'test'

require 'test/unit'
require 'test/unit/ui/console/testrunner'
require 'assert-diff.rb'
require 'kwartz/parser'
require 'kwartz/translator'
require 'kwartz/translator/eruby'
require 'kwartz/translator/php'
require 'kwartz/translator/jstl'


##
## translator test
##
class TranslatorTest < Test::Unit::TestCase

   def setup
      @flag_suspend = false
   end

   def _test(method_name, input, expected, properties={})
      s = caller()[1]
      s =~ /in `(.*)'/          #'
      testmethod = $1
      if testmethod =~ /_(eruby|php|jstl11|jstl10)$/
         lang = $1
      else
         raise "invalid testmethod name (='#{testmethod}')"
      end
      parser = Kwartz::Parser.new(input, properties)
      block_stmt = parser.__send__(method_name)
      translator = Kwartz::Translator.create(lang, properties)
      actual = translator.translate(block_stmt)
      assert_equal_with_diff(expected, actual)
   end

   def _test_expr(input, expected, properties={})
      _test('parse_expression', input, expected, properties)
   end

   def _test_stmt(input, expected, properties={})
      _test('parse_program', input, expected, properties)
   end
   

   ## ======================================== expression

   ## ---------------------------- literal
   @@literal1 = '1'
   def test_literal1_eruby
      expected = '1'
      _test_expr(@@literal1, expected)
   end
   def test_literal1_php
      expected = '1'
      _test_expr(@@literal1, expected)
   end
   def test_literal1_jstl11
      expected = '1'
      _test_expr(@@literal1, expected)
   end
   def test_literal1_jstl10
      expected = '1'
      _test_expr(@@literal1, expected)
   end


   @@literal2 = '"str\'s\r\n"'
   def test_literal2_eruby
      expected = '"str\'s\r\n"'
      _test_expr(@@literal2, expected)
   end
   def test_literal2_php
      expected = '"str\'s\r\n"'
      _test_expr(@@literal2, expected)
   end
   def test_literal2_jstl11
      expected = '"str\'s\r\n"'
      _test_expr(@@literal2, expected)
   end
   def test_literal2_jstl10
      expected = '"str\'s\r\n"'
      _test_expr(@@literal2, expected)
   end


#   #@@literal3 = "'str" + '\' + "'s\"\r\n'"
#   @@literal3 = %Q|'str\\\'s\r\n'|
#   def test_literal3_eruby
#      expected = '"str\'s\"\r\n"'
#      _test_expr(@@literal3, expected)
#   end
#   def test_literal3_php
#      expected = '"str\'s\"\r\n"'
#      _test_expr(@@literal3, expected)
#   end
#   def test_literal3_jstl11
#      expected = '"str\'s\"\r\n"'
#      _test_expr(@@literal3, expected)
#   end
#   def test_literal3_jstl10
#      expected = '"str\'s\"\r\n"'
#      _test_expr(@@literal3, expected)
#   end

   @@literal4 = "true"
   def test_literal4_eruby
      expected = "true"
      _test_expr(@@literal4, expected)
   end
   def test_literal4_php
      expected = "TRUE"
      _test_expr(@@literal4, expected)
   end
   def test_literal4_jstl11
      expected = "true"
      _test_expr(@@literal4, expected)
   end
   def test_literal4_jstl10
      expected = "true"
      _test_expr(@@literal4, expected)
   end


   @@literal5 = "false"
   def test_literal5_eruby
      expected = "false"
      _test_expr(@@literal5, expected)
   end
   def test_literal5_php
      expected = "FALSE"
      _test_expr(@@literal5, expected)
   end
   def test_literal5_jstl11
      expected = "false"
      _test_expr(@@literal5, expected)
   end
   def test_literal5_jstl10
      expected = "false"
      _test_expr(@@literal5, expected)
   end


   @@literal6 = "null"
   def test_literal6_eruby
      expected = "nil"
      _test_expr(@@literal6, expected)
   end
   def test_literal6_php
      expected = "NULL"
      _test_expr(@@literal6, expected)
   end
   def test_literal6_jstl11
      expected = "null"
      _test_expr(@@literal6, expected)
   end
   def test_literal6_jstl10
      expected = "null"
      _test_expr(@@literal6, expected)
   end



   ## ---------------------------- unary, binary

   @@expression1 = 'a + b * c - d % e'
   def test_expression1_eruby
      expected = 'a + b * c - d % e'
      _test_expr(@@expression1, expected)
   end
   def test_expression1_php
      expected = '$a + $b * $c - $d % $e'
      _test_expr(@@expression1, expected)
   end
   def test_expression1_jstl11
      expected = 'a + b * c - d % e'
      _test_expr(@@expression1, expected)
   end


   @@expression2 = 'a * (b+c) % (d.+e)'
   def test_expression2_eruby
      expected = 'a * (b + c) % (d + e)'
      _test_expr(@@expression2, expected)
   end
   def test_expression2_php
      expected = '$a * ($b + $c) % ($d . $e)'
      _test_expr(@@expression2, expected)
   end
   def test_expression2_jstl11
      expected = 'a * (b + c) % (fn:join(d,e))'
      _test_expr(@@expression2, expected)
   end


   @@expression3 = '- 2 * b'
   def test_expression3_eruby
      expected = '-2 * b'
      _test_expr(@@expression3, expected)
   end
   def test_expression3_php
      expected = '-2 * $b'
      _test_expr(@@expression3, expected)
   end
   def test_expression3_jstl11
      expected = '-2 * b'
      _test_expr(@@expression3, expected)
   end


   ## ---------------------------- assignment

   @@assign1 = 'a = 10'
   def test_assign1_eruby
      expected = 'a = 10'
      _test_expr(@@assign1, expected)
   end
   def test_assign1_php
      expected = '$a = 10'
      _test_expr(@@assign1, expected)
   end
#   def test_assign1_jstl11
#      expected = 'a = 10'
#      _test_expr(@@assign1, expected)
#   end


   @@assign2 = 'a += i+1'
   def test_assign2_eruby
      expected = 'a += i + 1'
      _test_expr(@@assign2, expected)
   end
   def test_assign2_php
      expected = '$a += $i + 1'
      _test_expr(@@assign2, expected)
   end
#   def test_assign2_jstl11
#      expected = 'a += i + 1'
#      _test_expr(@@assign2, expected)
#   end


   @@assign3 = 'a[i] *= a[i-2]+a[i-1]'
   def test_assign3_eruby
      expected = 'a[i] *= a[i - 2] + a[i - 1]'
      _test_expr(@@assign3, expected)
   end
   def test_assign3_php
      expected = '$a[$i] *= $a[$i - 2] + $a[$i - 1]'
      _test_expr(@@assign3, expected)
   end
#   def test_assign3_jstl11
#      expected = 'a[i] *= a[i - 2] + a[i - 1]'
#      _test_expr(@@assign3, expected)
#   end


   @@assign4 = "a[:name] .+= 's1'.+'s2'"
   def test_assign4_eruby
      expected = 'a[:name] += "s1" + "s2"'
      _test_expr(@@assign4, expected)
   end
   def test_assign4_php
      expected = "$a['name'] .= \"s1\" . \"s2\""
      _test_expr(@@assign4, expected)
   end
#   def test_assign4_jstl11
#      expected = "a['name'] .= \"s1\" . \"s2\""
#      _test_expr(@@assign4, expected)
#   end


   ## ---------------------------- function

   @@function1 = 'list = list_new()'
   def test_function1_eruby
      expected = 'list = []'
      _test_expr(@@function1, expected)
   end
   def test_function1_php
      expected = '$list = array()'
      _test_expr(@@function1, expected)
   end
#   def test_function1_jstl11
#      expected = 'list = array()'
#      _test_expr(@@function1, expected)
#   end


   @@function2 = 'hash = hash_new()'
   def test_function2_eruby
      expected = 'hash = {}'
      _test_expr(@@function2, expected)
   end
   def test_function2_php
      expected = '$hash = array()'
      _test_expr(@@function2, expected)
   end
#   def test_function2_jstl11
#      expected = 'hash = array()'
#      _test_expr(@@function2, expected)
#   end


   @@function3 = 'list_length(list) + str_length(str)'
   def test_function3_eruby
      expected = 'list.length + str.length'
      _test_expr(@@function3, expected)
   end
   def test_function3_php
      expected = 'count($list) + strlen($str)'
      _test_expr(@@function3, expected)
   end
   def test_function3_jstl11
      expected = 'fn:length(list) + fn:length(str)'
      _test_expr(@@function3, expected)
   end


   @@function4 = 'list_empty(list) && hash_empty(hash) && str_empty(str)'
   def test_function4_eruby
      expected = 'list.empty? && hash.empty? && str.empty?'
      _test_expr(@@function4, expected)
   end
   def test_function4_php
      expected = 'count($list)==0 && count($hash)==0 && $str'
      _test_expr(@@function4, expected)
   end
   def test_function4_jstl11
      expected = 'fn:length(list)==0 and fn:length(hash)==0 and fn:length(str)==0'
      _test_expr(@@function4, expected)
   end


   @@function5 = 'str_trim(s) .+ str_toupper(s) .+ str_tolower(s) .+ str_index(s, "x")'
   def test_function5_eruby
      expected = 's.trim + s.upcase + s.downcase + s.index("x")'
      _test_expr(@@function5, expected)
   end
   def test_function5_php
      expected = 'trim($s) . strtoupper($s) . strtolower($s) . strstr($s, "x")'
      _test_expr(@@function5, expected)
   end
   def test_function5_jstl11
      expected = 'fn:join(fn:join(fn:join(fn:trim(s),fn:toUpperCase(s)),fn:toLowerCase(s)),fn:indexOf(s, "x"))'
      _test_expr(@@function5, expected)
   end


   @@function6 = 'list_length(hash_keys(hash))'
   def test_function6_eruby
      expected = 'hash.keys.length'
      _test_expr(@@function6, expected)
   end
   def test_function6_php
      expected = 'count(array_keys($hash))'
      _test_expr(@@function6, expected)
   end
   def test_function6_jstl11
      expected = ''
      assert_raise(Kwartz::TranslationError) do
         _test_expr(@@function6, expected)
      end
   end


   ## ---------------------------- conditional op

   @@conditional1 = 'x > y ? x : y'
   def test_conditional1_eruby
      expected = 'x > y ? x : y'
      _test_expr(@@conditional1, expected)
   end
   def test_conditional1_php
      expected = '$x > $y ? $x : $y'
      _test_expr(@@conditional1, expected)
   end
   def test_conditional1_jstl11
      input = 'x > y ? x : y'
      expected = 'x gt y ? x : y'
      _test_expr(@@conditional1, expected)
   end


   @@conditional2 = 'klass = (i+=1)%2==0?"#FFCCCC":"#CCCCFF"'
   def test_conditional2_eruby
      expected = 'klass = (i += 1) % 2 == 0 ? "#FFCCCC" : "#CCCCFF"'
      _test_expr(@@conditional2, expected)
   end
   def test_conditional2_php
      expected = '$klass = ($i += 1) % 2 == 0 ? "#FFCCCC" : "#CCCCFF"'
      _test_expr(@@conditional2, expected)
   end
#   def test_conditional2_jstl11
#      expected = 'klass = (i += 1) % 2 == 0 ? "#FFCCCC" : "#CCCCFF"'
#      _test_expr(@@conditional2, expected)
#   end



   ## ======================================== statement

   ## ---------------------------- expression statement

   @@expr_stmt1 = "a = 1;"
   def test_expr_stmt1_eruby	# numeric
      expected = "<% a = 1 %>\n"
      _test_stmt(@@expr_stmt1, expected)
   end
   def test_expr_stmt1_php	# numeric
      expected = "<?php $a = 1; ?>\n"
      _test_stmt(@@expr_stmt1, expected)
   end
   def test_expr_stmt1_jstl11	# numeric
      expected = '<c:set var="a" value="1"/>' + "\n"
      _test_stmt(@@expr_stmt1, expected)
   end
   def test_expr_stmt1_jstl10	# numeric
      expected = '<c:set var="a" value="1"/>' + "\n"
      _test_stmt(@@expr_stmt1, expected)
   end


   @@expr_stmt2 = 's = "foo";'
   def test_expr_stmt2_eruby	# string
      expected = "<% s = \"foo\" %>\n"
      _test_stmt(@@expr_stmt2, expected)
   end
   def test_expr_stmt2_php	# string
      expected = "<?php $s = \"foo\"; ?>\n"
      _test_stmt(@@expr_stmt2, expected)
   end
   def test_expr_stmt2_jstl11	# string
      expected = '<c:set var="s" value="foo"/>' + "\n"
      _test_stmt(@@expr_stmt2, expected)
   end
   def test_expr_stmt2_jstl10	# string
      expected = '<c:set var="s" value="foo"/>' + "\n"
      _test_stmt(@@expr_stmt2, expected)
   end


   @@expr_stmt3 = 'v *= a[i]+1;'
   def test_expr_stmt3_eruby	# *=
      expected = "<% v *= a[i] + 1 %>\n"
      _test_stmt(@@expr_stmt3, expected)
   end
   def test_expr_stmt3_php	# *=
      expected = "<?php $v *= $a[$i] + 1; ?>\n"
      _test_stmt(@@expr_stmt3, expected)
   end
   def test_expr_stmt3_jstl11	# *=
      expected = '<c:set var="v" value="${v * (a[i] + 1)}"/>' + "\n"
      _test_stmt(@@expr_stmt3, expected)
   end
   def test_expr_stmt3_jstl10	# *=
      expected = '<c:set var="v" value="${v * (a[i] + 1)}"/>' + "\n"
      _test_stmt(@@expr_stmt3, expected)
   end


   @@epxr_stmt4 = "max = x>y ? x : y;"
   def test_expr_stmt4_eruby	# conditinal expr
      expected = "<% max = x > y ? x : y %>\n"
      _test_stmt(@@epxr_stmt4, expected)
   end
   def test_expr_stmt4_php	# conditinal expr
      expected = "<?php $max = $x > $y ? $x : $y; ?>\n"
      _test_stmt(@@epxr_stmt4, expected)
   end
   def test_expr_stmt4_jstl11
      expected = '<c:set var="max" value="${x gt y ? x : y}"/>' + "\n"
      _test_stmt(@@epxr_stmt4, expected)
   end
   def test_expr_stmt4_jstl10
      expected = <<'END'
<c:choose><c:when test="${x gt y}">
  <c:set var="max" value="${x}"/>
</c:when><c:otherwise>
  <c:set var="max" value="${y}"/>
</c:otherwise></c:choose>
END
      _test_stmt(@@epxr_stmt4, expected)
   end


   @@epxr_stmt5 = "max = x>y ? x : y;"
   def test_expr_stmt5_eruby	# conditinal expr
      expected = "<% max = x > y ? x : y %>\n"
      _test_stmt(@@epxr_stmt5, expected)
   end
   def test_expr_stmt5_php	# conditinal expr
      expected = "<?php $max = $x > $y ? $x : $y; ?>\n"
      _test_stmt(@@epxr_stmt5, expected)
   end
   def test_expr_stmt5_jstl11
      expected = '<c:set var="max" value="${x gt y ? x : y}"/>' + "\n"
      _test_stmt(@@epxr_stmt5, expected)
   end
   def test_expr_stmt5_jstl10
      expected = <<'END'
<c:choose><c:when test="${x gt y}">
  <c:set var="max" value="${x}"/>
</c:when><c:otherwise>
  <c:set var="max" value="${y}"/>
</c:otherwise></c:choose>
END
      _test_stmt(@@epxr_stmt5, expected)
   end


   @@epxr_stmt6 = "map[:key] = value;"
   def test_expr_stmt6_eruby	# map[:key] = value
      expected = "<% map[:key] = value %>\n"
      _test_stmt(@@epxr_stmt6, expected)
   end
   def test_expr_stmt6_php	# map[:key] = value
      expected = "<?php $map['key'] = $value; ?>\n"
      _test_stmt(@@epxr_stmt6, expected)
   end
   def test_expr_stmt6_jstl11	# map[:key] = value
      expected = '<c:set var="map" property="key" value="${value}"/>' + "\n"
      _test_stmt(@@epxr_stmt6, expected)
   end
   def test_expr_stmt6_jstl10	# map[:key] = value
      expected = '<c:set var="map" property="key" value="${value}"/>' + "\n"
      _test_stmt(@@epxr_stmt6, expected)
   end


   @@epxr_stmt7 = "map['key'] = value;"
   def test_expr_stmt7_eruby	# map['key'] = value
      expected = "<% map[\"key\"] = value %>\n"
      _test_stmt(@@epxr_stmt7, expected)
   end
   def test_expr_stmt7_php	# map['key'] = value
      expected = "<?php $map[\"key\"] = $value; ?>\n"
      _test_stmt(@@epxr_stmt7, expected)
   end
   def test_expr_stmt7_jstl11	# map['key'] = value
      expected = '<c:set var="map" property="key" value="${value}"/>' + "\n"
      _test_stmt(@@epxr_stmt7, expected)
   end
   def test_expr_stmt7_jstl10	# map['key'] = value
      expected = '<c:set var="map" property="key" value="${value}"/>' + "\n"
      _test_stmt(@@epxr_stmt7, expected)
   end


   @@epxr_stmt8 = "map[key] = value;"
   def test_expr_stmt8_eruby	# map[key] = value
      expected = "<% map[key] = value %>\n"
      _test_stmt(@@epxr_stmt8, expected)
   end
   def test_expr_stmt8_php	# map[key] = value
      expected = "<?php $map[$key] = $value; ?>\n"
      _test_stmt(@@epxr_stmt8, expected)
   end
   def test_expr_stmt8_jstl11	# map[key] = value
      expected = ""
      assert_raise(Kwartz::TranslationError) do
         _test_stmt(@@epxr_stmt8, expected)
      end
   end
   def test_expr_stmt8_jstl10	# map[key] = value
      expected = ""
      assert_raise(Kwartz::TranslationError) do
         _test_stmt(@@epxr_stmt8, expected)
      end
   end


   @@epxr_stmt9 = "obj.prop = value;"
   def test_expr_stmt9_eruby	# map[:key] = value
      expected = "<% obj.prop = value %>\n"
      _test_stmt(@@epxr_stmt9, expected)
   end
   def test_expr_stmt9_php	# map[:key] = value
      expected = "<?php $obj->prop = $value; ?>\n"
      _test_stmt(@@epxr_stmt9, expected)
   end
   def test_expr_stmt9_jstl11	# map[:key] = value
      expected = '<c:set var="obj" property="prop" value="${value}"/>' + "\n"
      _test_stmt(@@epxr_stmt9, expected)
   end
   def test_expr_stmt9_jstl10	# map[:key] = value
      expected = '<c:set var="obj" property="prop" value="${value}"/>' + "\n"
      _test_stmt(@@epxr_stmt9, expected)
   end



   ## ---------------------------- print statement

   @@print_stmt1 = 'print("foo", a+b, "\n");'
   def test_print_stmt1_eruby
      expected = "foo<%= a + b %>\n"
      _test_stmt(@@print_stmt1, expected)
   end
   def test_print_stmt1_php
      expected = "foo<?php echo $a + $b; ?>\n"
      _test_stmt(@@print_stmt1, expected)
   end
   def test_print_stmt1_jstl11
      expected = 'foo<c:out value="${a + b}" escapeXml="false"/>' + "\n"
      _test_stmt(@@print_stmt1, expected)
   end


   @@print_stmt2 = 'print(E(e), X(x), default);'
   def test_print_stmt2_eruby
      expected = "<%= CGI::escapeHTML((e).to_s) %><%= x %><%= default %>"
      _test_stmt(@@print_stmt2, expected)
   end
   def test_print_stmt2_php
      expected = "<?php echo htmlspecialchars($e); ?><?php echo $x; ?><?php echo $default; ?>"
      _test_stmt(@@print_stmt2, expected)
   end
   def test_print_stmt2_jstl11
      expected = '<c:out value="${e}"/><c:out value="${x}" escapeXml="false"/><c:out value="${default}" escapeXml="false"/>'
      _test_stmt(@@print_stmt2, expected)
   end


   @@print_stmt3 = 'print(E(e), X(x), default);'
   def test_print_stmt3_eruby
      expected = "<%= CGI::escapeHTML((e).to_s) %><%= x %><%= CGI::escapeHTML((default).to_s) %>"
      _test_stmt(@@print_stmt3, expected, {:escape=>true})
   end
   def test_print_stmt3_php
      expected = "<?php echo htmlspecialchars($e); ?><?php echo $x; ?><?php echo htmlspecialchars($default); ?>"
      _test_stmt(@@print_stmt3, expected, {:escape=>true})
   end
   def test_print_stmt3_jstl11
      expected = '<c:out value="${e}"/><c:out value="${x}" escapeXml="false"/><c:out value="${default}"/>'
      _test_stmt(@@print_stmt3, expected, {:escape=>true})
   end



   ## ---------------------------- if statement

   @@if_stmt1 = 'if (x == y) print("yes");'
   def test_if_stmt1_eruby
     expected = <<'END'
<% if x == y then %>
yes<% end %>
END
      _test_stmt(@@if_stmt1, expected)
   end
   def test_if_stmt1_php
      expected = <<'END'
<?php if ($x == $y) { ?>
yes<?php } ?>
END
      _test_stmt(@@if_stmt1, expected)
   end
   def test_if_stmt1_jstl11
      expected = <<'END'
<c:if test="${x eq y}">
yes</c:if>
END
      _test_stmt(@@if_stmt1, expected)
   end


   @@if_stmt2 = 'if (x>y) print(x); else print(y);'
   def test_if_stmt2_eruby
      expected = <<'END'
<% if x > y then %>
<%= x %><% else %>
<%= y %><% end %>
END
      _test_stmt(@@if_stmt2, expected)
   end
   def test_if_stmt2_php
      expected = <<'END'
<?php if ($x > $y) { ?>
<?php echo $x; ?><?php } else { ?>
<?php echo $y; ?><?php } ?>
END
      _test_stmt(@@if_stmt2, expected)
   end
   def test_if_stmt2_jstl11
      expected = <<'END'
<c:choose><c:when test="${x gt y}">
<c:out value="${x}" escapeXml="false"/></c:when><c:otherwise>
<c:out value="${y}" escapeXml="false"/></c:otherwise></c:choose>
END
      _test_stmt(@@if_stmt2, expected)
   end


   @@if_stmt3 = 'if (x>y) print(x); else if (y>z) print(y);'
   def test_if_stmt3_eruby
      expected = <<'END'
<% if x > y then %>
<%= x %><% elsif y > z then %>
<%= y %><% end %>
END
      _test_stmt(@@if_stmt3, expected)
   end
   def test_if_stmt3_php
      expected = <<'END'
<?php if ($x > $y) { ?>
<?php echo $x; ?><?php } elseif ($y > $z) { ?>
<?php echo $y; ?><?php } ?>
END
      _test_stmt(@@if_stmt3, expected)
   end
   def test_if_stmt3_jstl11
      expected = <<'END'
<c:choose><c:when test="${x gt y}">
<c:out value="${x}" escapeXml="false"/></c:when><c:when test="${y gt z}">
<c:out value="${y}" escapeXml="false"/></c:when></c:choose>
END
      _test_stmt(@@if_stmt3, expected)
   end


   @@if_stmt4 = <<'END'
if (x>y && x>z) {
  max = x;
} else if (y>x && y>z) {
  max = y;
} else if (z>x && z>x) {
  max = z;
} else {
  max = -1;
}
END
   def test_if_stmt4_eruby
      expected = <<'END'
<% if x > y && x > z then %>
<%   max = x %>
<% elsif y > x && y > z then %>
<%   max = y %>
<% elsif z > x && z > x then %>
<%   max = z %>
<% else %>
<%   max = -1 %>
<% end %>
END
      _test_stmt(@@if_stmt4, expected)
   end
   def test_if_stmt4_php
      expected = <<'END'
<?php if ($x > $y && $x > $z) { ?>
<?php   $max = $x; ?>
<?php } elseif ($y > $x && $y > $z) { ?>
<?php   $max = $y; ?>
<?php } elseif ($z > $x && $z > $x) { ?>
<?php   $max = $z; ?>
<?php } else { ?>
<?php   $max = -1; ?>
<?php } ?>
END
      _test_stmt(@@if_stmt4, expected)
   end
   def test_if_stmt4_jstl11
      expected = <<'END'
<c:choose><c:when test="${x gt y and x gt z}">
  <c:set var="max" value="${x}"/>
</c:when><c:when test="${y gt x and y gt z}">
  <c:set var="max" value="${y}"/>
</c:when><c:when test="${z gt x and z gt x}">
  <c:set var="max" value="${z}"/>
</c:when><c:otherwise>
  <c:set var="max" value="-1"/>
</c:otherwise></c:choose>
END
      _test_stmt(@@if_stmt4, expected)
   end


   ## ---------------------------- foreach statement

   @@foreach_stmt1 = <<'END'
foreach (item in list)
  print("<li>", item, "</li>\n");
END
   def test_foreach_stmt1_eruby
      expected = <<'END'
<% for item in list do %>
<li><%= item %></li>
<% end %>
END
      _test_stmt(@@foreach_stmt2, expected)
   end
   def test_foreach_stmt1_php
      expected = <<'END'
<?php foreach ($list as $item) { ?>
<li><?php echo $item; ?></li>
<?php } ?>
END
      _test_stmt(@@foreach_stmt2, expected)
   end
   def test_foreach_stmt1_jstl11
      expected = <<'END'
<c:forEach var="item" items="${list}">
<li><c:out value="${item}" escapeXml="false"/></li>
</c:forEach>
END
      _test_stmt(@@foreach_stmt2, expected)
   end


   @@foreach_stmt2 = <<'END'
foreach (item in list) {
  print("<li>", item, "</li>\n");
}
END
   def test_foreach_stmt2_eruby
      expected = <<'END'
<% for item in list do %>
<li><%= item %></li>
<% end %>
END
      _test_stmt(@@foreach_stmt2, expected)
   end
   def test_foreach_stmt2_php
      expected = <<'END'
<?php foreach ($list as $item) { ?>
<li><?php echo $item; ?></li>
<?php } ?>
END
      _test_stmt(@@foreach_stmt2, expected)
   end
   def test_foreach_stmt2_jstl11
      expected = <<'END'
<c:forEach var="item" items="${list}">
<li><c:out value="${item}" escapeXml="false"/></li>
</c:forEach>
END
   end


   ## ---------------------------- while statement


   @@while_stmt1 = <<'END'
while (i<len) i += i;
END
   def test_while_stmt1_eruby
      expected = <<'END'
<% while i < len do %>
<%   i += i %>
<% end %>
END
      _test_stmt(@@while_stmt1, expected)
   end
   def test_while_stmt1_php
      expected = <<'END'
<?php while ($i < $len) { ?>
<?php   $i += $i; ?>
<?php } ?>
END
      _test_stmt(@@while_stmt1, expected)
   end
   def test_while_stmt1_jstl11
      expected = ''
      assert_raise(Kwartz::TranslationError) do
         _test_stmt(@@while_stmt1, expected)
      end
   end


   ## ---------------------------- expand statement

   @@expand_stmt1 = '@element(foo);'
   def test_expand_stmt1_eruby
      expected = ''
      assert_raise(Kwartz::TranslationError) do
         _test_stmt(@@expand_stmt1, expected)
      end
   end
   def test_expand_stmt1_php
      expected = ''
      assert_raise(Kwartz::TranslationError) do
         _test_stmt(@@expand_stmt1, expected)
      end
   end
   def test_expand_stmt1_jstl11
      expected = ''
      assert_raise(Kwartz::TranslationError) do
         _test_stmt(@@expand_stmt1, expected)
      end
   end
   def test_expand_stmt1_jstl10
      expected = ''
      assert_raise(Kwartz::TranslationError) do
         _test_stmt(@@expand_stmt1, expected)
      end
   end


   ## ======================================== properties

   @@prop1 = <<'END'
i = 10;
foreach (i in list) {
  print("i = ", i, "\r\n");
}
END

   def test_properties1_eruby
      expected = <<END
<% i = 10 %>\r
<% for i in list do %>\r
i = <%= i %>\r
<% end %>\r
END
      _test_stmt(@@prop1, expected, {:newline => "\r\n"} )
   end
   
   def test_properties1_php
      expected = <<END
<?php $i = 10; ?>\r
<?php foreach ($list as $i) { ?>\r
i = <?php echo $i; ?>\r
<?php } ?>\r
END
      _test_stmt(@@prop1, expected, {:newline => "\r\n"} )
   end
   
   def test_properties1_jstl11
      expected = <<END
<c:set var="i" value="10"/>\r
<c:forEach var="i" items="${list}">\r
i = <c:out value="${i}"/>\r
</c:forEach>\r
END
      _test_stmt(@@prop1, expected, {:newline => "\r\n",  :escape=>true} )
   end
   
   def test_properties1_jstl10
      expected = <<END
<c:set var="i" value="10"/>\r
<c:forEach var="i" items="${list}">\r
i = <c:out value="${i}"/>\r
</c:forEach>\r
END
      _test_stmt(@@prop1, expected, {:newline => "\r\n", :escape=>true} )
   end
   

end



##
## main
##
if $0 == __FILE__
    Test::Unit::UI::Console::TestRunner.run(TranslatorTest)
end
