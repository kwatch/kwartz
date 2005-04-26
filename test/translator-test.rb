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
require 'kwartz/translator/erb'
require 'kwartz/translator/php'
require 'kwartz/translator/jstl'
require 'kwartz/translator/velocity'



##
## translator test
##
class TranslatorTest < Test::Unit::TestCase

   def setup
      @flag_suspend = false
   end

   def _test(method_name, input, expected, properties={}, lang=nil)
      if !lang
         s = caller()[1]
         s =~ /in `(.*)'/          #'
         testmethod = $1
         if testmethod =~ /_(eruby|erb|php|jstl11|jstl10|velocity)$/
            lang = $1
         else
            raise "invalid testmethod name (='#{testmethod}')"
         end
      end
      parser = Kwartz::Parser.new(input, properties)
      block_stmt = parser.__send__(method_name)
      translator = Kwartz::Translator.create(lang, properties)
      actual = translator.translate(block_stmt)
      assert_equal_with_diff(expected, actual)
   end

   def _test_expr(input, expected, properties={}, lang=nil)
      _test('parse_expression', input, expected, properties)
   end

   def _test_stmt(input, expected, properties={}, lang=nil)
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
   def test_literal1_velocity
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
      #expected = '"str\'s\r\n"'
      expected = "'str\\'s\r\n'"
      _test_expr(@@literal2, expected)
   end
   def test_literal2_jstl10
      #expected = '"str\'s\r\n"'
      expected = "'str\\'s\r\n'"
      _test_expr(@@literal2, expected)
   end
   def test_literal2_velocity
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
   def test_literal4_velocity
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
   def test_literal5_velocity
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
   def test_literal6_velocity
      expected = ""
      assert_raise(Kwartz::TranslationError) do
         _test_expr(@@literal6, expected)
      end
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
   def test_expression1_velocity
      expected = '$a + $b * $c - $d % $e'
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
   def test_expression2_velocity
      expected = ''
      assert_raise(Kwartz::TranslationError) do
         _test_expr(@@expression2, expected)
      end
      input = "a * (b + c) % d"
      expected = '$a * ($b + $c) % $d'
      _test_expr(input, expected)
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
   def test_expression3_velocity
      expected = '-2 * $b'
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
   def test_assign1_php
      expected = '$a = 10'
      _test_expr(@@assign1, expected)
   end


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
#   def test_assign2_velocity
#      expected = '$a += $i + 1'
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
   def test_assign3_velocity
      #expected = '$a[$i] *= $a[$i - 2] + $a[$i - 1]'
      input = 'a[i-2]'
      expected = '$a[$i - 2]'
      _test_expr(input, expected)
   end


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
#   def test_assign4_velocity
#      expected = "$a['name'] = \"s1\" . \"s2\""
#      _test_expr(@@assign4, expected)
#   end


   ## ---------------------------- function

   @@function01 = 'list = list_new()'			# list_new()
   def test_function1_eruby	# list_new()
      expected = 'list = []'
      _test_expr(@@function01, expected)
   end
   def test_function01_php	# list_new()
      expected = '$list = array()'
      _test_expr(@@function01, expected)
   end
   def test_function01_jstl11	# list_new()
      input = 'list_new()'
      expected = '***'
      assert_raise(Kwartz::TranslationError) do
         _test_expr(input, expected)
      end
   end
   def test_function01_velocity	# list_new()
      expected = '***'
      assert_raise(Kwartz::TranslationError) do
         _test_expr(@@function01, expected)
      end
   end


   @@function03 = 'list_length(list)'			# list_length()
   def test_function03_eruby	# list_length()
      expected = 'list.length'
      _test_expr(@@function03, expected)
   end
   def test_function03_php	# list_length()
      expected = 'count($list)'
      _test_expr(@@function03, expected)
   end
   def test_function03_jstl11	# list_length()
      expected = 'fn:length(list)'
      _test_expr(@@function03, expected)
   end
   def test_function03_velocity	# list_length()
      expected = '$list.size()'
      _test_expr(@@function03, expected)
   end


   @@function04 = 'list_empty(list)'			# list_empty()
   def test_function04_eruby	# list_empty()
      expected = 'list.empty?'
      _test_expr(@@function04, expected)
   end
   def test_function04_php	# list_empty()
      expected = 'count($list)==0'
      _test_expr(@@function04, expected)
   end
   def test_function04_jstl11	# list_empty()
      expected = 'fn:length(list)==0'
      _test_expr(@@function04, expected)
   end
   def test_function04_velocity	# list_empty()
      expected = '$list.size()==0'
      _test_expr(@@function04, expected)
   end



   @@function11 = 'hash = hash_new()'			# hash_new()
   def test_function11_eruby	# hash_new()
      expected = 'hash = {}'
      _test_expr(@@function11, expected)
   end
   def test_function11_php	# hash_new()
      expected = '$hash = array()'
      _test_expr(@@function11, expected)
   end
   def test_function11_jstl11	# hash_new()
      input = 'hash_new()'
      expected = '***'
      assert_raise(Kwartz::TranslationError) do
         _test_expr(input, expected)
      end
   end
   def test_function11_velocity	# hash_new()
      expected = '***'
      assert_raise(Kwartz::TranslationError) do
         _test_expr(@@function11, expected)
      end
   end


   @@function13 = 'hash_length(hash)'			# hash_length()
   def test_function13_eruby	# hash_length()
      expected = 'hash.length'
      _test_expr(@@function13, expected)
   end
   def test_function13_php	# hash_length()
      expected = 'count($hash)'
      _test_expr(@@function13, expected)
   end
   def test_function13_jstl11	# hash_length()
      expected = 'fn:length(hash)'
      _test_expr(@@function13, expected)
   end
   def test_function13_velocity	# hash_length()
      expected = '$hash.size()'
      _test_expr(@@function13, expected)
   end


   @@function14 = 'hash_empty(hash)'			# hash_empty()
   def test_function14_eruby	# hash_empty()
      expected = 'hash.empty?'
      _test_expr(@@function14, expected)
   end
   def test_function14_php	# hash_empty()
      expected = 'count($hash)==0'
      _test_expr(@@function14, expected)
   end
   def test_function14_jstl11	# hash_empty()
      expected = 'fn:length(hash)==0'
      _test_expr(@@function14, expected)
   end
   def test_function14_velocity	# hash_empty()
      expected = '$hash.size()==0'
      _test_expr(@@function14, expected)
   end


   @@function15 = 'hash_keys(hash)'			# hash_keys()
   def test_function15_eruby	# hash_keys()
      expected = 'hash.keys'
      _test_expr(@@function15, expected)
   end
   def test_function15_php	# hash_keys()
      expected = 'array_keys($hash)'
      _test_expr(@@function15, expected)
   end
   def test_function15_jstl11	# hash_keys()
      #expected = 'fn:length(hash)'
      expected = '***'
      assert_raise(Kwartz::TranslationError) do
         _test_expr(@@function15, expected)
      end
   end
   def test_function15_velocity	# hash_keys()
      expected = '$hash.keySet().toArray()'
      _test_expr(@@function15, expected)
   end



   @@function21 = 'str_length(s)'			# str_length()
   def test_function21_eruby	# str_length()
      expected = 's.length'
      _test_expr(@@function21, expected)
   end
   def test_function21_php	# str_length()
      expected = 'strlen($s)'
      _test_expr(@@function21, expected)
   end
   def test_function21_jstl11	# str_length()
      expected = 'fn:length(s)'
      _test_expr(@@function21, expected)
   end
   def test_function21_velocity	# str_length()
      expected = '$s.length()'
      _test_expr(@@function21, expected)
   end


   @@function22 = 'str_empty(s)'			# str_empty()
   def test_function22_eruby	# str_empty()
      expected = 's.empty?'
      _test_expr(@@function22, expected)
   end
   def test_function22_php	# str_empty()
      expected = 'strlen($s)==0'
      _test_expr(@@function22, expected)
   end
   def test_function22_jstl11	# str_empty()
      expected = 'fn:length(s)==0'
      _test_expr(@@function22, expected)
   end
   def test_function22_velocity	# str_empty()
      expected = '$s.length()==0'
      _test_expr(@@function22, expected)
   end


   @@function23 = 'str_trim(s)'				# str_trim()
   def test_function23_eruby	# str_trim()
      expected = 's.trim'
      _test_expr(@@function23, expected)
   end
   def test_function23_php	# str_trim()
      expected = 'trim($s)'
      _test_expr(@@function23, expected)
   end
   def test_function23_jstl11	# str_trim()
      expected = 'fn:trim(s)'
      _test_expr(@@function23, expected)
   end
   def test_function23_velocity	# str_trim()
      expected = '$s.trim()'
      _test_expr(@@function23, expected)
   end


   @@function24 = 'str_toupper(s)'			# str_toupper()
   def test_function24_eruby	# str_toupper()
      expected = 's.upcase'
      _test_expr(@@function24, expected)
   end
   def test_function24_php	# str_toupper()
      expected = 'strtoupper($s)'
      _test_expr(@@function24, expected)
   end
   def test_function24_jstl11	# str_toupper()
      expected = 'fn:toUpperCase(s)'
      _test_expr(@@function24, expected)
   end
   def test_function24_velocity	# str_toupper()
      expected = '$s.toUpperCase()'
      _test_expr(@@function24, expected)
   end


   @@function25 = 'str_tolower(s)'			# str_tolower()
   def test_function25_eruby	# str_tolower()
      expected = 's.downcase'
      _test_expr(@@function25, expected)
   end
   def test_function25_php	# str_tolower()
      expected = 'strtolower($s)'
      _test_expr(@@function25, expected)
   end
   def test_function25_jstl11	# str_tolower()
      expected = 'fn:toLowerCase(s)'
      _test_expr(@@function25, expected)
   end
   def test_function25_velocity	# str_tolower()
      expected = '$s.toLowerCase()'
      _test_expr(@@function25, expected)
   end


   @@function26 = 'str_index(s, "x")'			# str_index()
   def test_function26_eruby	# str_index()
      expected = 's.index("x")'
      _test_expr(@@function26, expected)
   end
   def test_function26_php	# str_index()
      expected = 'strstr($s, "x")'
      _test_expr(@@function26, expected)
   end
   def test_function26_jstl11	# str_index()
      expected = "fn:indexOf(s, 'x')"
      _test_expr(@@function26, expected)
   end
   def test_function26_velocity	# str_index()
      expected = '$s.indexOf("x")'
      _test_expr(@@function26, expected)
   end


   @@function27 = 'str_replace(s,from,"to")'		# str_replace()
   def test_function27_eruby	# str_replace()
      expected = 's.gsub(from, "to")'
      _test_expr(@@function27, expected)
   end
   def test_function27_php	# str_replace()
      expected = 'str_replace($from, "to", $s)'
      _test_expr(@@function27, expected)
   end
   def test_function27_jstl11	# str_replace()
      expected = "fn:replace(s, from, 'to')"
      _test_expr(@@function27, expected)
   end
   def test_function27_velocity	# str_replace()
      expected = '$s.replaceAll($from, "to")'
      _test_expr(@@function27, expected)
   end


   @@function28 = 'str_linebreak(line)'			# str_linebreak()
   def test_function28_eruby	# str_linebreak()
      expected = 'line.gsub(/\r?\n/,\'<br />\\&\')'
      _test_expr(@@function28, expected)
   end
   def test_function28_php	# str_linebreak()
      expected = 'nl2br($line)'
      _test_expr(@@function28, expected)
   end
   def test_function28_jstl11	# str_linebreak()
      expected = 'fn:replace(line,"\\n","<br />\\n")'   #'
      _test_expr(@@function28, expected)
   end
   def test_function28_velocity	# str_linebreak()
      expected = "$line.replaceAll('$','<br />')"  #'
      _test_expr(@@function28, expected)
   end


   @@function31 = 'escape_xml(xml)'			# escape_xml()
   def test_function31_eruby	# escape_url
      expected = 'CGI::escapeHTML(xml)'
      _test_expr(@@function31, expected)
   end
   def test_function31_php	# escape_url
      expected = 'htmlspecialchars($xml)'
      _test_expr(@@function31, expected)
   end
   def test_function31_jstl11	# escape_url
      expected = 'fn:escapeXml(xml)'
      _test_expr(@@function31, expected)
   end
   def test_function31_velocity	# escape_url
      expected = '$esc.xml($xml)'
      _test_expr(@@function31, expected)
   end


   @@function32 = 'escape_sql(sql)'			# escape_sql()
   def test_function32_eruby	# escape_url
      expected = 'sql.gsub([\'"\\\\\\0],\'\\&\')'
      _test_expr(@@function32, expected)
   end
   def test_function32_php	# escape_url
      expected = 'addslashes($sql)'
      _test_expr(@@function32, expected)
   end
   def test_function32_jstl11	# escape_url
      expected = '***'
      assert_raise(Kwartz::TranslationError) do
         _test_expr(@@function32, expected)
      end
   end
   def test_function32_velocity	# escape_url
      expected = '$esc.sql($sql)'
      _test_expr(@@function32, expected)
   end


   @@function33 = 'escape_url(url)'			# escape_url()
   def test_function33_eruby	# escape_url
      expected = 'CGI::escape(url)'
      _test_expr(@@function33, expected)
   end
   def test_function33_erb	# escape_url
      expected = 'url_encode(url)'
      _test_expr(@@function33, expected)
   end
   def test_function33_php	# escape_url
      expected = 'urlencode($url)'
      _test_expr(@@function33, expected)
   end
   def test_function33_jstl11	# escape_url
      expected = '***'
      assert_raise(Kwartz::TranslationError) do
         _test_expr(@@function33, expected)
      end
   end
   def test_function33_velocity	# escape_url
      expected = '$link.setURI($url).toString()'
      _test_expr(@@function33, expected)
   end


   @@function81 = 'foo(10) + bar(x)'		# original function
   def test_function81_eruby	# original function
      expected = 'foo(10) + bar(x)'
      _test_expr(@@function81, expected)
   end
   def test_function81_php	# original function
      expected = 'foo(10) + bar($x)'
      _test_expr(@@function81, expected)
   end
   def test_function81_jstl11	# original function
      expected = 'my:foo(10) + my:bar(x)'
      assert_raise(Kwartz::TranslationError) do
         _test_expr(@@function81, expected)
      end
   end
   def test_function81_velocity	# original function
      expected = 'my.foo(10) + my.bar($x)'
      assert_raise(Kwartz::TranslationError) do
         _test_expr(@@function81, expected)
      end
   end


   @@function82 = 's2 = sprintf("%02d - %s\n", x, s2)'		# sprintf
   def test_function82_eruby	# sprintf
      expected = 's2 = sprintf("%02d - %s\n", x, s2)'
      _test_expr(@@function82, expected)
   end
   def test_function82_php	# sprintf
      expected = '$s2 = sprintf("%02d - %s\n", $x, $s2)'
      _test_expr(@@function82, expected)
   end
   #def test_function82_jstl11	# sprintf
   #   expected = '***'
   #   assert_raise(Kwartz::TranslationError) do
   #      _test_expr(@@function82, expected)
   #   end
   #end
   #def test_function82_velocity	# sprintf
   #   expected = '***'
   #   assert_raise(Kwartz::TranslationError) do
   #      _test_expr(@@function82, expected)
   #   end
   #end


   @@function91 = 'str_length(str_toupper(s))'		# nested function
   def test_function91_eruby	# nested function
      expected = 's.upcase.length'
      _test_expr(@@function91, expected)
   end
   def test_function91_php	# nested function
      expected = 'strlen(strtoupper($s))'
      _test_expr(@@function91, expected)
   end
   def test_function91_jstl11	# nested function
      expected = 'fn:length(fn:toUpperCase(s))'
      _test_expr(@@function91, expected)
   end
   def test_function91_velocity	# nested function
      expected = '$s.toUpperCase().length()'
      _test_expr(@@function91, expected)
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


   ## ---------------------------- empty and notempty

   @@empty1 = 'str == empty'
   def test_empty1_eruby
      expected = '!str || str.empty?'
      _test_expr(@@empty1, expected)
   end
   def test_empty1_php
      expected = '!$str'
      _test_expr(@@empty1, expected)
   end
   def test_empty1_jstl11
      expected = 'empty str'
      _test_expr(@@empty1, expected)
      _test_expr(@@empty1, expected, {}, 'jstl10')
   end
   def test_empty1_velocity
      expected = '! $str || $str == ""'
      _test_expr(@@empty1, expected)
   end


   @@empty2 = 'str != empty'
   def test_empty2_eruby
      expected = 'str && !str.empty?'
      _test_expr(@@empty2, expected)
   end
   def test_empty2_php
      expected = '$str'
      _test_expr(@@empty2, expected)
   end
   def test_empty2_jstl11
      expected = 'not empty str'
      _test_expr(@@empty2, expected)
      _test_expr(@@empty2, expected, {}, 'jstl10')
   end
   def test_empty2_velocity
      expected = '$str && $str != ""'
      _test_expr(@@empty2, expected)
   end



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
   def test_expr_stmt1_velocity	# numeric
      expected = "#set($a = 1)\n"
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
   def test_expr_stmt2_velocity	# string
      expected = "#set($s = \"foo\")\n"
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
   def test_expr_stmt3_velocity	# *=
      expected = "#set($v = $v * ($a[$i] + 1))\n"
      _test_stmt(@@expr_stmt3, expected)
   end


   @@epxr_stmt4 = "min = x<y ? x : y;"
   def test_expr_stmt4_eruby	# conditinal expr
      expected = "<% min = x < y ? x : y %>\n"
      _test_stmt(@@epxr_stmt4, expected)
   end
   def test_expr_stmt4_php	# conditinal expr
      expected = "<?php $min = $x < $y ? $x : $y; ?>\n"
      _test_stmt(@@epxr_stmt4, expected)
   end
   def test_expr_stmt4_jstl11
      expected = '<c:set var="min" value="${x lt y ? x : y}"/>' + "\n"
      _test_stmt(@@epxr_stmt4, expected)
   end
   def test_expr_stmt4_jstl10
      expected = <<'END'
<c:choose><c:when test="${x lt y}">
  <c:set var="min" value="${x}"/>
</c:when><c:otherwise>
  <c:set var="min" value="${y}"/>
</c:otherwise></c:choose>
END
      _test_stmt(@@epxr_stmt4, expected)
   end
   def test_expr_stmt4_velocity	# conditinal expr
      expected = <<'END'
#if($x < $y)
  #set($min = $x)
#else
  #set($min = $y)
#end
END
      _test_stmt(@@epxr_stmt4, expected)
   end


   @@epxr_stmt5 = "max = x>y ? x : y>z? y : z;"
   def test_expr_stmt5_eruby	# conditinal expr
      expected = "<% max = x > y ? x : y > z ? y : z %>\n"
      _test_stmt(@@epxr_stmt5, expected)
   end
   def test_expr_stmt5_php	# conditinal expr
      expected = "<?php $max = $x > $y ? $x : $y > $z ? $y : $z; ?>\n"
      _test_stmt(@@epxr_stmt5, expected)
   end
   def test_expr_stmt5_jstl11
      expected = '<c:set var="max" value="${x gt y ? x : y gt z ? y : z}"/>' + "\n"
      _test_stmt(@@epxr_stmt5, expected)
   end
   def test_expr_stmt5_jstl10
      expected = <<'END'
<c:choose><c:when test="${x gt y}">
  <c:set var="max" value="${x}"/>
</c:when><c:when test="${y gt z}">
  <c:set var="max" value="${y}"/>
</c:when><c:otherwise>
  <c:set var="max" value="${z}"/>
</c:otherwise></c:choose>
END
      _test_stmt(@@epxr_stmt5, expected)
   end
   def test_expr_stmt5_velocity	# conditinal expr
      expected = <<'END'
#if($x > $y)
  #set($max = $x)
#elseif($y > $z)
  #set($max = $y)
#else
  #set($max = $z)
#end
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
   def test_expr_stmt6_velocity	# map[:key] = value
      expected = "#set($map.key = $value)\n"
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
   def test_expr_stmt7_velocity	# map['key'] = value
      expected = "#set($map[\"key\"] = $value)\n"
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
   def test_expr_stmt8_velocity	# map[key] = value
      expected = "#set($map[$key] = $value)\n"
      _test_stmt(@@epxr_stmt8, expected)
   end


   @@epxr_stmt9 = "obj.prop = value;"
   def test_expr_stmt9_eruby	# obj.prop = value;
      expected = "<% obj.prop = value %>\n"
      _test_stmt(@@epxr_stmt9, expected)
   end
   def test_expr_stmt9_php	# obj.prop = value;
      expected = "<?php $obj->prop = $value; ?>\n"
      _test_stmt(@@epxr_stmt9, expected)
   end
   def test_expr_stmt9_jstl11	# obj.prop = value;
      expected = '<c:set var="obj" property="prop" value="${value}"/>' + "\n"
      _test_stmt(@@epxr_stmt9, expected)
   end
   def test_expr_stmt9_jstl10	# obj.prop = value;
      expected = '<c:set var="obj" property="prop" value="${value}"/>' + "\n"
      _test_stmt(@@epxr_stmt9, expected)
   end
   def test_expr_stmt9_velocity	# obj.prop = value;
      expected = "#set($obj.prop = $value)\n"
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
   def test_print_stmt1_velocity
      expected = ""
      assert_raise(Kwartz::TranslationError) do
         _test_stmt(@@print_stmt1, expected)
      end
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
   def test_print_stmt2_velocity
      expected = "$!esc.html($e)$!{x}$!{default}"
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
   def test_print_stmt3_velocity
      expected = "$!esc.html($e)$!{x}$!esc.html($default)"
      _test_stmt(@@print_stmt3, expected, {:escape=>true})
   end



   @@print_stmt4 = 'print("http://" .+ url .+ "?param=" .+ value);'
   def test_print_stmt4_eruby
   	#expected = '<% "http://" + url + "?param=" + value %>'
   	expected = "http://<%= url %>?param=<%= value %>"
	_test_stmt(@@print_stmt4, expected)
   end
   def test_print_stmt4_php
   	#expected = '<?php echo "http://" . $url . "?param=" . $value; ?>'
   	expected = "http://<?php echo $url; ?>?param=<?php echo $value; ?>"
	_test_stmt(@@print_stmt4, expected)
   end
   def test_print_stmt4_jstl11
   	expected = 'http://<c:out value="${url}" escapeXml="false"/>?param=<c:out value="${value}" escapeXml="false"/>'
	_test_stmt(@@print_stmt4, expected)
   end
   def test_print_stmt4_jstl10
   	expected = 'http://<c:out value="${url}" escapeXml="false"/>?param=<c:out value="${value}" escapeXml="false"/>'
	_test_stmt(@@print_stmt4, expected)
   end
   def test_print_stmt4_velocity
   	expected = 'http://$!{url}?param=$!{value}'
	_test_stmt(@@print_stmt4, expected)
   end



   @@print_stmt5 = 'print("http://" .+ url .+ "?param=" .+ value);'
   def test_print_stmt5_eruby
   	expected = "http://<%= CGI::escapeHTML((url).to_s) %>?param=<%= CGI::escapeHTML((value).to_s) %>"
	_test_stmt(@@print_stmt5, expected, {:escape=>true})
   end
   def test_print_stmt5_php
   	expected = "http://<?php echo htmlspecialchars($url); ?>?param=<?php echo htmlspecialchars($value); ?>"
	_test_stmt(@@print_stmt5, expected, {:escape=>true})
   end
   def test_print_stmt5_jstl11
   	expected = 'http://<c:out value="${url}"/>?param=<c:out value="${value}"/>'
	_test_stmt(@@print_stmt5, expected, {:escape=>true})
   end
   def test_print_stmt5_jstl10
   	expected = 'http://<c:out value="${url}"/>?param=<c:out value="${value}"/>'
	_test_stmt(@@print_stmt5, expected, {:escape=>true})
   end
   def test_print_stmt5_velocity
   	expected = 'http://$!esc.html($url)?param=$!esc.html($value)'
	_test_stmt(@@print_stmt5, expected, {:escape=>true})
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
   def test_if_stmt1_velocity
      expected = <<'END'
#if($x == $y)
yes#end
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
   def test_if_stmt2_velocity
      expected = <<'END'
#if($x > $y)
$!{x}#else
$!{y}#end
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
   def test_if_stmt3_velocity
      expected = <<'END'
#if($x > $y)
$!{x}#elseif($y > $z)
$!{y}#end
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
   def test_if_stmt4_velocity
      expected = <<'END'
#if($x > $y && $x > $z)
  #set($max = $x)
#elseif($y > $x && $y > $z)
  #set($max = $y)
#elseif($z > $x && $z > $x)
  #set($max = $z)
#else
  #set($max = -1)
#end
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
      _test_stmt(@@foreach_stmt1, expected)
   end
   def test_foreach_stmt1_php
      expected = <<'END'
<?php foreach ($list as $item) { ?>
<li><?php echo $item; ?></li>
<?php } ?>
END
      _test_stmt(@@foreach_stmt1, expected)
   end
   def test_foreach_stmt1_jstl11
      expected = <<'END'
<c:forEach var="item" items="${list}">
<li><c:out value="${item}" escapeXml="false"/></li>
</c:forEach>
END
      _test_stmt(@@foreach_stmt1, expected)
   end
   def test_foreach_stmt1_velocity
      expected = <<'END'
#foreach($item in $list)
<li>$!{item}</li>
#end
END
      _test_stmt(@@foreach_stmt1, expected)
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
   def test_foreach_stmt2_velocity
      expected = <<'END'
#foreach($item in $list)
<li>$!{item}</li>
#end
END
      _test_stmt(@@foreach_stmt2, expected)
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
   def test_while_stmt1_velocity
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
   def test_expand_stmt1_velocity
      expected = ''
      assert_raise(Kwartz::TranslationError) do
         _test_stmt(@@expand_stmt1, expected)
      end
   end


   ## ---------------------------- rawcode statement

   @@rawcode_stmt1 = <<'END'
  ::: int i = 0;
  <?php foreach($hash as $key => $value) { ?>
     print(key, " = ", value, "\n");
  <?php } ?>
  <% hash.each do |key, value| %>
     print(key, " is ", value, "\n");
  <% end %>
END

   def test_rawcode_stmt1_eruby
      expected = <<'END'
<% int i = 0;%>
<%php foreach($hash as $key => $value) { %>
<%= key %> = <%= value %>
<%php } %>
<% hash.each do |key, value| %>
<%= key %> is <%= value %>
<% end %>
END
      _test_stmt(@@rawcode_stmt1, expected)
   end
   
   def test_rawcode_stmt1_php
      expected = <<'END'
<?php  int i = 0;?>
<?php foreach($hash as $key => $value) { ?>
<?php echo $key; ?> = <?php echo $value; ?>
<?php } ?>
<?php  hash.each do |key, value| ?>
<?php echo $key; ?> is <?php echo $value; ?>
<?php  end ?>
END
      _test_stmt(@@rawcode_stmt1, expected)
   end

   def test_rawcode_stmt1_jstl11
      expected = <<'END'
<% int i = 0;%>
<%php foreach($hash as $key => $value) { %>
<c:out value="${key}" escapeXml="false"/> = <c:out value="${value}" escapeXml="false"/>
<%php } %>
<% hash.each do |key, value| %>
<c:out value="${key}" escapeXml="false"/> is <c:out value="${value}" escapeXml="false"/>
<% end %>
END
      _test_stmt(@@rawcode_stmt1, expected)
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

   def test_properties1_velocity
      expected = <<END
#set($i = 10)\r
#foreach($i in $list)\r
i = $!{i}\r
#end\r
END
      _test_stmt(@@prop1, expected, {:newline => "\r\n"} )
   end


end



##
## main
##
if $0 == __FILE__
    Test::Unit::UI::Console::TestRunner.run(TranslatorTest)
end
