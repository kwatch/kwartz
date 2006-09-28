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


class KwartzRulesetTest_ extends PHPUnit2_Framework_TestCase {

    var $name;
    var $title;
    var $desc;
    var $pdata;
    var $plogic;
    var $expected;
    var $excpetion;
    var $message;
    var $lang;

    function _test() {
        $pdata = $this->pdata;
        $plogic = $this->plogic;
        $expected = $this->expected;
        $Lang = ucfirst($this->lang);
        $handler_klass = "Kwartz{$Lang}Handler";
        $translator_klass = "Kwartz{$Lang}Translator";
        $parser = new KwartzCssStyleParser();
        $rulesets = $parser->parse($plogic);
        $handler = new $handler_klass($rulesets);
        $converter = new KwartzTextConverter($handler);
        $stmt_list = $converter->convert($pdata);
        $translator = new $translator_klass();
        $actual = $translator->translate($stmt_list);
        kwartz_assert_text_equals($expected, $actual, $this->name);
    }

}


$testdata = kwartz_load_testdata(__FILE__);
$code = kwartz_build_testmethods_with_each_lang($testdata, 'KwartzRulesetTest');
//echo '<'."?php \n", $code, '?'.'>';
eval($code);


?>