#!/usr/bin/ruby

###
### unit test for Converter
###
### $Id$
###

$: << 'lib'
$: << '../lib'
$: << 'test'

require 'test/unit'
require 'test/unit/ui/console/testrunner'
require 'assert-diff.rb'
require 'kwartz/scanner'


class ScannerTest < Test::Unit::TestCase

   def _test(input, expected, flag_test=true)
      return unless flag_test
      input.gsub!(/^\t\t/, '')
      expected.gsub!(/^\t\t/, '')
      scanner = Kwartz::Scanner.new(input)
      actual = scanner.scan_all()
      #assert_equal(expected, actual)
      assert_equal_with_diff(expected, actual)
   end


    def test_scan_plogic2	# element, macro, end
	input = <<-END
		macro cont_foo {
		  print('<td class="', klass, '">', value, '</td>');
		}
		element foo {
		  i = 0;
		  foreach (user in list) {
		    klass = i % 2 == 0 ? 'odd' : 'even';
		    @stag;
		    @cont;
		    @etag;
		  }
		}
	END
	expected = <<-'END'
		:macro
		cont_foo
		{
		:print
		(
		"<td class=\""
		,
		klass
		,
		"\">"
		,
		value
		,
		"</td>"
		)
		;
		}
		:element
		foo
		{
		i
		=
		0
		;
		:foreach
		(
		user
		:in
		list
		)
		{
		klass
		=
		i
		%
		2
		==
		0
		?
		"odd"
		:
		"even"
		;
		@stag
		;
		@cont
		;
		@etag
		;
		}
		}
	END
	_test(input, expected)
    end

    def test_scan_keywords	# keywords
       input = <<-'END'
		expand
		element
		macro

		value:
		attr:
		append:
		remove:
		tagname:
		plogic:
		value
		attr
		append
		remove
		tagname
		plogic

		print
		while
		foreach
		for
		in
		if
		else
		elseif
		require

		true
		false
		null
		empty
       END
       expected = <<-'END'
		:expand
		:element
		:macro
		value
		:
		attr
		:
		append
		:
		remove
		:
		tagname
		:
		plogic
		:
		value
		attr
		append
		remove
		tagname
		plogic
		:print
		:while
		:foreach
		:for
		:in
		:if
		:else
		:elseif
		require
		:true
		:false
		:null
		:empty
       END
       _test(input, expected)
    end

    
    def test_scan_rawcode1	# rawcode statement
       input = <<-'END'
		:::  pulic int i = 0;
		<% foo %>
		<?php echo $foo; ?>
       END
#       expected = <<-'END'
#		  pulic int i = 0;
#		<%= foo %>
#		<?php echo $foo; ?>
#       END
       expected = <<-'END'
		<%  pulic int i = 0;%>
		<% foo %>
		<%php echo $foo; %>
       END
       _test(input, expected)
    end


    def test_scan_rawcode2	# rawcode expression
       input = <<-'END'
		<%= foo %>
		<?= $foo ?>
       END
       expected = <<-'END'
		<%= foo %>
		<%= $foo %>
       END
       _test(input, expected)
    end


    def test_scan_rawcode3	# unclosed rawcode
       input = "<% foo ?>"
       expected = ""
       assert_raise(Kwartz::ScanError) do
          _test(input, expected)
       end
       input = "<%= foo ?>"
       expected = ""
       assert_raise(Kwartz::ScanError) do
          _test(input, expected)
       end
    end
    
    
    def test_scan_rawcode4	# unterminated rawcode
       input = "<? foo "
       expected = ""
       assert_raise(Kwartz::ScanError) do
          _test(input, expected)
       end
       input = "<?= foo "
       expected = ""
       assert_raise(Kwartz::ScanError) do
          _test(input, expected)
       end
    end
    

    
    def test_scan_operators1
       input = <<-'END'
		+-*/%!=<><=>===!=+=-=*=/=%=

       END
       expected = <<-'END'
		+
		-
		*
		/
		%
		!=
		<
		>
		<=
		>=
		==
		!=
		+=
		-=
		*=
		/=
		%=
       END
       _test(input, expected)
    end


    def test_scan_operators2
       input = <<-'END'
		{}[][:][:if]()

       END
       expected = <<-'END'
		{
		}
		[
		]
		[:
		]
		[:
		:if
		]
		(
		)
       END
       _test(input, expected)
    end


    def test_scan_chars1
    	input = <<-'END'
		!^&&||:;,.?

	END
	expected = <<-'END'
		!
		^
		&&
		||
		:
		;
		,
		.
		?
	END
        _test(input, expected)
    end

    def test_scan_chars2
       expected = ''
       assert_raise(Kwartz::ScanError) do
          _test('$100', "")
       end
       assert_raise(Kwartz::ScanError) do
          _test('~', "")
       end
       assert_raise(Kwartz::ScanError) do
          _test('`', "")
       end
       assert_raise(Kwartz::ScanError) do
          _test('\\', "")
       end
       assert_raise(Kwartz::ScanError) do
          _test('&foo', "")
       end
       assert_raise(Kwartz::ScanError) do
          _test('|foo', "")
       end
    end


    def test_scan_string1
    	input = <<-'END'
		"foo" 'bar'
		"who's whoo" 'who"s whoo'
		"\t\r\n" '\t\r\n'
	END
	expected = <<-'END'
		"foo"
		"bar"
		"who's whoo"
		"who\"s whoo"
		"\t\r\n"
		"\\t\\r\\n"
	END
       _test(input, expected)
    end

    def test_scan_string2  # unclosed string "foo
       input = <<-'END'
		"foo
		;
       END
       #"
       expected = ''
       assert_raise(Kwartz::ScanError) do
          _test(input, expected)
       end
    end


    def test_scan_string3  # unclosed string 'foo
       input = <<-'END'
		'foo
		;
       END
       #'
       expected = ''
       assert_raise(Kwartz::ScanError) do
          _test(input, expected)
       end
    end


    def test_scan_space1  # bug: empty text
       input = "   "
       expected = ''
       _test(input, expected)
    end
    
    
    def test_scan_comment1	# line comment
       input = "// comment"
       expected = ''
       _test(input, expected)
       input = "hoge // comment\n // comment \ngeji //comment"
       expected = "hoge\ngeji\n"
       _test(input, expected)
    end

    def test_scan_comment2	# region comment
       input = "/* region comment */"
       expected = ''
       _test(input, expected)
       input = "hoge /* comment */\n /* comment \n comment */ geji"
       expected = "hoge\ngeji\n"
       _test(input, expected)
    end

end



if $0 == __FILE__
    Test::Unit::UI::Console::TestRunner.run(ScannerTest)
    #---
    #suite = Test::Unit::TestSuite.new()
    #suite << ScannerTest.suite()
    #Test::Unit::UI::Console::TestRunner.run(suite)
end
