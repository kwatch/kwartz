#!/usr/bin/ruby

###
### unit test for Parser
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

include Kwartz


##
## parse expression test
##
class ParseExpressionTest < Test::Unit::TestCase

   def setup
      @flag_suspend = false
   end

   ##
   def _test(input, expected, klass, properties={})
      return if @flag_suspend
      s = caller().first
      s =~ /in `(.*)'/		#'
      testmethod = $1
      method_name = testmethod.sub(/\Atest_/, '').sub(/\d*\z/, '')
      #$stderr.puts "*** debug: method_name=#{method_name.inspect}"
      parser = Kwartz::Parser.new(input, properties)
      expr = parser.__send__(method_name)
      assert_equal(klass, expr.class)
      assert_equal_with_diff(expected, expr._inspect())
   end

   ##
   def _test_parse_arguments(input, expected, properties={})
      parser = Kwartz::Parser.new(input, {})
      arguments = parser.parse_arguments
      assert_equal(Array, arguments.class)
      actual = arguments.collect { |expr| expr._inspect() }.join()
      assert_equal_with_diff(expected, actual)
   end



   ##
   def test_parse_arguments1
      input = 'x, 10, "str"'
      expected = "x\n10\n\"str\"\n"
      _test_parse_arguments(input, expected)
   end

   def test_parse_arguments2
      input = "x, y+1, a<b?b: a, 'foo'"
      expected = <<'END'
x
+
  y
  1
?:
  <
    a
    b
  b
  a
"foo"
END
      _test_parse_arguments(input, expected)
   end

   ##
   def test_parse_item_expr1
      input = "x"
      expected = "x\n"
      _test(input, expected, VariableExpression)
   end

   def test_parse_item_expr2
      input = "f1()"
      expected = "f1()\n"
      _test(input, expected, FunctionExpression)
      input = "f2(x, y)"
      expected = "f2()\n  x\n  y\n"
      _test(input, expected, FunctionExpression)
   end

   def test_parse_item_expr3
      input = "(x + y)"
      expected = "+\n  x\n  y\n"
      _test(input, expected, ArithmeticExpression)
   end

   def test_parse_item_expr4	# macro C(), S(), D()
      input = "C(flag)"
      expected = <<'END'
?:
  flag
  " checked=\"checked\""
  ""
END
      _test(input, expected, ConditionalExpression)

      input = "S(gender=='M')"
      expected = <<'END'
?:
  ==
    gender
    "M"
  " selected=\"selected\""
  ""
END
      _test(input, expected, ConditionalExpression)

      input = "D(gender=='M')"
      expected = <<'END'
?:
  ==
    gender
    "M"
  " disabled=\"disabled\""
  ""
END
      _test(input, expected, ConditionalExpression)
   end


   def test_parse_item_expr5	# arity check of macro C() S() D()
      input = "C()"
      expected = ''
      assert_raise(Kwartz::SemanticError) do
         _test(input, expected, ConditionalExpression)
      end
      input = "S(foo, bar)"
      expected = ''
      assert_raise(Kwartz::SemanticError) do
         _test(input, expected, ConditionalExpression)
      end
      input = "D(1, 2)"
      expected = ''
      assert_raise(Kwartz::SemanticError) do
         _test(input, expected, ConditionalExpression)
      end
   end


   ##
   def test_parse_literal_expr1
      input = "123"
      expected = "123\n"
      _test(input, expected, NumericExpression)
   end

   def test_parse_literal_expr2
      input = "'foo\"bar'"
      expected = '"foo\\"bar"' + "\n"
      _test(input, expected, StringExpression)
      input = '"foo\'bar\r\n"'
      expected = '"foo\'bar\r\n"' + "\n"
      _test(input, expected, StringExpression)
   end

   def test_parse_literal_expr3
      input = "true"
      expected = "true\n"
      _test(input, expected, BooleanExpression)
      input = "false"
      expected = "false\n"
      _test(input, expected, BooleanExpression)
      input = "null"
      expected = "null\n"
      _test(input, expected, NullExpression)
   end

   def test_parse_literal_expr4
      input = "empty"
      expected = ""
      assert_raise(Kwartz::SyntaxError) do
         _test(input, expected, Expression)
      end
   end

   def test_parse_literal_expr5		# bug: Parser#parse_literal()
      input = "'foo' bar"
      expected = '"foo"' + "\n"
      _test(input, expected, StringExpression)
   end

   ##
   def test_parse_factor_expr1
      input = "x"
      expected = "x\n"
      _test(input, expected, VariableExpression)
   end

   def test_parse_factor_expr2
      input = "x[i+1]"
      expected = "[]\n  x\n  +\n    i\n    1\n"
      _test(input, expected, IndexExpression)
   end

   def test_parse_factor_expr3
      input = "x[:key]"
      expected = "[:]\n  x\n  \"key\"\n"
      _test(input, expected, IndexExpression)
   end

   def test_parse_factor_expr4
      input = "x.prop"
      expected = ".\n  x\n  prop\n"
      _test(input, expected, PropertyExpression)
   end

   def test_parse_factor_expr5
      input = "x.m1(a, b)"
      expected = ".()\n  x\n  m1\n    a\n    b\n"
      _test(input, expected, MethodExpression)
   end

   ##
   def test_parse_term_expr1
      input = "x * y"
      expected = "*\n  x\n  y\n"
      _test(input, expected, ArithmeticExpression)
   end

   def test_parse_term_expr2
      input = "a * b / c % d"
      expected = <<'END'
%
  /
    *
      a
      b
    c
  d
END
      _test(input, expected, ArithmeticExpression)
   end

   ##
   def test_parse_unary_expr1
      input = "-1"
      expected = "-.\n  1\n"
      _test(input, expected, UnaryExpression)
      input = "+1"
      expected = "+.\n  1\n"
      _test(input, expected, UnaryExpression)
      input = "! flag"
      expected = "!\n  flag\n"
      _test(input, expected, UnaryExpression)
   end

   def test_parse_unary_expr2
      input = "1"
      expected = "1\n"
      _test(input, expected, NumericExpression)
   end

   ##
   def test_parse_arith_expr1
      input = "x + y"
      expected = "+\n  x\n  y\n"
      _test(input, expected, ArithmeticExpression)
   end

   def test_parse_arith_expr2
      input = "a + b - c .+ d"
      expected = <<'END'
.+
  -
    +
      a
      b
    c
  d
END
      _test(input, expected, ArithmeticExpression)
   end

   def test_parse_arith_expr3
      input = "! a + b * c - d % e"
      expected = <<'END'
-
  +
    !
      a
    *
      b
      c
  %
    d
    e
END
      _test(input, expected, ArithmeticExpression)
   end

   def test_parse_arith_expr4
      input = "- a * b * ! c"
      expected = ""
      assert_raise(Kwartz::SyntaxError) do
         _test(input, expected, Expression)
      end
   end

   ##
   def test_parse_relational_expr1
      input = "x == y"
      expected = "==\n  x\n  y\n"
      _test(input, expected, RelationalExpression)
      input = "x != y"
      expected = "!=\n  x\n  y\n"
      _test(input, expected, RelationalExpression)
      input = "x > y"
      expected = ">\n  x\n  y\n"
      _test(input, expected, RelationalExpression)
      input = "x >= y"
      expected = ">=\n  x\n  y\n"
      _test(input, expected, RelationalExpression)
      input = "x < y"
      expected = "<\n  x\n  y\n"
      _test(input, expected, RelationalExpression)
      input = "x <= y"
      expected = "<=\n  x\n  y\n"
      _test(input, expected, RelationalExpression)
   end

   def test_parse_relational_expr2
      input = "x + y <= x * y"
      expected = <<'END'
<=
  +
    x
    y
  *
    x
    y
END
      _test(input, expected, RelationalExpression)
   end

   def test_parse_relational_expr3
      input = "x == empty"
      expected = "empty\n  x\n"
      _test(input, expected, EmptyExpression)
      input = "x != empty"
      expected = "notempty\n  x\n"
      _test(input, expected, EmptyExpression)
   end

   def test_parse_relational_expr4
      input = "x > empty"
      expected = ""
      assert_raise(Kwartz::SyntaxError) do
         _test(input, expected, Expression)
      end
   end

   ##
   def test_parse_logical_and_expr1
      input = "0 < x && x < 10"
      expected = <<END
&&
  <
    0
    x
  <
    x
    10
END
      _test(input, expected, LogicalExpression)
   end

   ##
   def test_parse_logical_or_expr1
      input = "x < 0 || 10 < x"
      expected = <<END
||
  <
    x
    0
  <
    10
    x
END
      _test(input, expected, LogicalExpression)
   end

   def test_parse_logical_or_expr2
      input = "! flag || 0 < x && 10 >= x"
      expected = <<END
||
  !
    flag
  &&
    <
      0
      x
    >=
      10
      x
END
      _test(input, expected, LogicalExpression)
   end

   ##
   def test_parse_conditional_expr1
      input = "x > y ? x : y"
      expected = <<END
?:
  >
    x
    y
  x
  y
END
      _test(input, expected, ConditionalExpression)
   end

   def test_parse_conditional_expr2
      input = "x > y ? x : y > z ? y : z"
      expected = <<END
?:
  >
    x
    y
  x
  ?:
    >
      y
      z
    y
    z
END
      _test(input, expected, ConditionalExpression)
   end

   ##
   def test_parse_assignment_expr1
      input = "x = 1"
      expected = "=\n  x\n  1\n"
      _test(input, expected, AssignmentExpression)
      input = "x += 1"
      expected = "+=\n  x\n  1\n"
      _test(input, expected, AssignmentExpression)
      input = "x -= 1"
      expected = "-=\n  x\n  1\n"
      _test(input, expected, AssignmentExpression)
      input = "x *= 1"
      expected = "*=\n  x\n  1\n"
      _test(input, expected, AssignmentExpression)
      input = "x /= 1"
      expected = "/=\n  x\n  1\n"
      _test(input, expected, AssignmentExpression)
      input = "x .+= 1"
      expected = ".+=\n  x\n  1\n"
      _test(input, expected, AssignmentExpression)
   end

   def test_parse_assignment_expr2
      input = "x = y = z = null"
      expected = <<'END'
=
  x
  =
    y
    =
      z
      null
END
      _test(input, expected, AssignmentExpression)
   end

   ##
   def test_parse_expression1
      input = "val = x > y ? x + 1 : y - 1"
      expected = <<'END'
=
  val
  ?:
    >
      x
      y
    +
      x
      1
    -
      y
      1
END
      _test(input, expected, AssignmentExpression)
   end

end


##
## parse statement test
##
class ParseStatementTest < Test::Unit::TestCase

   def setup
      #@flag_suspend = true
   end

   def _test(input, expected, klass=nil, properties={})
      return if @flag_suspend
      s = caller().first
      s =~ /in `(.*)'/		#'
      testmethod = $1
      method_name = testmethod.sub(/\Atest_/, '').sub(/\d*\z/, '')
      #$stderr.puts "*** debug: method_name=#{method_name.inspect}"
      parser = Parser.new(input, properties)
      expr = parser.__send__(method_name)
      assert_equal(klass, expr.class) if klass
      if klass == Array
         actual = ''
         expr.each do |item|
            actual << item._inspect()
         end
      else
         actual = expr._inspect()
      end
      assert_equal_with_diff(expected, actual)
   end

   ##
   def test_parse_print_stmt1
      input = "print(10, 'abc', true);"
      expected = <<'END'
