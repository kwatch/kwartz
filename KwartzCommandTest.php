<?php

###
### KwartzCommandTest.php
###

require_once('PHPUnit.php');
require_once('kwartz.php');

class KwartzCommandTest extends PHPUnit_TestCase {

	function __construct($name) {
		$this->PHPUnit_TestCase($name);
	}

	
	## ----------------------------------------
	
	const pdata = 
'<html>
 <body>
  <table>
   <tbody kd:php="mark(user_list)">
    <tr class="odd" kd:php="attr(\'class\'=>$klass)">
     <td kd:php="value($name)">Foo</td>
     <td><a href="foo@mail.com" kd:php="attr(\'href\'=>$mail);value($mail)">foo@mail.com</a></td>
    </tr>
    <tr class="even" kd:php="dummy">
     <td>Bar</td>
     <td><a href="bar@mail.org">bar@mail.org</a></td>
    </tr>
   </tbody>
  </table>
 </body>
</html>
';

	const plogic = 
'element user_list {
  $i = 0;
  @stag;
  foreach ($user_list as $user) {
    $i += 1;
    $klass = $i % 2 == 0 ? "even" : "odd";
    $name = $user->name;
    $mail = $user->mail;
    @cont;
  }
  @etag;
}
';

	const output_php = 
'<html>
 <body>
  <table>
<?php $i = 0; ?>
   <tbody>
<?php foreach ($user_list as $user) { ?>
   <?php $i += 1; ?>
   <?php $klass = $i % 2 == 0 ? "even" : "odd"; ?>
   <?php $name = $user->name; ?>
   <?php $mail = $user->mail; ?>
    <tr class="<?php echo $klass; ?>">
     <td><?php echo $name; ?></td>
     <td><a href="<?php echo $mail; ?>"><?php echo $mail; ?></a></td>
    </tr>
<?php } ?>
   </tbody>
  </table>
 </body>
</html>
';

	const output_php_escaped =
'<html>
 <body>
  <table>
<?php $i = 0; ?>
   <tbody>
<?php foreach ($user_list as $user) { ?>
   <?php $i += 1; ?>
   <?php $klass = $i % 2 == 0 ? "even" : "odd"; ?>
   <?php $name = $user->name; ?>
   <?php $mail = $user->mail; ?>
    <tr class="<?php echo htmlspecialchars($klass); ?>">
     <td><?php echo htmlspecialchars($name); ?></td>
     <td><a href="<?php echo htmlspecialchars($mail); ?>"><?php echo htmlspecialchars($mail); ?></a></td>
    </tr>
<?php } ?>
   </tbody>
  </table>
 </body>
</html>
';

	const output_eruby =
'<html>
 <body>
  <table>
<% i = 0 %>
   <tbody>
<% for user in user_list do %>
  <% i += 1 %>
  <% klass = i % 2 == 0 ? "even" : "odd" %>
  <% name = user.name %>
  <% mail = user.mail %>
    <tr class="<%= klass %>">
     <td><%= name %></td>
     <td><a href="<%= mail %>"><%= mail %></a></td>
    </tr>
<% end %>
   </tbody>
  </table>
 </body>
</html>
';

	const output_eruby_escaped =
'<html>
 <body>
  <table>
<% i = 0 %>
   <tbody>
<% for user in user_list do %>
  <% i += 1 %>
  <% klass = i % 2 == 0 ? "even" : "odd" %>
  <% name = user.name %>
  <% mail = user.mail %>
    <tr class="<%= CGI.escapeHTML((klass).to_s) %>">
     <td><%= CGI.escapeHTML((name).to_s) %></td>
     <td><a href="<%= CGI.escapeHTML((mail).to_s) %>"><%= CGI.escapeHTML((mail).to_s) %></a></td>
    </tr>
<% end %>
   </tbody>
  </table>
 </body>
</html>
';

	const output_jsp =
'<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core" %>
<html>
 <body>
  <table>
<c:set var="i" value="0"/>
   <tbody>
<c:forEach var="user" items="${user_list}">
  <c:set var="i" value="${i + 1}"/>
  <c:choose>
    <c:when test="${i % 2 == 0}">
      <c:set var="klass" value="even"/>
    </c:when>
    <c:otherwise>
      <c:set var="klass" value="odd"/>
    </c:otherwise>
  </c:choose>
  <c:set var="name" value="${user.name}"/>
  <c:set var="mail" value="${user.mail}"/>
    <tr class="<c:out value="${klass}" escapeXml="false"/>">
     <td><c:out value="${name}" escapeXml="false"/></td>
     <td><a href="<c:out value="${mail}" escapeXml="false"/>"><c:out value="${mail}" escapeXml="false"/></a></td>
    </tr>
</c:forEach>
   </tbody>
  </table>
 </body>
</html>
';

	const output_jsp_escaped =
'<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core" %>
<html>
 <body>
  <table>
<c:set var="i" value="0"/>
   <tbody>
<c:forEach var="user" items="${user_list}">
  <c:set var="i" value="${i + 1}"/>
  <c:choose>
    <c:when test="${i % 2 == 0}">
      <c:set var="klass" value="even"/>
    </c:when>
    <c:otherwise>
      <c:set var="klass" value="odd"/>
    </c:otherwise>
  </c:choose>
  <c:set var="name" value="${user.name}"/>
  <c:set var="mail" value="${user.mail}"/>
    <tr class="<c:out value="${klass}"/>">
     <td><c:out value="${name}"/></td>
     <td><a href="<c:out value="${mail}"/>"><c:out value="${mail}"/></a></td>
    </tr>
</c:forEach>
   </tbody>
  </table>
 </body>
