<?php

###
### KwartzAnalyzerTest.php
###

require_once('PHPUnit.php');
require_once('Kwartz/KwartzAnalyzer.php');
require_once('Kwartz/KwartzParser.php');
require_once('Kwartz/KwartzNode.php');
require_once('Kwartz/KwartzParser.php');
require_once('Kwartz/KwartzConverter.php');

class KwartzAnalyzerTest extends PHPUnit_TestCase {

	function _test($pdata, $plogic, $expected, $flag_test=TRUE) {
		$expected = preg_replace('/^\t\t/m', '', $expected);
		#$expected = preg_replace('/^\n/',    '', $expected);

		$pdata_block = NULL;
		if ($pdata) {
			$converter = new KwartzConverter($pdata);
			$pdata_block = $converter->convert();
		}
		$plogic_block = NULL;
		if ($plogic) {
			$parser = new KwartzParser($plogic);
			$plogic_block = $parser->parse();
		}
		if ($pdata_block == NULL) {
			$block = $plogic_block;
		} elseif ($plogic_block == NULL) {
			$block = $pdata_block;
		} else {
			$list = array_merge($pdata_block->statements(), $plogic_block->statements());
			$block = new KwartzBlockStatement($list);
		}
		assert($block != NULL);

		$analyzer = new KwartzAnalyzer($block);
		$analyzer->analyze();

		$s = "\n";

		$s .= "global vars:";
		$warned_globals = array();
		$global_vars = $analyzer->global_vars();
		ksort($global_vars);
		foreach ($global_vars as $name => $flag_warning) {
			$s .= " ${name}";
			if ($flag_warning) { $warned_globals[] = $name; }
		}
		$s .= "\n";

		$s .= "local vars:";
		$warned_locals = array();
		$local_vars = $analyzer->local_vars();
		ksort($local_vars);
		foreach ($local_vars as $name => $flag_warning) {
			$s .= " ${name}";
			if ($flag_warning) { $warned_locals[] = $name; }
		}
		$s .= "\n";

		$s .= "warned global vars:";
		sort($warned_globals);
		foreach ($warned_globals as $name) {
			$s .= " $name";
		}
		$s .= "\n";

		$s .= "warned local vars:";
		sort($warned_locals);
		foreach ($warned_locals as $name) {
			$s .= " $name";
		}
		$s .= "\n";
		
		$actual = $s;

		if ($flag_test) {
			$this->assertEquals($expected, $actual);
		} else {
		}
	}
	
	function test_analyze1() {
		$plogic = '
		:set(x = 1)
		:print(x, y)
		';
		$expected ='
		global vars: y
		local vars: x
		warned global vars:
		warned local vars:
		';
		$this->_test('', $plogic, $expected);
	}


	function test_analyze2() {
		$plogic = '
		:set(x += 1)
		:set(y = y*1)
		:set(z = 0)
		:set(z += 1)
		';
		$expected ='
		global vars: y
		local vars: x z
		warned global vars: y
		warned local vars: x
		';
		$this->_test('', $plogic, $expected);
	}
	


	function test_analyze3() {
		$plogic = '
		:print(a[0])
		:set(b[0]=c[:key])
		:set(c=0)
		';
		$expected ='
		global vars: a b c
		local vars:
		warned global vars: b c
		warned local vars:
		';
		$this->_test('', $plogic, $expected);
	}


	function test_analyze4() {
		$plogic = '
		:set(ctr = 0)
		:foreach(item = list)
		  :set(ctr += 1)
		  :foreach(value = item.values)
		    :print(value)
		  :end
		:end
		';
		$expected ='
		global vars: list
		local vars: ctr item value
		warned global vars:
		warned local vars:
		';
		$this->_test('', $plogic, $expected);
	}



