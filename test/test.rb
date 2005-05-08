#!/usr/bin/ruby

###
### $Id$
###

$: << 'test'

require 'test/unit'

flag_quick = true
if ARGV[0] && ARGV[0] == '-q'
   flag_quick = false
   ARGV.shift
end

suite = Test::Unit::TestSuite.new()

require 'converter-test'
suite << ConverterTest.suite()

require 'scanner-test'
suite << ScannerTest.suite()

require 'node-test'
suite << ExpressionTest.suite()
suite << StatementTest.suite()

require 'parser-test'
suite << ParseExpressionTest.suite()
suite << ParseStatementTest.suite()
suite << ParseDeclarationTest.suite()

require 'element-test'
suite << ElementTest.suite()

require 'translator-test'
suite << TranslatorTest.suite()

require 'compiler-test'
suite << CompilerTest.suite()
suite << SpanTest.suite()

require 'analyzer-test'
suite << AnalyzerTest.suite()

require 'defun-test'
suite << DefunTest.suite()

unless flag_quick
   require 'examples-test'
   suite << ExamplesTest.suite()
end

Test::Unit::UI::Console::TestRunner.run(suite)
