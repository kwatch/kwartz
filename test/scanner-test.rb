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
require 'kwartz/scanner'


class ScannerTest < Test::Unit::TestCase

    $flag_test = true		# do test or not


    ### --------------------
    ### scan all
    ### --------------------
    def _test(input, expected, flag_test=$flag_test)
	return unless flag_test
	input.gsub!(/^\t\t/, '')
	expected.gsub!(/^\t\t/, '')
	scanner = Kwartz::Scanner.new(input)
	actual = scanner.scan_all()
	#assert_equal(expected, actual)
	assert_equal_with_diff(expected, actual)
    end

    
    def test_scan1	# plogic
	input = <<-'END'
		:macro(foo)
		  @stag
		  :foreach(user=user_list)
		    :print("<td>", user[:name], "</td>\n")
		  :end
		  @etag
		:end
	END
	expected = <<-'END'
		:macro
		(
		foo
		)
		@stag
		:foreach
		(
		user
		=
		user_list
		)
		:print
		(
		"<td>"
		,
		user
		[:
		name
		]
		,
		"</td>\n"
		)
		:end
		@etag
		:end
	END
	_test(input, expected)
    end
    
    
    def test_scan2	# #element, #macro, #end
	input = <<-END
		#macro cont_foo
		  :print('<td class="', klass, '">', value, '</td>')
		#end
		#element foo
		  user_list.each_with_index { |user, index|
		    klass = index % 2 == 0 ? 'odd' : 'even'
		    @stag
		    @cont
		    @etag
		  }
		#end
	END
	expected = <<-'END'
		#macro cont_foo
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
		#end
		#element foo
		:rubycode  user_list.each_with_index { |user, index|
		:rubycode    klass = index % 2 == 0 ? 'odd' : 'even'
		@stag
		@cont
		@etag
		:rubycode  }
		#end
	END
	_test(input, expected)
    end


    def test_scan3	# string '...'
	input = <<-'END'
		:print('foo\'s"bar"\n\r\t\\\'')
	END
	expected = <<-'END'
		:print
		(
		"foo's\"bar\"\\n\\r\\t\\'"
		)
	END
	_test(input, expected)
    end


    def test_scan4	# string "..."
    	input = <<-'END'
		:print("foo\'s\"bar\"\n\r\t\\\'")
	END
    	expected = <<-'END'
		:print
		(
		"foo\\'s\"bar\"\n\r\t\\\\'"
		)
	END
	_test(input, expected)
    end
    

    def test_scan5	# unclosed string '...
	input = <<-END
		:print('fooo)
		:set(v=1)
	END
	expected = ""
	assert_raise(Kwartz::ScanError) {
	    _test(input, expected)
	}
    end


    def test_scan6	# unclosed string "...
	input = <<-END
		:print("fooo)
		:set(v=1)
	END
	expected = ""
	assert_raise(Kwartz::ScanError) {
	    _test(input, expected)
	}
    end


    def test_scan7	# comment
	input = <<-'END'
## comment
#element foo
     # :foreach(item=list)
     @stag
     @cont
     @etag
     # :end
#end
	END
	expected = <<-'END'
#element foo
@stag
@cont
@etag
#end
	END
	_test(input, expected)
    end


    def test_scan8	# invalid ruby code
	input = <<-'END'
		#element foo
		for item in list do
		  @stag
		  @cont
		  @etag
		end
		#end
	END
	expected = <<-'END'
		#element foo
		:rubycodefor item in list do
		@stag
		@cont
		@etag
		:rubycodeend
		#end
	END
	assert_raise(Kwartz::ScanError) {
		_test(input, expected)
	}
    end


    def test_scan9	#
	input = <<-'END'
		:set(x=1+=2-=3*=4/=5%=6^=7.+=8)
		:print(foo.bar[:key].+str?'even':'odd')
		:print(a>b>=c<d<=e!f!=g==h=i&&j||k)
	END
	expected = <<-'END'
		:set
		(
		x
		=
		1
		+=
		2
		-=
		3
		*=
		4
		/=
		5
		%=
		6
		^=
		7.
		+=
		8
		)
		:print
		(
		foo
		.
		bar
		[:
		key
		]
		.+
		str
		?
		"even"
		:
		"odd"
		)
		:print
		(
		a
		>
		b
		>=
		c
		<
		d
		<=
		e
		!
		f
		!=
		g
		==
		h
		=
		i
		&&
		j
		||
		k
		)
	END
	_test(input, expected)
    end


    def test_scan10	# keywords
	input = <<-'END'
		:print(true, false, nil, null, empty)
	END
	expected = <<-'END'
:print
(
:true
,
:false
,
:null
,
:null
,
:empty
)
	END
	_test(input, expected)
    end


    def test_scan11	# invalid keyword
	input = <<-'END'
		:for(user in list)
		:end
	END
	expected = ""
	assert_raise(Kwartz::ScanError) {
	    _test(input, expected)
	}
    end


end


if $0 == __FILE__
    Test::Unit::UI::Console::TestRunner.run(ScannerTest)
    #suite = Test::Unit::TestSuite.new()
    #suite << ScannerTest.suite()
    #Test::Unit::UI::Console::TestRunner.run(suite)
end
