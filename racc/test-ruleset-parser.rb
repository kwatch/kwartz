
require 'test/unit'
require 'node'
require 'parser'
require 'yaml'
require 'kwartz/util'
require 'kwartz/util/testcase-helper'
require 'kwartz/util/assert-text-equal'


class RulesetParserTest < Test::Unit::TestCase


  yaml_filename = __FILE__.sub(/\.\w+$/, '.yaml')
  load_yaml_testdata(yaml_filename)


  def _test
    return if ENV['TEST'] && ENV['TEST'] != @name
    parser = Kwartz::RulesetParser.new(@input)
    if @exception
      error_class = @exception.split(/::/).inject(Object) { |m, name| m.const_get(name) }
      ex = assert_raise(error_class) do
        parser.parse()
      end
      assert_equal(@errormsg, ex.message) if @errormsg
    else
      rulesets = parser.parse()
      actual = rulesets.collect {|ruleset| ruleset._inspect}.join
      assert_text_equal(@expected, actual)
    end
  end


end