	function test_analyze_macro1() {
		$plogic = '
		:element(user)
		  @stag
		  @cont
		  @etag
		:end
		:macro(stag_user)
		  :print("<tr>")
		:end
		:macro(cont_user)
		  :print("<td>", user, "</td>")
		:end
		:macro(etag_user)
		  :print("</tr>\n")
		:end
		@element_user
		:element(user)
		  :set(ctr=0)
		  :foreach(user = list)
		    :set(ctr += 1)
		    @stag
		    @cont
		    @etag
		  :end
		:end
		';

		$expected ='
		global vars: list
		local vars: ctr user
		warned global vars:
		warned local vars:
		';
		$this->_test('', $plogic, $expected);
	}



	function test_analyze_macro2() {
		$pdata = '
		<?php
			$year = 2004;
			$month = 10;
			$first_weekday = 6;
			$num_days = 31;
		?>
		<html>
		  <body>
		
		    <table cellpadding="2" summary="">
		      <caption>
		        <i id="value:month">Jan</i>&nbsp;<i id="value:year">20XX</i>
		      </caption>
		      <thead>
		        <tr bgcolor="#CCCCCC">
		          <th><span class="holiday">S</span></th>
		          <th>M</th><th>T</th><th>W</th><th>T</th><th>F</th><th>S</th>
		        </tr>
		      </thead>
		      <tbody>
		        <tr id="mark:week">
		          <td><span id="mark:day" class="holiday">&nbsp;</span></td>
		          <td id="dummy:d1">&nbsp;</td>
		          <td id="dummy:d2">1</td>
		          <td id="dummy:d3">2</td>
		          <td id="dummy:d4">3</td>
		          <td id="dummy:d5">4</td>
		          <td id="dummy:d6">5</td>
		        </tr>
		        <tr id="dummy:w1">
		          <td><span class="holiday">6</span></td>
		          <td>7</td><td>8</td><td>9</td>
		          <td>10</td><td>11</td><td>12</td>
		        </tr>
		        <tr id="dummy:w2">
		          <td><span class="holiday">13</span></td>
		          <td>14</td><td>15</td><td>16</td>
		          <td>17</td><td>18</td><td>19</td>
		        </tr>
		        <tr id="dummy:w3">
		          <td><span class="holiday">20</span></td>
		          <td>21</td><td>22</td><td>23</td>
		          <td>24</td><td>25</td><td>26</td>
		        </tr>
		        <tr id="dummy:w4">
		          <td><span class="holiday">27</span></td>
		          <td>28</td><td>29</td><td>30</td>
		          <td>31</td><td>&nbsp;</td><td>&nbsp;</td>
		        </tr>
		      </tbody>
		    </table>
		    &nbsp;
		
		  </body>
		</body>
		';

		$plogic = '
		element week {
		
		    $day = \'&nbsp;\';
		    $wday = 1;
		    while ($wday < $first_weekday) {
		        if ($wday == 1) {
		            @stag;
		        }
		        @cont;
		        $wday += 1;
		    }
		
		    $day = 0;
		    $wday -= 1;
		    while ($day < $num_days) {
		        $day += 1;
		        $wday = $wday % 7 + 1;
		        if ($wday == 1) {
		            @stag;
		        }
		        @cont;
		        if ($wday == 7) {
		            @etag;
		        }
		    }
		
		    if ($wday != 7) {
		        $day = \'&nbsp;\';
		        while ($wday != 6) {
		            $wday += 1;
		            @cont;
		        }
		        @etag;
		    }
		
		}
		
		element day {
		    if ($wday == 1) {
			@stag
			echo $day;
			@etag;
		    } else {
			echo $day;
		    }
		}
		';

		$expected  = '
		global vars: first_weekday month num_days year
		local vars: day wday
		warned global vars:
		warned local vars:
		';
		
		$this->_test($pdata, $plogic, $expected);
	}

}


###
### execute test
###
//if ($argv[0] == 'KwartzAnalyzerTest.php') {
	$suite = new PHPUnit_TestSuite('KwartzAnalyzerTest');
	$result = PHPUnit::run($suite);
	//echo $result->toHTML();
	echo $result->toString();
//}
?>