:print
  10
  "abc"
  true
END
      _test(input, expected, PrintStatement)
   end


   ##
   def test_parse_print_stmt2
      input = "print(a[10], 'foo', obj.prop, \"\\n\");"
      expected = <<'END'
:print
  []
    a
    10
  "foo"
  .
    obj
    prop
  "\n"
END
      _test(input, expected, PrintStatement)
   end


   ##
   def test_parse_expr_stmt1
      input = "a = 10;"
      expected = <<'END'
:expr
  =
    a
    10
END
      _test(input, expected, ExprStatement)
   end


   ##
   def test_parse_expr_stmt2
      input = "a[i-1] += x+2*3;"
      expected = <<'END'
:expr
  +=
    []
      a
      -
        i
        1
    +
      x
      *
        2
        3
END
      begin
      $DEBUG = true
      _test(input, expected, ExprStatement)
      ensure
      $DEBUG = false
      end
   end


   ##
   def test_parse_block_stmt1
      input = <<-'END'
        { print(foo); print(bar); }
      END
      expected = <<-'END'
:block
  :print
    foo
  :print
    bar
      END
      _test(input, expected, BlockStatement)
   end


   ##
   def test_parse_block_stmt2
      input = " { }  "
      expected = <<-'END'
:block
END
      _test(input, expected, BlockStatement)
   end


   ##
   def test_parse_foreach_stmt1
      input = "foreach (item in user.list) print(item);"
      exptected = <<'END'
