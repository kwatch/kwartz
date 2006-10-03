
require 'test/unit'
require 'node'
require 'parser'
require 'yaml'
require 'kwartz/util'
require 'kwartz/util/testcase-helper'
require 'kwartz/util/assert-text-equal'


class ExpressionParserTest < Test::Unit::TestCase


  yaml_filename = __FILE__.sub(/\.\w+$/, '.yaml')
  load_yaml_testdata(yaml_filename)


  def _test
    return if ENV['TEST'] && ENV['TEST'] != @name
    if @exception
      error_class = @exception.split(/::/).inject(Object) { |m, name| m.const_get(name) }
      inputs = @input.is_a?(Array) ? @input : [ @input ]
      inputs.each do |input|
        parser = Kwartz::ExpressionParser.new(input)
        ex = assert_raise(error_class) do
          parser.parse()
        end
        assert_equal(@errormsg, ex.message) if @errormsg
      end
    else
      parser = Kwartz::ExpressionParser.new(@input)
      expr = parser.parse()
      assert_text_equal(@expected, expr._inspect)
    end
  end


end
