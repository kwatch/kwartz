<?php

/// $Rev$
/// $Release$
/// $Copyright$


// you need to install PHPUnit2 by 'sudo pear install --alldeps PHPUnit2'
// see http://www.phpunit.de/pocket_guide/2.3/en/installation.html

require_once 'KwartzTest.inc';

require_once 'Kwartz/KwartzParser.php';


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
        try {
            if (preg_match('/scanner/', $this->name)) {
                $this->_test_scanner($parser);
            } else {
                $this->_test_parser($parser);
            }
            if ($this->teardown) eval($this->teardown);
        } catch (Exception $ex) {
            if ($this->teardown) eval($this->teardown);
            throw $ex;
        }
    }

    function _test_scanner($parser) {
        $parser->_reset($this->plogic);
        $sb = array();
        while (($ret = $parser->scan()) !== null) {
            $sb[] = "{$parser->linenum}:{$parser->column}:";
            $value = kwartz_inspect_str($parser->value);
            $sb[] = " token={$parser->token}, value={$value}\n";
            if ($ret == 'error' || $ret == ':error') break;
        }
        $actual = join($sb);
        kwartz_assert_text_equals($this->expected, $actual, $this->name);
    }

    function _test_parser($parser) {
        $ruleset_list = $parser->parse($this->plogic);
        //var_export($ruleset_list);
        $sb = array();
        foreach ($ruleset_list as $ruleset) {
            $sb[] = $ruleset->_inspect();
        }
        $actual = join($sb);
        kwartz_assert_text_equals($this->expected, $actual, $this->name);
    }

}


$data_list = kwartz_load_testdata(__FILE__);
$list = array();
foreach ($data_list as $data) {
    if ($data['style'] != 'css')
        continue;
    foreach ($data as $key => $val) {
        if ($key[strlen($key)-1] == '*') {
            unset($data[$key]);
            $key = substr($key, 0, strlen($key)-1);
            $val = $val['php'];
            $data[$key] = $val;
        }
    }
    $list[] = $data;
}
$data_list = $list;

//var_export($data_list);  //exit(0);

$sb = array();
$sb[] = "class KwartzParserTest extends KwartzParserTest_ {\n";
foreach ($data_list as $data) {
    $sb[] =     "  function test_{$data['name']}(){\n";
    foreach ($data as $key=>$val) {
        $sb[] = "    \$this->{$key} = " . var_export($val, true) . ";\n";
    }
    $sb[] =     "    \$this->_test();\n";
    $sb[] =     "  }\n";
}
$sb[] = "}\n";
//echo "---\n", join($sb), "---\n";
eval(join($sb));


?>