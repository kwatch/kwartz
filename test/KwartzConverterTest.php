<?php

/// $Rev$
/// $Release$
/// $Copyright$


// you need to install PHPUnit2 by 'sudo pear install --alldeps PHPUnit2'
// see http://www.phpunit.de/pocket_guide/2.3/en/installation.html

require_once 'KwartzTest.inc';

require_once 'Kwartz/Parser.php';
require_once 'Kwartz/Converter.php';
require_once 'Kwartz/Translator.php';
require_once 'Kwartz/Binding/Php.php';
require_once 'Kwartz/Binding/Eruby.php';
require_once 'Kwartz/Binding/Jstl.php';
require_once 'Kwartz/Binding/Eperl.php';


class KwartzConverterTest_ extends PHPUnit2_Framework_TestCase {

    var $name;
    var $title;
    var $properties;
    var $desc;
    var $pdata;
    var $plogic;
    var $expected;
    var $exception;
    var $errormsg;

    function _test() {
        $name     = $this->name;
        $testname = getenv('TEST');
        if ($testname && $testname != $name) return;
        $pdata    = $this->pdata;
        $plogic   = $this->plogic;
        $expected = $this->expected;
        $exception = $this->exception;
        $errormsg = $this->errormsg;
        $properties = array();
        if ($this->properties) {
            foreach ($this->properties as $key => $val) {
                if ($key[0] == ":") $key = substr($key, 1);
                $properties[$key] = $val;
            }
        } else {
            $properties = array();
        }
        //
        $Lang = ucfirst($this->lang);
        $handler_klass = "Kwartz{$Lang}Handler";
        $parser = new KwartzCssStyleParser();
        $rulesets = $parser->parse($plogic);
        $handler = new $handler_klass($rulesets, $properties);
        $converter = new KwartzTextConverter($handler, $properties);
        //
        if ($exception) {
            try {
                $stmt_list = $converter->convert($pdata);
                $this->fail("'$excepion' is expected but not thrown.");
            }
            catch (Exception $ex) {
                $this->assertType($exception, $ex);
                $this->assertEquals($errormsg, $ex->__toString());
            }
        } else {
            $stmt_list = $converter->convert($pdata);
            $buf = array();
            foreach ($stmt_list as $stmt) {
                $buf[] = $stmt->_inspect();
            }
            $actual = join($buf);
            kwartz_assert_text_equals($expected, $actual, $this->name);
        }
    }

}


$testdata = kwartz_load_testdata(__FILE__);
$code = kwartz_build_testmethods_with_each_lang($testdata, 'KwartzConverterTest');
//echo '<'."?php \n", $code, '?'.'>';
eval($code);


?>