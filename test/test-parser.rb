###
### $Rev$
### $Release$
### $Copyright$
###

require "#{File.dirname(__FILE__)}/test.rb"


class ParserTest < Test::Unit::TestCase

  ## define test methods
  filename = __FILE__.sub(/\.rb$/, '.yaml')
  load_yaml_testdata(filename)

  def _test
    begin
      eval @setup if @setup
      __test
    ensure
      eval @teardown if @teardown
    end
  end

  def __test
    case @parser
    when 'RubyStyleParser'
      parser = Kwartz::RubyStyleParser.new()
    when 'CssStyleParser'
      parser = Kwartz::CssStyleParser.new()
    else
      raise "*** invalid parser class: #{@parser}"
    end
    if @name =~ /scan/
      actual = ''
      parser.__send__ :reset, @input
      while (ret = parser.scan()) != nil
        actual << "#{parser.linenum}:#{parser.column}:"
        actual << " token=#{parser.token.inspect}, value=#{parser.value.inspect}\n"
        break if ret == :error
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
