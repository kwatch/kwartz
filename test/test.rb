#!/usr/bin/ruby

$: << 'test'

require 'test/unit'

suite = Test::Unit::TestSuite.new()

require 'converter-test'
suite << ConverterTest.suite()

require 'scanner-test'
suite << ScannerTest.suite()

Test::Unit::UI::Console::TestRunner.run(suite)