:foreach
  item
  .
    user
    list
  :print
    item
END
      _test(input, exptected, ForeachStatement)
   end


   ##
   def test_parse_foreach_stmt2
      input = "foreach (item in user.list) { i += 1; print(item); }"
      exptected = <<'END'
:foreach
  item
  .
    user
    list
  :block
    :expr
      +=
        i
        1
    :print
      item
END
      _test(input, exptected, ForeachStatement)
   end


   ##
   def test_parse_while_stmt1
      input = "while(i>0) i-=1;"
      expected = <<'END'
:while
  >
    i
    0
  :expr
    -=
      i
      1
END
      _test(input, expected, WhileStatement)
   end


   ##
   def test_parse_while_stmt2
      input = "while(i>0) { i-=1; print(i); }"
      expected = <<'END'
:while
  >
    i
    0
  :block
    :expr
      -=
        i
        1
    :print
      i
END
      _test(input, expected, WhileStatement)
   end


   ##
   def test_parse_if_stmt1
      input = "if(x>y) max=x;"
      expected = <<'END'
:if
  >
    x
    y
  :expr
    =
      max
      x
END
      _test(input, expected, IfStatement)
   end


   ##
   def test_parse_if_stmt2
      input = "if(x>y) max=x; else max=y;"
      expected = <<'END'
