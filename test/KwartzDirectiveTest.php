<?php

/// $Rev$
/// $Release$
/// $Copyright$


// you need to install PHPUnit2 by 'sudo pear install --alldeps PHPUnit2'
// see http://www.phpunit.de/pocket_guide/2.3/en/installation.html

require_once 'KwartzTest.inc';

//require_once 'Kwartz/KwartzException.php';
//require_once 'Kwartz/KwartzNode.php';
//require_once 'Kwartz/KwartzUtility.php';
require_once 'Kwartz/KwartzConfig.php';
require_once 'Kwartz/KwartzConverter.php';
require_once 'Kwartz/KwartzTranslator.php';
require_once 'Kwartz/Binding/Php.php';


class KwartzDirectiveTest_ extends PHPUnit2_Framework_TestCase {

    var $name;
    var $subject;
    var $desc;
    var $pdata;
    var $expected;
    var $excpetion;
    var $message;

    function _test() {
        $pattern  = '/\{\{\*|\*\}\}/';
        $pdata    = preg_replace($pattern, '', $this->pdata);
        $expected = preg_replace($pattern, '', $this->expected);
        $rulesets = array();
        $handler   = new KwartzPhpHandler($rulesets);
        $converter = new KwartzTextConverter($handler);
        $stmt_list = $converter->convert($pdata);
        //echo "*** debug: stmt_list="; var_export($stmt_list); echo "\n";
        $translator = new KwartzPhpTranslator();
        $actual = $translator->translate($stmt_list);
        kwartz_assert_text_equals($expected, $actual, $this->name);
    }

}


$testdata = kwartz_load_testdata(__FILE__);
$testdata = kwartz_select_testdata($testdata, 'php');
//var_export($testdata);  exit(0);
kwartz_define_testmethods($testdata, 'KwartzDirectiveTest');


?>