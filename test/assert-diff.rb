require 'test/unit'
require 'tempfile'

module Test
  module Unit
    class TestCase
      def assert_equal_with_diff(expected, actual, diffopt='-u', flag_cut=true)
        if expected == actual
          assert(true)
          return
        end
        
        if expected[-1] != ?\n || actual[-1] != ?\n
          expected += "\n"
          actual   += "\n"
        end
        expfile = Tempfile.new(".expected.")
        expfile.write(expected); expfile.flush()
        actfile = Tempfile.new(".actual.")
        actfile.write(actual);   actfile.flush()
        diff = `diff #{diffopt} #{expfile.path} #{actfile.path}`
        expfile.close(true)
        actfile.close(true)
        
        # cut 1st & 2nd lines
        message = flag_cut ? diff.gsub(/\A.*\n.*\n/, '') : diff
        #raise Test::Unit::AssertionFailedError.new(message)
        assert_block(message) { false }  # or assert(false, message)
      end
    end
  end
end