:if
  >
    x
    y
  :expr
    =
      max
      x
  :expr
    =
      max
      y
END
      _test(input, expected, IfStatement)
   end


   ##
   def test_parse_if_stmt3
      input = "if(x>y) max=x; else if (y>z) max=y; else max = z;"
      expected = <<'END'
:if
  >
    x
    y
  :expr
    =
      max
      x
  :if
    >
      y
      z
    :expr
      =
        max
        y
    :expr
      =
        max
        z
END
      _test(input, expected, IfStatement)
   end


   ##
   def test_parse_if_stmt4
      input = "if(x>y) { max=x; } else if (y>z) { max=y; } else { max = z; }"
      expected = <<'END'
:if
  >
    x
    y
  :block
    :expr
      =
        max
        x
  :if
    >
      y
      z
    :block
      :expr
        =
          max
          y
    :block
      :expr
        =
          max
          z
END
      _test(input, expected, IfStatement)
   end



   ##
   def test_parse_if_stmt5
      input = <<'END'
if (x > 10)
  y = 10;
else if (x > 5)
  y = 5;
else if (x > 0)
  y = 0;
else
  y = -1;
END
      expected = <<'END'
:if
  >
    x
    10
  :expr
    =
      y
      10
  :if
    >
      x
      5
    :expr
      =
        y
        5
    :if
      >
        x
        0
      :expr
        =
          y
          0
      :expr
        =
          y
          -.
            1
