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
require_once 'Kwartz/Binding/Eruby.php';
require_once 'Kwartz/Binding/Jstl.php';
require_once 'Kwartz/Binding/Eperl.php';


class KwartzDirectiveTest_ extends PHPUnit2_Framework_TestCase {

    var $name;
    var $subject;
    var $desc;
    var $pdata;
    var $expected;
    var $excpetion;
    var $message;

    function _test() {
        $pdata = $this->pdata;
        $expected = $this->expected;
        $Lang = ucfirst($this->lang);
        $handler_klass = "Kwartz{$Lang}Handler";
        $translator_klass = "Kwartz{$Lang}Translator";
        //$parser = new KwartzCssStyleParser();
        //$rulesets = $parser->parse($plogic);
        $properties = array('header'=>'');
        $rulesets = array();
        $handler = new $handler_klass($rulesets, $properties);
        $converter = new KwartzTextConverter($handler);
        $stmt_list = $converter->convert($pdata);
        //echo "*** debug: stmt_list="; var_export($stmt_list); echo "\n";
        $translator = new $translator_klass($properties);
        $actual = $translator->translate($stmt_list);
        kwartz_assert_text_equals($expected, $actual, $this->name);
    }

}


$testdata = kwartz_load_testdata(__FILE__);
$code = kwartz_build_testmethods_with_each_lang($testdata, 'KwartzDirectiveTest');
//echo '<'."?php \n", $code, '?'.'>';
eval($code);


?>