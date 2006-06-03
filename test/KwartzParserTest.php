<?php

/// $Rev$
/// $Release$
/// $Copyright$


// you need to install PHPUnit2 by 'sudo pear install --alldeps PHPUnit2'
// see http://www.phpunit.de/pocket_guide/2.3/en/installation.html

$testdir = dirname(__FILE__);
$basedir = dirname($testdir);

set_include_path(get_include_path() . PATH_SEPARATOR . $basedir);

if (! extension_loaded('syck')) {
    if (! dl('syck.so')) {   // or dl('/some/where/to/syck.so')
        die('cannot load syck extension.');
    }
}

require_once('PHPUnit2/Framework/TestCase.php');
require_once('Kwartz/KwartzParser.php');

error_reporting(E_ALL);


class KwartzParserTest_ extends PHPUnit2_Framework_TestCase {

    var $name;
    var $plogic;
    var $expected;
    var $excpetion;
    var $message;

    function _test() {
        $parser = new KwartzCssStyleParser();
        $ruleset_list = $parser->parse($this->plogic);
        //var_export($ruleset_list);
        $actual = "";
        foreach ($ruleset_list as $ruleset) {
            if ($actual) $actual .= "\n";
            $actual .= $ruleset->_inspect();
        }
        $tmpdir = 'tmp.d';
        if (! file_exists($tmpdir)) mkdir($tmpdir);
        file_put_contents("{$tmpdir}/{$this->name}.plogic",   $this->plogic);
        file_put_contents("{$tmpdir}/{$this->name}.expected", $this->expected);
        file_put_contents("{$tmpdir}/{$this->name}.actual",   $actual);
        $this->assertEquals($this->expected, $actual);
    }
}


$filename = preg_replace('/\.php$/', '.yaml', __FILE__);
$data_list = syck_load(kwartz_untabify(file_get_contents($filename)));

//var_export($data_list);  exit(0);

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


//
//    function test_parser1() {
//        $this->plogic = <<<END
//#item {
//  value:  \$item;
//}
//
//END;
//        $this->expected = <<<END
//name: item
//cont: \$item
//
//END;
//        $this->_test();
//    }
//
//}
//';
//



?>