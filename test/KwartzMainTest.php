<?php

/// $Rev$
/// $Release$
/// $Copyright$


// you need to install PHPUnit2 by 'sudo pear install --alldeps PHPUnit2'
// see http://www.phpunit.de/pocket_guide/2.3/en/installation.html

require_once 'KwartzTest.inc';

require_once 'Kwartz/Main.php';

$filename = preg_replace('/\.php$/', '.yaml', __FILE__);
$str = file_get_contents($filename);
//$str = kwartz_untabify($str);
$ydoc = syck_load($str);
//var_export($ydoc); echo "\n";

define('PDATA',    $ydoc['pdata']);
define('PLOGIC',   $ydoc['plogic*']['php']);
define('EXPECTED', $ydoc['expected*']['php']);
define('YAML_DATA', $ydoc['yamldata']);
define('YAML_OUTPUT', $ydoc['yamloutput']);
define('PLOGIC_ERUBY',   $ydoc['plogic*']['eruby']);
define('EXPECTED_ERUBY', $ydoc['expected*']['eruby']);
define('IMPORT_PDATA',  $ydoc['import_pdata']);
define('IMPORT_PLOGIC', $ydoc['import_plogic*']['php']);
define('LAYOUT',   $ydoc['layout']);


class KwartzMainTest extends PHPUnit2_Framework_TestCase {


    var $name;
    var $desc;
    var $argv;
    var $pdata;
    var $plogic;
    var $expected;
    var $exception;
    var $message;
    var $yamldata;
    var $yamloutput;
    var $debug;
    var $layout;


    function _setup() {
        $name = $this->name;
        if (! $name) die("name is required.\n");
        //
        $argv = $this->argv;
        if (! $argv) die("argv is required.\n");
        if (is_string($argv)) {
            $argv = preg_split('/\s+/', $argv);
        }
        $this->argv = array_merge(array('kwartz-php'), $argv);
        //
        if ($this->pdata)    file_put_contents("{$name}.pdata",  $this->pdata);
        if ($this->plogic)   file_put_contents("{$name}.plogic", $this->plogic);
        if ($this->yamldata) file_put_contents("{$name}.yaml",   $this->yamldata);
        if ($this->layout)   file_put_contents("layout.html", $this->layout);
    }


    function _teardown() {
        if ($this->debug) return;
        $name = $this->name;
        $filenames = array("{$name}.pdata", "{$name}.plogic", "{$name}.yaml",
                           "layout.html");
        foreach ($filenames as $filename) {
            if (file_exists($filename)) {
                unlink($filename);
            }
        }
    }


    function _test() {
        $this->_setup();
        try {
            $this->_do_test();
            $this->_teardown();
        } catch (Exception $ex) {
            $this->_teardown();
            throw $ex;
        }
    }


    function _do_test() {
        $main = new KwartzMain($this->argv);
        if ($this->exception) {
            try {
                $actual = $main->execute();
                $this->fail("exception {$this->exception} is expected but not throwed.");
            } catch (Exception $ex) {
                if (! ($ex instanceof $this->exception)) {
                    $this->fail("exception {$this->exception} is expected but got {$ex->__toString()}.");
                }
                $msg = $ex->__toString();
                kwartz_assert_text_equals($this->message, $msg, $this->name);
            }
        } else {
            $actual = $main->execute();
            kwartz_assert_text_equals($this->expected, $actual, $this->name);
        }
    }


    function test_pdata1() {
        $this->name = 'pdata1';
        $this->pdata = PDATA;
        $this->expected = preg_replace('/ id="mark:.*?"/', '', PDATA);
        $this->argv = "pdata1.pdata";
        $this->_test();
    }


/*
//    function test_pstyle1() { // -P
//        // OK
//        $this->name = 'pstyle1';
//        $this->pdata = PDATA;
//        $this->plogic = PLOGIC;
//        $this->argv = '-Pcss -p pstyle1 pstyle1.pdata';
//        $this->expected = EXPECTED;
//        $this->_test();
//        // NG
//        $this->argv = '-Phoge -p pstyle1 pstyle1.pdata';
//        $this->exception = 'KwartzCommandOptionError';
//        $this->message = "-P hoge: unknown style name (parser class not registered).";
//        $this->_test();
//    }
*/


