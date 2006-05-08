
base_testnames = %w[test-directives test-compile test-handlers]

recipe :test   	 		    		 do
        rm_rf 'test.log'
        base_testnames.each do |name|
          sys "ruby test/#{name}.rb 2>&1 | tee -a test.log"
        end
    end
