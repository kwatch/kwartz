<?php

###
### KwartzCompilerTest.php
###

require_once('PHPUnit.php');
require_once('KwartzCompiler.inc');

class KwartzCompilerTest extends PHPUnit_TestCase {

	function __construct($name) {
		$this->PHPUnit_TestCase($name);
	}


	function _test($pdata, $plogic, $expected, $flag_test=TRUE) {
		$pdata    = preg_replace('/^\t\t/m', '', $pdata);
		$plogic   = preg_replace('/^\t\t/m', '', $plogic);
		$expected = preg_replace('/^\t\t/m', '', $expected);
		//echo "*** debug: pdata=$pdata\n";
		//echo "*** debug: plogic=$plogic\n";
		$compiler = new KwartzCompiler($pdata, $plogic);
		$code = $compiler->compile();
		$actual = $code;
		if ($flag_test) {
			$this->assertEquals($expected, $code);
		}
		return $compiler;
	}

	
	function test_compile1() {
		$pdata = <<<END
		<html>
		 <body>
		  <table>
		   <tr class="odd" id="mark:user" kd="attr:class:klass">
		    <td id="value:user['name']">foo</td>
		    <td id="value:user['mail']">foo@mail.com</td>
		   </tr>
		   <tr class="even" id="dummy:d1">
		    <td>bar</td>
		    <td>bar@mail.com</td>
		   </tr>
		  </table>
		 </body>
		</html>
END;

		$pdata_php = <<<END
		<html>
		 <body>
		  <table>
		   <tr class="odd" php="mark(user);attr('class'=>\$klass)">
		    <td php="echo(\$user['name'])">foo</td>
		    <td php="echo(\$user['mail'])">foo@mail.com</td>
		   </tr>
		   <tr class="even" php="dummy(d1)">
		    <td>bar</td>
		    <td>bar@mail.com</td>
		   </tr>
		  </table>
		 </body>
		</html>
END;

		$plogic = <<<END
		:elem(user)
		  :set(i = 0)
		  :foreach(user = user_list)
		    :set(i += 1)
		    :set(klass = i%2==0 ? 'even' : 'odd')
		    @stag
		    @cont
		    @etag
		  :end
		:end
END;


		$plogic_php = <<<END
		element user {
		  \$i = 0;
		  foreach (\$user_list as \$user) {
		    \$i += 1;
		    \$klass = \$i % 2 == 0 ? 'even' : 'odd';
		    @stag;
		    @cont;
		    @etag;
		  }
		}
END;
		$expected = <<<END
		<html>
		 <body>
		  <table>
		<?php \$i = 0; ?>
		<?php foreach (\$user_list as \$user) { ?>
		  <?php \$i += 1; ?>
		  <?php \$klass = \$i % 2 == 0 ? "even" : "odd"; ?>
		   <tr class="<?php echo \$klass; ?>">
		    <td><?php echo \$user["name"]; ?></td>
		    <td><?php echo \$user["mail"]; ?></td>
		   </tr>
		<?php } ?>
		  </table>
		 </body>
		</html>
END;

		$this->_test($pdata,     $plogic,     $expected);
		$this->_test($pdata,     $plogic_php, $expected);
		$this->_test($pdata_php, $plogic,     $expected);
		$this->_test($pdata_php, $plogic_php, $expected);
	}


	function test_compile2() {
		$pdata = <<<END
		<a href="#{url}#" id="mark:link">next page</a>

END;
		$pdata_php = <<<END
		<a href="#{url}#" php="mark(link)">next page</a>

END;
		$plogic = <<<END
		:elem(link)
		  :if (url != null)
		    @stag
		    @cont
		    @etag
		  :else
		    @cont
		  :end
		:end
END;

		$plogic_php = <<<END
		element link {
		  if (\$url != NULL) {
		    @stag;
		    @cont;
		    @etag;
		  } else {
		    @cont;
		  }
		}
END;

		$expected = <<<END
		<?php if (\$url != NULL) { ?>
		<a href="<?php echo \$url; ?>">next page</a>
		<?php } else { ?>
		next page<?php } ?>

END;
		$this->_test($pdata, $plogic,     $expected);
		$this->_test($pdata, $plogic_php, $expected);
		$this->_test($pdata_php, $plogic,     $expected);
		$this->_test($pdata_php, $plogic_php, $expected);
	}