    function test_lang1() { // -l
        // OK
        $this->name = 'lang1';
        $this->pdata = PDATA;
        $this->plogic = PLOGIC;
        $this->argv = '-l php -p lang1 lang1.pdata';
        $this->expected = EXPECTED;
        $this->_test();
        // NG
        $this->argv = '-l hoge -p lang1 lang1.pdata';
        $this->exception = 'KwartzCommandOptionException';
        $this->message = "-l hoge: unknown lang name.";
        $this->_test();
    }


/*
//    function test_requires1() { // -r
//        // OK
//        $this->name = 'requires1';
//        $this->pdata = PDATA;
//        $this->plogic = PLOGIC_ERUBY;
//        $this->argv = '-r xxx requires1.pdata';
//        $this->expected = preg_replace('/ id="mark:.*?"/', '', PDATA);
//        $this->_test();
//        // NG
//        $this->argv = '-rxxxx requires1.pdata';
//        $this->exception = 'LoadError';
//        $this->_test();
//    }
*/

    function test_plogics1() {  // -p
        // OK
        $this->name = 'plogics1';
        $this->pdata = PDATA;
        $this->plogic = PLOGIC;
        $this->expected = EXPECTED;
        $this->argv = "-p plogics1 plogics1.pdata";
        $this->_test();
        // NG (not found)
        $this->argv = "-p hogeratta plogics1.pdata";
        $this->exception = 'KwartzCommandOptionException';
        $this->message = "-p hogeratta[.plogic]: file not found.";
        $this->_test();
        // NG (syntax error)
        $this->plogic = preg_replace('/title;/', 'title', PLOGIC);
        $this->argv = '-p plogics1 plogics1.pdata';
        $this->exception = 'KwartzParseException';
        $this->message = "plogics1.plogic:3:1: 'value:': ';' is required.";
        $this->_test();
    }


    function test_escape1() { // -e, --escape
        // OK
        $this->name = 'escape1';
        $this->pdata = PDATA;
        $this->plogic = PLOGIC;
        $this->expected = preg_replace('/echo \$title;/',
                                       'echo htmlspecialchars($title);',
                                       EXPECTED);
        $this->argv = '-epescape1 escape1.pdata';
        $this->_test();
        // OK
        //$this->pdata = PDATA;
        //$this->plogic = PLOGIC_ERUBY;
        //$this->expected = preg_replace('/<%= @title %>/', '<%=h @title %>', EXPECTED_ERUBY);
        //$this->argv = '--escape -leruby -pescape1 escape1.pdata';
        //$this->_test();
    }


    function test_import1() { // -1
        // OK
        $this->name = 'import1';
        $this->pdata = PDATA;
        $this->plogic = preg_replace('/^\#doctitle.*?\}/s',
                                     "#doctitle{logic:{\n_element(sectitle);\n}\n}",
                                     PLOGIC);
        $this->expected = preg_replace('/^\s*<h1>.*?<\/h1>/m',
                                       '<'.'?php echo $sectitle; ?'.'>',
                                       EXPECTED);
        file_put_contents('import1a.pdata', IMPORT_PDATA);
        file_put_contents('import1a.plogic', IMPORT_PLOGIC);
        $this->argv = '-p import1,import1a -i import1a.pdata import1.pdata';
        $ex = null;
        try {
            $this->_test();
        } catch (Exception $ex) {
        }
        if (file_exists("import1a.pdata")) unlink("import1a.pdata");
        if (file_exists("import1a.plogic")) unlink("import1a.plogic");
        if ($ex) throw $ex;
        // NG
        $this->argv = '-p import1 -i hogehoge import1.pdata';
        $this->exception = 'KwartzCommandOptionException';
        $this->message = '-i hogehoge: file not found.';
        $this->_test();
    }


    function test_layout1() { // -L
        // OK
        $this->name = 'layout1';
        $this->pdata = PDATA;
        $this->plogic = PLOGIC;
        $this->layout = LAYOUT;
        preg_match('/^\s*<table.*?<\/table>/sm', EXPECTED, $m);
        $content_str = $m[0];
        $expected = preg_replace('/^(\s*)<title.*?<\/title>/m',
                                 '${1}<title><'.'?php echo $title; ?'.'></title>',
                                 LAYOUT);
        $expected = preg_replace('/^( *)<div .*?<\/div>/sm', $content_str, $expected);
        $expected = preg_replace('/^<'.'\?xml/', '<<'.'?php ?'.'>?xml', $expected);
        $this->expected = $expected;
        $this->argv = '-p layout1 -L layout.html layout1.pdata';
        $this->_test();
        // NG
        $this->argv = '-p layout1 -L hogehoge layout1.pdata';
        $this->exception = 'KwartzCommandOptionException';
        $this->message = '-L hogehoge: file not found.';
        $this->_test();
    }


