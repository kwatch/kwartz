<?php

###
### KwartzHelperTest.php
###

require_once('PHPUnit.php');
require_once('Kwartz/KwartzHelper.php');

class KwartzHelperTest extends PHPUnit_TestCase {

	var $pdata_filename = '.helpertest.pdata';
	var $plogic_filename = '.helpertest.plogic';
	var $output_filename = '.helpertest.view';
	
	var $pdata = 
'<ul id="mark:list">
 <li id="value:item">foo</li>
</ul>
';
	var $plogic = 
'element list {
  @stag;
  foreach ($list as $item) {
    @cont;
  }
  @etag;
}
';
	var $output =
'<ul>
<?php foreach ($list as $item) { ?>
 <li><?php echo $item; ?></li>
<?php } ?>
</ul>
';

	var $output_without_plogic =
'<ul>
 <li><?php echo $item; ?></li>
</ul>
';

	var $dummy = "***dummy***\n";


	function __construct($name) {
		$this->PHPUnit_TestCase($name);
	}

	function setUp() {
		$f = fopen($this->pdata_filename, "wb");
		fwrite($f, $this->pdata);
		fclose($f);
		$f = fopen($this->plogic_filename, "wb");
		fwrite($f, $this->plogic);
		fclose($f);
		$f = fopen($this->output_filename, "wb");
		fwrite($f, $this->dummy);			## dummy data
		fclose($f);
	}
	
	function tearDown() {
		//$this->remove('all');
		if (file_exists($this->pdata_filename)) {
			unlink($this->pdata_filename);
		}
		if (file_exists($this->plogic_filename)) {
			unlink($this->plogic_filename);
		}
		if (file_exists($this->output_filename)) {
			unlink($this->output_filename);
		}
	}


	function _test_compile_template($pdata_filename, $plogic_filename, $output_filename, $flag_escape, $lang='php', $toppings=NULL) {
	}
	
	function test_compile_template1() {	# output script is not exist
		unlink($this->output_filename);
		kwartz_compile_template($this->pdata_filename, $this->plogic_filename, $this->output_filename, FALSE);
		$output = file_get_contents($this->output_filename);
		//echo $output;
		$expected = $this->output;
		$this->assertEquals($expected, $output);
	}

	function test_compile_template2() {	# output script is the newest
		sleep(1);
		touch($this->output_filename);
		kwartz_compile_template($this->pdata_filename, $this->plogic_filename, $this->output_filename, FALSE);
		$output = file_get_contents($this->output_filename);
		//echo $output;
		$expected = $this->dummy;
		$this->assertEquals($expected, $output);
	}

	function test_compile_template3() {	# output script is older than pdata file
		sleep(1);
		touch($this->pdata_filename);
		kwartz_compile_template($this->pdata_filename, $this->plogic_filename, $this->output_filename, FALSE);
		$output = file_get_contents($this->output_filename);
		//echo $output;
		$expected = $this->output;
		$this->assertEquals($expected, $output);
	}

	function test_compile_template4() {	# output script is older than plogic file
		sleep(1);
		touch($this->plogic_filename);
		kwartz_compile_template($this->pdata_filename, $this->plogic_filename, $this->output_filename, FALSE);
		$output = file_get_contents($this->output_filename);
		//echo $output;
		$expected = $this->output;
		$this->assertEquals($expected, $output);
	}

	function test_compile_template5() {	# plogic and output is not exist
		unlink($this->plogic_filename);
		unlink($this->output_filename);
		kwartz_compile_template($this->pdata_filename, NULL, $this->output_filename, FALSE);
		$output = file_get_contents($this->output_filename);
		//echo $output;
		$expected = $this->output_without_plogic;
		$this->assertEquals($expected, $output);
	}

	function test_compile_template6() {	# plogic is not exist and output is older than pdata
		unlink($this->plogic_filename);
		sleep(1);
		touch($this->pdata_filename);
		//echo "*** debug: filemtime(pdata_filename)="  , filemtime($this->pdata_filename) ,"\n";
		//echo "*** debug: filemtime(output_filename)=" , filemtime($this->output_filename) , "\n";
		kwartz_compile_template($this->pdata_filename, NULL, $this->output_filename, FALSE);
		$output = file_get_contents($this->output_filename);
		//echo $output;
		$expected = $this->output_without_plogic;
		$this->assertEquals($expected, $output);
	}

	function test_compile_template7() {	# plogic is not exist and output is newer than pdata
		unlink($this->plogic_filename);
		sleep(1);
		touch($this->output_filename);
		//echo "*** debug: filemtime(pdata_filename)="  , filemtime($this->pdata_filename) ,"\n";
		//echo "*** debug: filemtime(output_filename)=" , filemtime($this->output_filename) , "\n";
		kwartz_compile_template($this->pdata_filename, NULL, $this->output_filename, FALSE);
		$output = file_get_contents($this->output_filename);
		//echo $output;
		$expected = $this->dummy;
		$this->assertEquals($expected, $output);
	}

}


###
### execute test
###
//if ($argv[0] == 'KwartzHelperTest.php') {
	$suite = new PHPUnit_TestSuite('KwartzHelperTest');
	$result = PHPUnit::run($suite);
	//echo $result->toHTML();
	echo $result->toString();
//}
?>
