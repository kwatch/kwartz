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


	function _test($pdata, $plogic, $expected, $lang, $flag_test=TRUE) {
		//if (! $flag_test) { return; }
		$pdata    = preg_replace('/^\t\t/m', '', $pdata);
		$pdata    = preg_replace('/^\n/',    '', $pdata);
		$plogic   = preg_replace('/^\t\t/m', '', $plogic);
		$plogic   = preg_replace('/^\n/',    '', $plogic);
		$expected = preg_replace('/^\t\t/m', '', $expected);
		$expected = preg_replace('/^\n/',    '', $expected);
		$compiler = new KwartzCompiler($pdata, $plogic, $lang);
		$code = $compiler->compile();
		$actual = $code;
		if ($flag_test) {
			$this->assertEquals($expected, $actual);
		} else {
			#echo "\n------\n";
			#echo kwartz_inspect_str($expected);
			#echo "\n------\n";
			#echo kwartz_inspect_str($actual);
		}
		return $compiler;
	}

	
	
	const pdata_compile1 = '
		<html>
		 <body>
		  <table>
		   <tr class="odd" id="mark:user" kd="attr:class:klass">
		    <td id="value:user[\'name\']">foo</td>
		    <td id="value:user[\'mail\']">foo@mail.com</td>
		   </tr>
		   <tr class="even" id="dummy:d1">
		    <td>bar</td>
		    <td>bar@mail.com</td>
		   </tr>
		  </table>
		 </body>
		</html>
		';

	const pdata_compile1_php = '
		<html>
		 <body>
		  <table>
		   <tr class="odd" php="mark(user);attr(\'class\'=>$klass)">
		    <td php="echo($user[\'name\'])">foo</td>
		    <td php="echo($user[\'mail\'])">foo@mail.com</td>
		   </tr>
		   <tr class="even" php="dummy(d1)">
		    <td>bar</td>
		    <td>bar@mail.com</td>
		   </tr>
		  </table>
		 </body>
		</html>
		';

	const plogic_compile1 = '
		:elem(user)
		  :set(i = 0)
		  :foreach(user = user_list)
		    :set(i += 1)
		    :set(klass = i%2==0 ? \'even\' : \'odd\')
		    @stag
		    @cont
		    @etag
		  :end
		:end
	';

	const plogic_compile1_php = '
		element user {
		  $i = 0;
		  foreach ($user_list as $user) {
		    $i += 1;
		    $klass = $i % 2 == 0 ? \'even\' : \'odd\';
		    @stag;
		    @cont;
		    @etag;
		  }
		}
		';
	
	const expected_compile1_php = '
		<html>
		 <body>
		  <table>
		<?php $i = 0; ?>
		<?php foreach ($user_list as $user) { ?>
		  <?php $i += 1; ?>
		  <?php $klass = $i % 2 == 0 ? "even" : "odd"; ?>
		   <tr class="<?php echo $klass; ?>">
		    <td><?php echo $user["name"]; ?></td>
		    <td><?php echo $user["mail"]; ?></td>
		   </tr>
		<?php } ?>
		  </table>
		 </body>
		</html>
		';

	const expected_compile1_eruby = '
		<html>
		 <body>
		  <table>
		<% i = 0 %>
		<% for user in user_list do %>
		  <% i += 1 %>
		  <% klass = i % 2 == 0 ? "even" : "odd" %>
		   <tr class="<%= klass %>">
		    <td><%= user["name"] %></td>
		    <td><%= user["mail"] %></td>
		   </tr>
		<% end %>
		  </table>
		 </body>
		</html>
		';

	const expected_compile1_jsp = '
		<html>
		 <body>
		  <table>
		<c:set var="i" value="0"/>
		<c:forEach var="user" items="${user_list}">
		  <c:set var="i" value="${i + 1}"/>
		  <c:choose><c:when test="${i % 2 == 0}">
		    <c:set var="klass" value="even"/>
		  </c:when><c:otherwise>
		    <c:set var="klass" value="odd"/>
		  </c:otherwise></c:choose>
		   <tr class="<c:out value="${klass}" escapeXml="false"/>">
		    <td><c:out value="${user[\'name\']}" escapeXml="false"/></td>
		    <td><c:out value="${user[\'mail\']}" escapeXml="false"/></td>
		   </tr>
		</c:forEach>
		  </table>
		 </body>
		</html>
		';


	function test_compile1_php() {
		$pdata      = KwartzCompilerTest::pdata_compile1;
		$pdata_php  = KwartzCompilerTest::pdata_compile1_php;
		$plogic     = KwartzCompilerTest::plogic_compile1;
		$plogic_php = KwartzCompilerTest::plogic_compile1_php;
		$expected_php   = KwartzCompilerTest::expected_compile1_php;

		$this->_test($pdata,     $plogic,     $expected_php, 'php');
		$this->_test($pdata,     $plogic_php, $expected_php, 'php');
		$this->_test($pdata_php, $plogic,     $expected_php, 'php');
		$this->_test($pdata_php, $plogic_php, $expected_php, 'php');
	}


	function test_compile1_eruby() {
		$pdata      = KwartzCompilerTest::pdata_compile1;
		$pdata_php  = KwartzCompilerTest::pdata_compile1_php;
		$plogic     = KwartzCompilerTest::plogic_compile1;
		$plogic_php = KwartzCompilerTest::plogic_compile1_php;
		$expected_eruby   = KwartzCompilerTest::expected_compile1_eruby;

		$this->_test($pdata,     $plogic,     $expected_eruby, 'eruby');
		$this->_test($pdata,     $plogic_php, $expected_eruby, 'eruby');
		$this->_test($pdata_php, $plogic,     $expected_eruby, 'eruby');
		$this->_test($pdata_php, $plogic_php, $expected_eruby, 'eruby');
	}

	function test_compile1_jsp() {
		$pdata          = KwartzCompilerTest::pdata_compile1;
		$pdata_php      = KwartzCompilerTest::pdata_compile1_php;
		$plogic         = KwartzCompilerTest::plogic_compile1;
		$plogic_php     = KwartzCompilerTest::plogic_compile1_php;
		$expected_jsp   = KwartzCompilerTest::expected_compile1_jsp;

		$this->_test($pdata,     $plogic,     $expected_jsp, 'jsp');
		$this->_test($pdata,     $plogic_php, $expected_jsp, 'jsp');
		$this->_test($pdata_php, $plogic,     $expected_jsp, 'jsp');
		$this->_test($pdata_php, $plogic_php, $expected_jsp, 'jsp');
	}



	## --------------------


	const pdata_compile2 = '
		<a href="#{url}#" id="mark:link">next page</a>
		';

	const pdata_compile2_php = '
		<a href="@{$url}@" php="mark(link)">next page</a>
		';

	const plogic_compile2 = '
		:elem(link)
		  :if (url != null)
		    @stag
		    @cont
		    @etag
		  :else
		    @cont
		  :end
		:end
		';

	const plogic_compile2_php = '
		element link {
		  if ($url != NULL) {
		    @stag;
		    @cont;
		    @etag;
		  } else {
		    @cont;
		  }
		}
		';

	const expected_compile2_php = '
		<?php if ($url != NULL) { ?>
		<a href="<?php echo $url; ?>">next page</a>
		<?php } else { ?>
		next page<?php } ?>
		';

	const expected_compile2_eruby = '
		<% if url != nil then %>
		<a href="<%= url %>">next page</a>
		<% else %>
		next page<% end %>
		';

	const expected_compile2_jsp = '
		<c:choose><c:when test="${url != null}">
		<a href="<c:out value="${url}" escapeXml="false"/>">next page</a>
		</c:when><c:otherwise>
		next page</c:otherwise></c:choose>
		';

	function test_compile2_php() {
		$pdata      = KwartzCompilerTest::pdata_compile2;
		$pdata_php  = KwartzCompilerTest::pdata_compile2_php;
		$plogic     = KwartzCompilerTest::plogic_compile2;
		$plogic_php = KwartzCompilerTest::plogic_compile2_php;
		$expected_php = KwartzCompilerTest::expected_compile2_php;

		$this->_test($pdata,     $plogic,     $expected_php, 'php');
		$this->_test($pdata,     $plogic_php, $expected_php, 'php');
		$this->_test($pdata_php, $plogic,     $expected_php, 'php');
		$this->_test($pdata_php, $plogic_php, $expected_php, 'php');
	}

	function test_compile2_eruby() {
		$pdata      = KwartzCompilerTest::pdata_compile2;
		$pdata_php  = KwartzCompilerTest::pdata_compile2_php;
		$plogic     = KwartzCompilerTest::plogic_compile2;
		$plogic_php = KwartzCompilerTest::plogic_compile2_php;
		$expected_eruby = KwartzCompilerTest::expected_compile2_eruby;

		$this->_test($pdata,     $plogic,     $expected_eruby, 'eruby');
		$this->_test($pdata,     $plogic_php, $expected_eruby, 'eruby');
		$this->_test($pdata_php, $plogic,     $expected_eruby, 'eruby');
		$this->_test($pdata_php, $plogic_php, $expected_eruby, 'eruby');
	}

	function test_compile2_jsp() {
		$pdata          = KwartzCompilerTest::pdata_compile2;
		$pdata_php      = KwartzCompilerTest::pdata_compile2_php;
		$plogic         = KwartzCompilerTest::plogic_compile2;
		$plogic_php     = KwartzCompilerTest::plogic_compile2_php;
		$expected_jsp   = KwartzCompilerTest::expected_compile2_jsp;

		$this->_test($pdata,     $plogic,     $expected_jsp, 'jsp');
		$this->_test($pdata,     $plogic_php, $expected_jsp, 'jsp');
		$this->_test($pdata_php, $plogic,     $expected_jsp, 'jsp');
		$this->_test($pdata_php, $plogic_php, $expected_jsp, 'jsp');
	}



	## --------------------

	const pdata_compile3 = '
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
		';

	const plogic_compile3 = '
		:elem(week)
		
		  :set(day = \'&nbsp;\')
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
		    :set(day = \'&nbsp;\')
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
		';

	const pdata_compile3_php = '
		<table cellpadding="2" summary="">
		  <caption>
		    <i php="echo($month)">Jan</i>&nbsp;<i php="echo($year)">20XX</i>
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
		';

	const plogic_compile3_php = '
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

	const expected_compile3_php = '
		<table cellpadding="2" summary="">
		  <caption>
		    <i><?php echo $month; ?></i>&nbsp;<i><?php echo $year; ?></i>
		  </caption>
		  <thead>
		    <tr bgcolor="#CCCCCC">
		      <th><span class="holiday">S</span></th>
		      <th>M</th><th>T</th><th>W</th><th>T</th><th>F</th><th>S</th>
		    </tr>
		  </thead>
		  <tbody>
		<?php $day = "&nbsp;"; ?>
		<?php $wday = 1; ?>
		<?php while ($wday < $first_weekday) { ?>
		  <?php if ($wday == 1) { ?>
		    <tr>
		  <?php } ?>
		      <td><?php if ($wday == 1) { ?>
		<span class="holiday"><?php echo $day; ?></span><?php } else { ?>
		<?php echo $day; ?><?php } ?>
		</td>
		  <?php $wday += 1; ?>
		<?php } ?>
		<?php $day = 0; ?>
		<?php $wday -= 1; ?>
		<?php while ($day < $num_days) { ?>
		  <?php $day += 1; ?>
		  <?php $wday = $wday % 7 + 1; ?>
		  <?php if ($wday == 1) { ?>
		    <tr>
		  <?php } ?>
		      <td><?php if ($wday == 1) { ?>
		<span class="holiday"><?php echo $day; ?></span><?php } else { ?>
		<?php echo $day; ?><?php } ?>
		</td>
		  <?php if ($wday == 7) { ?>
		    </tr>
		  <?php } ?>
		<?php } ?>
		<?php if ($wday != 7) { ?>
		  <?php $day = "&nbsp;"; ?>
		  <?php while ($wday != 6) { ?>
		    <?php $wday += 1; ?>
		      <td><?php if ($wday == 1) { ?>
		<span class="holiday"><?php echo $day; ?></span><?php } else { ?>
		<?php echo $day; ?><?php } ?>
		</td>
		  <?php } ?>
		    </tr>
		<?php } ?>
		  </tbody>
		</table>
		&nbsp;
		';

	const expected_compile3_eruby = '
		<table cellpadding="2" summary="">
		  <caption>
		    <i><%= month %></i>&nbsp;<i><%= year %></i>
		  </caption>
		  <thead>
		    <tr bgcolor="#CCCCCC">
		      <th><span class="holiday">S</span></th>
		      <th>M</th><th>T</th><th>W</th><th>T</th><th>F</th><th>S</th>
		    </tr>
		  </thead>
		  <tbody>
		<% day = "&nbsp;" %>
		<% wday = 1 %>
		<% while wday < first_weekday do %>
		  <% if wday == 1 then %>
		    <tr>
		  <% end %>
		      <td><% if wday == 1 then %>
		<span class="holiday"><%= day %></span><% else %>
		<%= day %><% end %>
		</td>
		  <% wday += 1 %>
		<% end %>
		<% day = 0 %>
		<% wday -= 1 %>
		<% while day < num_days do %>
		  <% day += 1 %>
		  <% wday = wday % 7 + 1 %>
		  <% if wday == 1 then %>
		    <tr>
		  <% end %>
		      <td><% if wday == 1 then %>
		<span class="holiday"><%= day %></span><% else %>
		<%= day %><% end %>
		</td>
		  <% if wday == 7 then %>
		    </tr>
		  <% end %>
		<% end %>
		<% if wday != 7 then %>
		  <% day = "&nbsp;" %>
		  <% while wday != 6 do %>
		    <% wday += 1 %>
		      <td><% if wday == 1 then %>
		<span class="holiday"><%= day %></span><% else %>
		<%= day %><% end %>
		</td>
		  <% end %>
		    </tr>
		<% end %>
		  </tbody>
		</table>
		&nbsp;
		';


	function test_compile3_php() {
		$pdata        = KwartzCompilerTest::pdata_compile3;
		$plogic       = KwartzCompilerTest::plogic_compile3;
		$pdata_php    = KwartzCompilerTest::pdata_compile3_php;
		$plogic_php   = KwartzCompilerTest::plogic_compile3_php;
		$expected_php = KwartzCompilerTest::expected_compile3_php;

		$this->_test($pdata,     $plogic,     $expected_php, 'php');
		$this->_test($pdata,     $plogic_php, $expected_php, 'php');
		$this->_test($pdata_php, $plogic,     $expected_php, 'php');
		$this->_test($pdata_php, $plogic_php, $expected_php, 'php');
	}

	function test_compile3_eruby() {
		$pdata          = KwartzCompilerTest::pdata_compile3;
		$plogic         = KwartzCompilerTest::plogic_compile3;
		$pdata_php      = KwartzCompilerTest::pdata_compile3_php;
		$plogic_php     = KwartzCompilerTest::plogic_compile3_php;
		$expected_eruby = KwartzCompilerTest::expected_compile3_eruby;

		$this->_test($pdata,     $plogic,     $expected_eruby, 'eruby');
		$this->_test($pdata,     $plogic_php, $expected_eruby, 'eruby');
		$this->_test($pdata_php, $plogic,     $expected_eruby, 'eruby');
		$this->_test($pdata_php, $plogic_php, $expected_eruby, 'eruby');
	}

	#function test_compile3_jsp() {
	#	# translation error
	#}



	## --------------------
	## newline char
	## --------------------
	function test_newline1_php() {
		$pdata    = preg_replace('/\n/', "\r\n", KwartzCompilerTest::pdata_compile1);
		$plogic   = preg_replace('/\n/', "\r\n", KwartzCompilerTest::plogic_compile1);
		$expected = preg_replace('/\n/', "\r\n", KwartzCompilerTest::expected_compile1_php);
		$this->_test($pdata, $plogic, $expected, 'php');
	}
	function test_newline1_eruby() {
		$pdata    = preg_replace('/\n/', "\r\n", KwartzCompilerTest::pdata_compile1);
		$plogic   = preg_replace('/\n/', "\r\n", KwartzCompilerTest::plogic_compile1);
		$expected = preg_replace('/\n/', "\r\n", KwartzCompilerTest::expected_compile1_eruby);
		$this->_test($pdata, $plogic, $expected, 'eruby');
	}
	function test_newline1_jsp() {
		$pdata    = preg_replace('/\n/', "\r\n", KwartzCompilerTest::pdata_compile1);
		$plogic   = preg_replace('/\n/', "\r\n", KwartzCompilerTest::plogic_compile1);
		$expected = preg_replace('/\n/', "\r\n", KwartzCompilerTest::expected_compile1_jsp);
		$this->_test($pdata, $plogic, $expected, 'jsp');
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