	function test_compile3() {
		$pdata = <<<END
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

END;

		$pdata_php = <<<END
		<table cellpadding="2" summary="">
		  <caption>
		    <i php="echo(\$month)">Jan</i>&nbsp;<i php="echo(\$year)">20XX</i>
		  </caption>
		  <thead>
		    <tr bgcolor="#CCCCCC">
		      <th><span class="holiday">S</span></th>
		      <th>M</th><th>T</th><th>W</th><th>T</th><th>F</th><th>S</th>
		    </tr>
		  </thead>
		  <tbody>
		    <tr php="mark(week)">
		      <td><span php="mark(day)" class="holiday">&nbsp;</span></td>
		      <td id="dummy:d1">&nbsp;</td>
		      <td id="dummy:d2">1</td>
		      <td id="dummy:d3">2</td>
		      <td id="dummy:d4">3</td>
		      <td id="dummy:d5">4</td>
		      <td id="dummy:d6">5</td>
		    </tr>
		    <tr php="dummy(w1)">
		      <td><span class="holiday">6</span></td>
		      <td>7</td><td>8</td><td>9</td>
		      <td>10</td><td>11</td><td>12</td>
		    </tr>
		    <tr php="dummy(w2)">
		      <td><span class="holiday">13</span></td>
		      <td>14</td><td>15</td><td>16</td>
		      <td>17</td><td>18</td><td>19</td>
		    </tr>
		    <tr php="dummy(w3)">
		      <td><span class="holiday">20</span></td>
		      <td>21</td><td>22</td><td>23</td>
		      <td>24</td><td>25</td><td>26</td>
		    </tr>
		    <tr php="dummy(w4)">
		      <td><span class="holiday">27</span></td>
		      <td>28</td><td>29</td><td>30</td>
		      <td>31</td><td>&nbsp;</td><td>&nbsp;</td>
		    </tr>
		  </tbody>
		</table>
		&nbsp;

END;


		$plogic = <<<END
		:elem(week)
		
		  :set(day = '&nbsp;')
		  :set(wday = 1)
		  :while(wday < first_weekday)
		    :if(wday == 1)
		      @stag
		    :end
		    @cont
		    :set(wday += 1)
		  :end
		
		  :set(day = 0)
		  :set(wday -= 1)
		  :while(day < num_days)
		    :set(day += 1)
		    :set(wday = wday % 7 + 1)
		    :if(wday == 1)
		      @stag
		    :end
		    @cont
		    :if(wday == 7)
		      @etag
		    :end
		  :end
		
		  :if(wday != 7)
		    :set(day = '&nbsp;')
		    :while(wday != 6)
		      :set(wday += 1)
		      @cont
		    :end
		    @etag
		  :end
		
		:end
		
		:elem(day)
		  :if(wday == 1)
		    @stag
		    :print(day)
		    @etag
		  :else
		    :print(day)
		  :end
		:end

END;

		$plogic_php = <<<END
		element week {
		
		    \$day = '&nbsp;';
		    \$wday = 1;
		    while (\$wday < \$first_weekday) {
		        if (\$wday == 1) {
		            @stag;
		        }
		        @cont;
		        \$wday += 1;
		    }
		
		    \$day = 0;
		    \$wday -= 1;
		    while (\$day < \$num_days) {
		        \$day += 1;
		        \$wday = \$wday % 7 + 1;
		        if (\$wday == 1) {
		            @stag;
		        }
		        @cont;
		        if (\$wday == 7) {
		            @etag;
		        }
		    }
		
		    if (\$wday != 7) {
		        \$day = '&nbsp;';
		        while (\$wday != 6) {
		            \$wday += 1;
		            @cont;
		        }
		        @etag;
		    }
		
		}
		
		element day {
		    if (\$wday == 1) {
			@stag
			echo \$day;
			@etag;
		    } else {
			echo \$day;
		    }
		}

END;


		$expected = <<<END
		<table cellpadding="2" summary="">
		  <caption>
		    <i><?php echo \$month; ?></i>&nbsp;<i><?php echo \$year; ?></i>
		  </caption>
		  <thead>
		    <tr bgcolor="#CCCCCC">
		      <th><span class="holiday">S</span></th>
		      <th>M</th><th>T</th><th>W</th><th>T</th><th>F</th><th>S</th>
		    </tr>
		  </thead>
		  <tbody>
		<?php \$day = "&nbsp;"; ?>
		<?php \$wday = 1; ?>
		<?php while (\$wday < \$first_weekday) { ?>
		  <?php if (\$wday == 1) { ?>
		    <tr>
		  <?php } ?>
		      <td><?php if (\$wday == 1) { ?>
		<span class="holiday"><?php echo \$day; ?></span><?php } else { ?>
		<?php echo \$day; ?><?php } ?>
		</td>
		  <?php \$wday += 1; ?>
		<?php } ?>
		<?php \$day = 0; ?>
		<?php \$wday -= 1; ?>
		<?php while (\$day < \$num_days) { ?>
		  <?php \$day += 1; ?>
		  <?php \$wday = \$wday % 7 + 1; ?>
		  <?php if (\$wday == 1) { ?>
		    <tr>
		  <?php } ?>
		      <td><?php if (\$wday == 1) { ?>
		<span class="holiday"><?php echo \$day; ?></span><?php } else { ?>
		<?php echo \$day; ?><?php } ?>
		</td>
		  <?php if (\$wday == 7) { ?>
		    </tr>
		  <?php } ?>
		<?php } ?>
		<?php if (\$wday != 7) { ?>
		  <?php \$day = "&nbsp;"; ?>
		  <?php while (\$wday != 6) { ?>
		    <?php \$wday += 1; ?>
		      <td><?php if (\$wday == 1) { ?>
		<span class="holiday"><?php echo \$day; ?></span><?php } else { ?>
		<?php echo \$day; ?><?php } ?>
		</td>
		  <?php } ?>
		    </tr>
		<?php } ?>
		  </tbody>
		</table>
		&nbsp;

END;
		$this->_test($pdata,     $plogic,     $expected);
		$this->_test($pdata,     $plogic_php, $expected);
		$this->_test($pdata_php, $plogic,     $expected);
		$this->_test($pdata_php, $plogic_php, $expected);
	}


}


###
### execute test
###
//if ($argv[0] == 'KwartzCompilerTest.php') {
	$suite = new PHPUnit_TestSuite('KwartzCompilerTest');
	$result = PHPUnit::run($suite);
	//echo $result->toHTML();
	echo $result->toString();
//}
?>