    function test_extract1() { // -X
        // OK
        $this->name = 'extract1';
        $this->pdata = PDATA;
        $this->plogic = PLOGIC;
        $this->argv = '-X content -p extract1 extract1.pdata';
        preg_match('/^ *<table.*?<\/table>\n/sm', EXPECTED, $m);
        $this->expected = $m[0];
        $this->_test();
        // NG
        $this->exception = 'KwartzConvertionException';
        $this->message = "extract1.pdata:: element 'hogehoge' not found.";
        $this->argv = '-X hogehoge -p extract1 extract1.pdata';
        $this->_test();
    }


    function test_extract2() { // -x
        // OK
        $this->name = 'extract2';
        $this->pdata = PDATA;
        $this->plogic = PLOGIC;
        $this->argv = '-x content -p extract2 extract2.pdata';
        preg_match('/<table id=".*?">\n(.*)^ *<\/table>/sm', EXPECTED, $m);
        $this->expected = $m[1];
        $this->_test();
        // NG
        $this->exception = 'KwartzConvertionException';
        $this->message = "extract2.pdata:: element 'hogehoge' not found.";
        $this->argv = '-x hogehoge -p extract2 extract2.pdata';
        $this->_test();
    }


    function test_yamlfile1() { // -f
        // OK
        $this->name = 'yamlfile1';
        $this->pdata = PDATA;
        $this->plogic = PLOGIC;
        $this->argv = '-f yamlfile1.yaml -p yamlfile1 yamlfile1.pdata';
        $this->yamldata = preg_replace('/\t/', '  ', YAML_DATA);
        $this->expected = YAML_OUTPUT;
        $this->_test();
        // NG (not found)
        $this->argv = '-f hogehoge.yaml -p yamlfile1 yamlfile1.pdata';
        $this->exception = 'KwartzCommandOptionException';
        $this->message = '-f hogehoge.yaml: file not found.';
        $this->_test();
        // NG (not a mapping)
        $s  = "- title: kwartz test\n";
        $s .= "- list:\n";
        $s .= "    - aaa\n";
        $s .= "    - bbb\n";
        $s .= "    - ccc\n";
        $this->yamldata = $s;
        $this->argv = '-f yamlfile1.yaml -p yamlfile1 yamlfile1.pdata';
        $this->exception = 'KwartzCommandOptionException';
        $this->message = '-f yamlfile1.yaml: not a mapping.';
        $this->_test();
    }


    function test_untabify1() { // -t
        // OK
        $this->name = 'untabify1';
        $this->pdata = PDATA;
        $this->plogic = PLOGIC;
        $this->argv = '-tf untabify1.yaml -p untabify1 untabify1.pdata';
        $this->yamldata = YAML_DATA;
        $this->expected = YAML_OUTPUT;
        $this->_test();
        //// NG
        //$this->argv = '-f untabify1.yaml -p untabify1 untabify1.pdata';
        //$this->exception = '???';
        //$this->message = 'Error at [Line 5, Col -1]: syntax error';
        //$this->_test();
    }


/*

//  def test_intern1 # -S
//    # OK
//    @pdata = <<END
//<span title="value: @aaa[:bb1][:cc1][:dd1]">xxx</span>
//<span title="value: @aaa[:bb1][:cc1][:dd2][:bb2]">xxx</span>
//END
//    @yamldata = <<END
//aaa: &anchor1
//  bb1:
//    cc1:
//      dd1: foo
//      dd2: *anchor1
//  bb2: bar
//END
//    @expected = <<END
//<span>foo</span>
//<span>bar</span>
//END
//    @argv = %w[-tSf intern1.yaml intern1.pdata]
//    _test
//    # OK
//    @pdata = <<END
//<span title="value: @aaa['bb1']['cc1']['dd1']">xxx</span>
//<span title="value: @aaa['bb1']['cc1']['dd2']['bb2']">xxx</span>
//END
//    @argv = %w[-tf intern1.yaml intern1.pdata]
//    _test
//  end

*/


    function test_no_args() {
        $this->name = 'no_args';
        $this->exception = 'KwartzCommandOptionException';
        $tuples = array(
            'l' => 'lang name',
            //'k' => 'kanji code',
            //'r' => 'library name',
            'p' => 'file name',
            //'P' => 'parser style',
            'x' => 'element id',
            'X' => 'element id',
            'i' => 'file name',
            'L' => 'file name',
            'f' => 'yaml file',
            );
        foreach ($tuples as $opt => $arg) {
            $this->argv = "-{$opt}";
            $this->message = "-{$opt}: {$arg} required.";
            $this->_test();
        }
    }


    function test_no_filenames() {
        $this->name = 'no_filenames';
        $this->exception = 'KwartzCommandOptionException';
        $this->argv = '-p foo';
        $this->message = 'filename of presentation data is required.';
        $this->_test();
    }


}


?>