</html>
';

	var $pdata  = '.test.pdata';
	var $plogic = '.test.plogic';

	var $contents  = array(
		'.test.pdata'  => KwartzCommandTest::pdata,
		'.test.plogic' => KwartzCommandTest::plogic,
	);

	function _fcreate($filename) {
		$f = fopen($filename, "w");
		fwrite($f, $this->contents[$filename]);
		fclose($f);
	}
	function _fremove($filename) {
		unlink($filename);
	}


	## ----------------------------------------

	function test_parse_args() {
		$cmdstr = "/usr/local/bin/kwartz.php -hvaconvert -si6 file1 file2";
		$args = split(' ', $cmdstr);
		$command = new KwartzCommand($args);
		//echo var_dump($command);
		$command->parse_args();
		//echo var_dump($command);
		$this->assertEquals('kwartz.php', $command->_command_name());
		$args = $command->_args();
		$this->assertEquals('file1', $args[0]);
		$this->assertEquals('file2', $args[1]);
		$this->assertEquals(TRUE, $command->option('h'));
		$this->assertEquals(TRUE, $command->option('v'));
		$this->assertEquals('convert', $command->option('a'));
		$this->assertEquals(TRUE, $command->option('s'));
		$this->assertEquals(6, $command->option('i'));
	}
	
	# ----------------------------------------
	
	function _test_compile($command_str, $expected) {
		$this->_fcreate($this->pdata);
		$this->_fcreate($this->plogic);
		$args = split(' ', $command_str);
		$command = new KwartzCommand($args);
		$output = $command->main();
		//echo $output;
		$this->_fremove($this->pdata);
		$this->_fremove($this->plogic);
		$this->assertEquals($expected, $output);
		//echo $expected;
	}

	function test_compile1() {	# without plogic file
		$command_str = "/usr/local/bin/kwartz.php {$this->pdata}";
		$expected = 
		'<html>
		 <body>
		  <table>
		   <tbody>
		    <tr class="<?php echo $klass; ?>">
		     <td><?php echo $name; ?></td>
		     <td><a href="<?php echo $mail; ?>"><?php echo $mail; ?></a></td>
		    </tr>
		   </tbody>
		  </table>
		 </body>
		</html>
		';
		$expected = preg_replace('/^\t\t/m', '', $expected);
		$this->_test_compile($command_str, $expected);
	}

	function test_compile2() {	# -p file.plogic
		## php
		$command_str = "/usr/local/bin/kwartz.php -p {$this->plogic} {$this->pdata}";
		$expected = KwartzCommandTest::output_php;
		$expected = preg_replace('/^\s*<\?php/m', '<?php', $expected);
		$this->_test_compile($command_str, $expected);

		## eruby
		$command_str = "/usr/local/bin/kwartz.php -l eruby -p {$this->plogic} {$this->pdata}";
		$expected = KwartzCommandTest::output_eruby;
		$expected = preg_replace('/^\s*<%/m', '<%', $expected);
		$this->_test_compile($command_str, $expected);

		## jsp
		$command_str = "/usr/local/bin/kwartz.php -ljsp --escape=false -p {$this->plogic} {$this->pdata}";
		$expected = KwartzCommandTest::output_jsp;
		$expected = preg_replace('/^\s*<(\/?)c:/m', '<\1c:', $expected);
		$this->_test_compile($command_str, $expected);
	}
	
	function test_compile3() {	# -s, -e, --escape=true
		## php
		$command_str = "/usr/local/bin/kwartz.php -e -p {$this->plogic} {$this->pdata}";
		$expected = KwartzCommandTest::output_php_escaped;
		$expected = preg_replace('/^\s*<\?php/m', '<?php', $expected);
		$this->_test_compile($command_str, $expected);

		## eruby
		$command_str = "/usr/local/bin/kwartz.php -sleruby -p {$this->plogic} {$this->pdata}";
		$expected = KwartzCommandTest::output_eruby_escaped;
		$expected = preg_replace('/^\s*<%/m', '<%', $expected);
		$this->_test_compile($command_str, $expected);

		## jsp
		$command_str = "/usr/local/bin/kwartz.php -ljsp --escape=true -p {$this->plogic} {$this->pdata}";
		$expected = KwartzCommandTest::output_jsp_escaped;
		$expected = preg_replace('/^\s*<(\/?)c:/m', '<\1c:', $expected);
		$this->_test_compile($command_str, $expected);
	}
	
	function test_compile4() {	# -i
		## php
		$command_str = "/usr/local/bin/kwartz.php -ei3 -p {$this->plogic} {$this->pdata}";
		$expected = KwartzCommandTest::output_php_escaped;
		//$expected = preg_replace('/^\s*<\?php/m', '<?php', $expected);
		$this->_test_compile($command_str, $expected);

		## eruby
		$command_str = "/usr/local/bin/kwartz.php -l eruby -i -p {$this->plogic} {$this->pdata}";
		$expected = KwartzCommandTest::output_eruby;
		//$expected = preg_replace('/^\s*<%/m', '<%', $expected);
		$this->_test_compile($command_str, $expected);
		
		## jsp
		$command_str = "/usr/local/bin/kwartz.php -ljsp --escape=true -i2 -p {$this->plogic} {$this->pdata}";
		$expected = KwartzCommandTest::output_jsp_escaped;
		//$expected = preg_replace('/^\s*<(\/?)c:/m', '<\1c:', $expected);
		$this->_test_compile($command_str, $expected);
	}
}


###
### execute test
###
//if ($argv[0] == 'KwartzScannerTest.php') {
	$suite = new PHPUnit_TestSuite('KwartzCommandTest');
	$result = PHPUnit::run($suite);
	//echo $result->toHTML();
	echo $result->toString();
//}
?>
