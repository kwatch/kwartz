<?php

/// $Rev$
/// $Release$
/// $Copyright$


// you need to install PHPUnit2 by 'sudo pear install --alldeps PHPUnit2'
// see http://www.phpunit.de/pocket_guide/2.3/en/installation.html

require_once 'KwartzTest.inc';

require_once 'Kwartz/Parser.php';


class KwartzParserTest_ extends PHPUnit2_Framework_TestCase {

    var $name;
    var $plogic;
    var $expected;
    var $excpetion;
    var $message;
    var $setup;
    var $teardown;

    function _test() {
        if ($this->setup) eval($this->setup);
        $parser = new KwartzCssStyleParser();
        $pattern = '/\{\{\*|\*\}\}/';
        $plogic   = preg_replace($pattern, '', $this->plogic);
        $expected = preg_replace($pattern, '', $this->expected);
        try {
            if (preg_match('/scanner/', $this->name)) {
                $actual = $this->_do_scan($parser, $plogic);
            } else {
                $actual = $this->_do_parse($parser, $plogic);
            }
            kwartz_assert_text_equals($expected, $actual, $this->name);
            if ($this->teardown) eval($this->teardown);
        } catch (Exception $ex) {
            if ($this->teardown) eval($this->teardown);
            throw $ex;
        }
    }

    function _do_scan($parser, $plogic) {
        $parser->_reset($plogic);
        $sb = array();
        while (($ret = $parser->scan()) !== null) {
            $sb[] = "{$parser->linenum}:{$parser->column}:";
            $value = kwartz_inspect_str($parser->value);
            $sb[] = " token={$parser->token}, value={$value}\n";
            if ($ret == 'error' || $ret == ':error') break;
        }
        $actual = join($sb);
        return $actual;
    }

    function _do_parse($parser, $plogic) {
        $ruleset_list = $parser->parse($plogic);
        //var_export($ruleset_list);
        $sb = array();
        foreach ($ruleset_list as $ruleset) {
            $sb[] = $ruleset->_inspect();
        }
        $actual = join($sb);
        return $actual;
    }

}


$testdata = kwartz_load_testdata(__FILE__);
$testdata = kwartz_select_testdata($testdata, 'php');
$list = array();
foreach ($testdata as $data) {
    if ($data['style'] == 'css') {
        $list[] = $data;
    }
}
$testdata = $list;

//var_export($testdata);  //exit(0);

kwartz_define_testmethods($testdata, 'KwartzParserTest');


?>