<?php

/// $Rev$
/// $Release$
/// $Copyright$


// you need to install PHPUnit2 by 'sudo pear install --alldeps PHPUnit2'
// see http://www.phpunit.de/pocket_guide/2.3/en/installation.html

require_once 'KwartzTest.inc';

require_once 'Kwartz/KwartzParser.php';
require_once 'Kwartz/KwartzConverter.php';
require_once 'Kwartz/KwartzTranslator.php';
require_once 'Kwartz/Binding/Php.php';


class KwartzRulesetTest_ extends PHPUnit2_Framework_TestCase {

    var $name;
    var $title;
    var $desc;
    var $pdata;
    var $plogic;
    var $expected;
    var $excpetion;
    var $message;

    function _test() {
        $pattern = '/\{\{\*|\*\}\}/';
        $pdata    = preg_replace($pattern, '', $this->pdata);
        $plogic   = preg_replace($pattern, '', $this->plogic);
        $expected = preg_replace($pattern, '', $this->expected);

        $parser = new KwartzCssStyleParser();
        $rulesets = $parser->parse($plogic);
        $handler = new KwartzPhpHandler($rulesets);
        $converter = new KwartzTextConverter($handler);
        $stmt_list = $converter->convert($pdata);
        $translator = new KwartzPhpTranslator();
        $actual = $translator->translate($stmt_list);

        kwartz_assert_text_equals($expected, $actual, $this->name);
    }

}


$testdata = kwartz_load_testdata(__FILE__);
$testdata = kwartz_select_testdata($testdata, 'php');

//var_export($testdata);  //exit(0);

kwartz_define_testmethods($testdata, 'KwartzRulesetTest');


?>