END
      _test(input, expected)
   end



   ##
   def test_parse_expand_stmt1  # @stag
      input = "@stag;"
      expected = <<'END'
@stag
END
      _test(input, expected, ExpandStatement)
   end


   ##
   def test_parse_expand_stmt2  # @element(foo)
      input = "@element(foo);"
      expected = <<'END'
@element(foo)
END
      _test(input, expected, ExpandStatement)
   end


   ##
   def test_parse_rawcode_stmt1  # <% ... %>, <?php ... ?>
      input = '   <?php foreach($hash as $key => $value) { ?>'
      expected = <<'END'
<?php foreach($hash as $key => $value) { ?>
END
      _test(input, expected, RawcodeStatement)
   end


   ##
   def test_parse_rawcode_stmt2  # :::
      input    = "  :::  int i=0;\n"
      expected =   ":::  int i=0;\n"
      _test(input, expected, RawcodeStatement)
   end


   ##
   def test_parse_stmt_list1
       @flag_suspend = false
       input = <<'END'
 day = 'foo';
END
       expected = <<'END'
:expr
  =
    day
    "foo"
END
       _test(input, expected, Array)
    end


    ##
   def test_parse_stmt_list2
       @flag_suspend = false
       input = <<'END'
 day = 'foo';
 print(day);
 while (i > 0) i -= 1;
END
       expected = <<'END'
:expr
  =
    day
    "foo"
:print
  day
:while
  >
    i
    0
  :expr
    -=
      i
      1
END
       _test(input, expected, Array)
    end



   ##
   def test_parse_program1
      input = <<'END'
a = 1;
print(a);
a = 10;
END
      expected = <<'END'
:block
  :expr
    =
      a
      1
  :print
    a
  :expr
    =
      a
      10
END
      _test(input, expected, BlockStatement)
   end



   ##
   def test_parse_program2	# error linenum
      input = <<'END'
a = 1;
print(a)
a = 10;
END
      expected = ''
      assert_raise(Kwartz::SyntaxError) do
         _test(input, expected, nil)
      end
      begin
         _test(input, expected, nil)
      rescue Kwartz::SyntaxError => ex
         assert_equal(3, ex.linenum)
      end
   end



   ##
   def test_parse_program9    # complex statement list
      input = <<'END'
  day = '&nbsp';
  wday = 1;
  while (wday < first_weekday) {
    if(wday == 1)
      @stag;
    @cont;
    wday += 1;
  }
  day = 0;
  wday -= 1;
  while (day < num_days) {
    day += 1;
    wday = wday % 7 + 1;
    if (wday == 1)
      @stag;
    @cont;
    if(wday == 7)
      @etag;
  }
  if (wday != 7) {
    day = '&nbsp;';
    while (wday != 6) {
      @cont;
      wday += 1;
    }
    @etag;
  }
END

      expected = <<'END'
:block
  :expr
    =
      day
      "&nbsp"
  :expr
    =
      wday
      1
  :while
    <
      wday
      first_weekday
    :block
      :if
        ==
          wday
          1
        @stag
      @cont
      :expr
        +=
          wday
          1
  :expr
    =
      day
      0
  :expr
    -=
      wday
      1
  :while
    <
      day
      num_days
    :block
      :expr
        +=
          day
          1
      :expr
        =
          wday
          +
            %
              wday
              7
            1
      :if
        ==
          wday
          1
        @stag
      @cont
      :if
        ==
          wday
          7
        @etag
  :if
    !=
      wday
      7
    :block
      :expr
        =
          day
          "&nbsp;"
      :while
        !=
          wday
          6
        :block
          @cont
          :expr
            +=
              wday
              1
      @etag
END
      _test(input, expected, BlockStatement)
   end



end


##
## parse declaration test
##
class ParseDeclarationTest < Test::Unit::TestCase

   def setup
      @flag_suspend = false
   end


   def _test(input, expected, klass=nil, properties={}, method_name=nil)
      return if @flag_suspend
      if !method_name
         s = caller().first
         s =~ /in `(.*)'/		#'
         testmethod = $1
         method_name = testmethod.sub(/\Atest_/, '').sub(/\d*\z/, '')
         #$stderr.puts "*** debug: method_name=#{method_name.inspect}"
      end
      parser = Parser.new(input, properties)
      obj = parser.__send__(method_name)
      assert_equal(klass, obj.class) if klass
      actual = ""
      if klass == Array
         if obj[0].is_a?(String)
            actual << obj.collect { |str| str.inspect() }.join(',') << "\n"
         elsif obj[0].is_a?(Declaration)
            obj.each do |elem_decl|
               actual << "[#{elem_decl.name}]\n"
               actual << elem_decl._inspect()
            end
            #actual << obj.keys.sort.collect { |key| "[#{key}]\n#{obj[key]._inspect}" }.join()
         elsif obj[0].is_a?(Expression)
            obj.each do |expr|
               actual << expr._inspect()
            end
         end
      elsif klass == Hash || klass == Kwartz::Util::OrderedHash
         actual << obj.keys.sort.collect { |key| "[#{key}]\n#{obj[key]._inspect}" }.join()
      elsif klass == nil
         actual = obj
      else
         actual << obj._inspect()
      end
      assert_equal_with_diff(expected.to_s, actual.to_s)
   end


   ##
   def test_parse_value_part1
      input = "value: foo;"
      expected = "foo\n"
      _test(input, expected, VariableExpression)
   end


   ##
   def test_parse_value_part2
      input = "value: 'mailto:'.+user.email;"
      expected = <<'END'
.+
  "mailto:"
  .
    user
    email
END
      _test(input, expected, ArithmeticExpression)
   end


   ##
   def test_parse_value_part3
      input = "value: 'mailto:'.+user.email attrs:"
      expected = nil
      assert_raise(Kwartz::SyntaxError) do
         _test(input, expected)
      end
   end


   ##
   def test_parse_value_part4
      @flag_suspend = false
      input = "value: ;"
      expected = ''
      _test(input, expected)
   end


   ##
   def test_parse_attrs_part1
      input = 'attrs: "foo" bar; '
      expected = "[foo]\nbar\n"
      _test(input, expected, Kwartz::Util::OrderedHash)
   end

   ##
   def test_parse_attrs_part2
      input = 'attrs: "class" klass, "href" user.url; '
      expected = "[class]\nklass\n[href]\n.\n  user\n  url\n"
      _test(input, expected, Kwartz::Util::OrderedHash)
   end

   ##
   def test_parse_attrs_part3
      input = 'attrs: "class" klass, "href" user.url '
      expected = ""
      assert_raise(Kwartz::SyntaxError) do
         _test(input, expected, nil)
      end
   end

   ##
   def test_parse_append_part1
      input = 'append: flag ? " checked=\"checked\"" : "";'
      expected = "?:\n  flag\n  \" checked=\\\"checked\\\"\"\n  \"\"\n"
      _test(input, expected, Array)
   end

   ##
   def test_parse_append_part2
      input = 'append: flag ? " checked=\"checked\"" : ""'
      expected = "?:\n  flag\n  \" checked=\\\"checked\\\"\"\n  \"\"\n"
      assert_raise(Kwartz::SyntaxError) do
         _test(input, expected, nil)
      end
   end

   ##
   def test_parse_tagname_part1
      input = 'tagname: "html:html";'
      expected = '"html:html"' + "\n"
      _test(input, expected, StringExpression)
   end

   ##
   def test_parse_tagname_part2
      input = 'tagname: "html:html"'
      expected = '"html:html"' + "\n"
      assert_raise(Kwartz::SyntaxError) do
         _test(input, expected, nil)
      end
   end

   ##
   def test_parse_remove_part1
      input = 'remove: "id";'
      expected = '"id"' + "\n"
      _test(input, expected, Array)
   end

   ##
   def test_parse_remove_part2
      input = 'remove: "id", "class", \'foo\';'
      expected = '"id","class","foo"' + "\n"
      _test(input, expected, Array)
   end

   ##
   def test_parse_remove_part3
      input = 'remove: "id"'
      expected = nil
      assert_raise(Kwartz::SyntaxError) do
         _test(input, expected, nil)
      end
   end

   ##
   def test_parse_plogic_part1
      input = 'plogic: { }'
      expected = ":block\n"
      _test(input, expected, BlockStatement)
   end

   ##
   def test_parse_plogic_part2
      input = 'plogic: { @stag; @cont; @etag; }'
      expected = ":block\n  @stag\n  @cont\n  @etag\n"
      _test(input, expected, BlockStatement)
   end

   ##
   def test_parse_plogic_part3
      input = <<'END'
      plogic: {
       @stag;
       foreach (item in list)
         @cont;
       @etag;
       }
END
      expected = <<'END'
:block
  @stag
  :foreach
    item
    list
    @cont
  @etag
END
      _test(input, expected, BlockStatement)
   end

   ##
   def test_parse_plogic_part4
      input = 'plogic: ;'
      expected = nil
      assert_raise(Kwartz::SyntaxError) do
         _test(input, expected, nil)
      end
   end

#   ##
#   def test_parse_elem_part1
#      input = <<'END'
#value:   user.name;
#attrs:    "class" klass, "bgcolor" color;
#append:  flag ? ' checked="checked"' : '';
#remove:  "id";
#tagname: tag;
#plogic: {
#	@stag;
#	foreach (item in list) {
#	  @cont;
#	}
#	@etag;
#}
#END
#      expected = <<'END'
#append:
#?:
#  flag
#  " checked=\"checked\""
#  ""
#attrs:
#bgcolor=color
#class=klass
#plogic:
#:block
#  @stag
#  :foreach
#    item
#    list
#    :block
#      @cont
#  @etag
#remove:
#id
#tagname:
#tag
#value:
#.
#  user
#  name
#END
#      parser = Kwartz::Parser.new(input)
#      hash = parser.parse_elem_part()
#      s = ''
#      hash.keys.collect{|k| k.to_s}.sort.each do |key|
#         key = key.intern
#         value = hash[key]
#         s << "#{key}:\n"
#         case key
#         when :value, :tagname, :plogic
#            s << value._inspect if value
#         when :append
#            value.each do |v|
#               s << v._inspect()
#            end
#         when :attrs
#            value.keys.sort.each do |k|
#               v = value[k]
#               s << "#{k}=#{v._inspect}"
#            end
#         when :remove
#            s << value.collect{|v| "#{v}"}.join(",") << "\n"
#         else
#            fail("invalid key(='#{key.inspect}')")
#         end
#      end
#      assert_equal_with_diff(expected, s)
#   end

   ##
   def test_parse_element_decl1
      input = <<'END'
foo {
	value:   user.name;
	attrs:   "class" klass, "bgcolor" color;
	append:  flag ? ' checked="checked"' : '';
	remove:  "id";
	tagname: tag;
	plogic: {
		@stag;
		foreach (item in list)
		  @cont;
		@etag;
	}
}
END
      expected = <<'END'
#foo {
  value:
    .
      user
      name
  attrs:
    "bgcolor" color
    "class" klass
  append:
    ?:
      flag
      " checked=\"checked\""
      ""
  remove:
    "id"
  tagname:
    tag
  plogic:
    :block
      @stag
      :foreach
        item
        list
        @cont
      @etag
}
END
      _test(input, expected, Declaration)
   end


   ##
   def test_parse_begin_part1
      input = <<'END'
begin:{
      user_list = args['users'];
      print("<!-- document start -->\n");
   }
END
      expected = <<'END'
:block
  :expr
    =
      user_list
      []
        args
        "users"
  :print
    "<!-- document start -->\n"
END
      _test(input, expected, Kwartz::BlockStatement)
   end


   ##
   def test_parse_end_part1
      input = <<'END'
end:{
      print("<!-- copyright -->\n");
   }
END
      expected = <<'END'
:block
  :print
    "<!-- copyright -->\n"
END
      _test(input, expected, Kwartz::BlockStatement)
   end


   ##
   def test_parse_global_part1
      input = <<'END'
global: foo, bar;
END
      expected = <<'END'
"foo","bar"
END
      _test(input, expected, Array)
   end


   ##
   def test_parse_local_part1
      input = <<'END'
local: foo, bar;
END
      expected = <<'END'
"foo","bar"
END
      _test(input, expected, Array)
   end


   ##
   def test_parse_require_part1
      input = <<'END'
require: 'foo', "bar";
END
      expected = <<'END'
"foo","bar"
END
      _test(input, expected, Array)
   end


   ##
   def test_parse_vartype_part1
      input = <<'END'
vartype: {
	int i;
	String str;
	String[] str_list;
}
END
      expected = <<'END'

END
      #_test(input, expected, Hash)
      parser = Kwartz::Parser.new(input)
      hash = parser.parse_vartype_part()
      assert_equal(Kwartz::Util::OrderedHash, hash.class)
      assert_equal("int", hash["i"])
      assert_equal("String", hash["str"])
      assert_equal("String [ ]", hash["str_list"])
   end


   ##
   def test_parse_document_decl1
      input = <<'END'
DOCUMENT {
   begin: {
      user_list = args['users'];
      title     = args[:title];
      print("<!-- document start -->\n");
   }
   end: {
      print("<!-- copyright(c) 2004-2005 ", copyright, " rights reserved -->\n");
   }
   global: args, copyright;
   require: 'foo', 'bar';
}
END
      expected = <<'END'
#DOCUMENT {
  begin:
    :block
      :expr
        =
          user_list
          []
            args
            "users"
      :expr
        =
          title
          [:]
            args
            "title"
      :print
        "<!-- document start -->\n"
  end:
    :block
      :print
        "<!-- copyright(c) 2004-2005 "
        copyright
        " rights reserved -->\n"
  global: args, copyright;
  require: "foo", "bar";
}
END
      _test(input, expected, Declaration)
   end


   ##
   def test_parse_plogic1
      input = <<'END'
#foo {
	value:   user;
	attrs:   "class" klass, "bgcolor" color;
	plogic: {
		@stag;
		foreach (item in list)
		  @cont;
		@etag;
	}
}

#bar {
   plogic: {
      @cont;
   }
}
END
      expected = <<'END'
[foo]
#foo {
  value:
    user
  attrs:
    "bgcolor" color
    "class" klass
  plogic:
    :block
      @stag
      :foreach
        item
        list
        @cont
      @etag
}
[bar]
#bar {
  plogic:
    :block
      @cont
}
END
      _test(input, expected, Array)
   end


end


##
## main
##
if $0 == __FILE__
    Test::Unit::UI::Console::TestRunner.run(ParseExpressionTest)
    Test::Unit::UI::Console::TestRunner.run(ParseStatementTest)
    Test::Unit::UI::Console::TestRunner.run(ParseDeclarationTest)
    #suite = Test::Unit::TestSuite.new()
    #suite << ParseExpressionTest.suite()
    #suite << ParseStatementTest.suite()
    #Test::Unit::UI::Console::TestRunner.run(suite)
end
