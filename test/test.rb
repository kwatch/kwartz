#!/usr/bin/ruby

###
### $Id$
###

$: << 'test'

require 'test/unit'

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

Test::Unit::UI::Console::TestRunner.run(suite)
