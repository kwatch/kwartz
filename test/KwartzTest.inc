<?php
$testdir = dirname(__FILE__);
$basedir = dirname($testdir);
set_include_path(get_include_path() . PATH_SEPARATOR . $basedir);

if (! extension_loaded('syck')) {
    if (! dl('syck.so')) {   // or dl('/some/where/to/syck.so')
        die('cannot load syck extension.');
    }
}

require_once 'PHPUnit2/Framework/TestCase.php';


function kwartz_assert_text_equals($expected, $actual) {
    if ($expected != $actual) {
        //$tmpdir = php_get_tmpdir();
        $tmpdir = ".";
        $expected_filename = $tmpdir . "/.expected";
        $actual_filename   = $tmpdir . "/.actual";
        file_put_contents($expected_filename, $expected);
        file_put_contents($actual_filename,   $actual);
        ob_start();
        system("diff -u {$expected_filename} {$actual_filename}");
        $result = ob_get_clean();
        unlink($expected_filename);
        unlink($actual_filename);
        $preamble = "--- expected\n+++ actual\n";
        $result = preg_replace('/\A.*\n.*\n/', $preamble, $result);
        //$this->fail($result);
        PHPUnit2_Framework_Assert::fail($result);
    } else {
        PHPUnit2_Framework_Assert::assertEquals($expected, $actual);
    }
}


function kwartz_load_testdata($filename, $untabify=true) {
    $filename = preg_replace('/\.php$/', '.yaml', $filename);
    $str = file_get_contents($filename);
    if ($untabify) $str = kwartz_untabify($str);
    $testdata_list = syck_load($str);
    $table = array();   // hash
    foreach ($testdata_list as $testdata) {
        if (! array_key_exists('name', $testdata))
            die("*** {$filename}: key 'name' is not found.");
        $name = $testdata['name'];
        if (array_key_exists($name, $table))
            die("*** {$filename}: name '{$name}' is duplicated.");
        $table[$name] = $testdata;
    }
    return $testdata_list;
}


function kwartz_select_testdata($testdata, $lang) {
    $list = array();
    foreach ($testdata as $data) {
        foreach ($data as $key => $val) {
            if ($key[strlen($key)-1] == '*') {
                unset($data[$key]);
                $key = substr($key, 0, strlen($key)-1);
                $val = $val[$lang];
                $data[$key] = $val;
            }
        }
        $list[] = $data;
    }
    return $list;
}


function kwartz_build_testmethods($testdata, $classname, $parent_classname=null) {
    if (! $parent_classname)
        $parent_classname = $classname . '_';
    $sb = array();
    $sb[] = "class {$classname} extends {$parent_classname} {\n";
    foreach ($testdata as $data) {
        $sb[] =     "  function test_{$data['name']}(){\n";
        foreach ($data as $key=>$val) {
            $val = preg_replace('/\{\{\*|\*\}\}/', '', $val);
            $expr = var_export($val, true);
            $sb[] = "    \$this->{$key} = {$expr};\n";
        }
        $sb[] =     "    \$this->_test();\n";
        $sb[] =     "  }\n";
    }
    $sb[] = "}\n";
    return join($sb);
}


function kwartz_define_testmethods($testdata, $classname) {
    $code = kwartz_build_testmethods($testdata, $classname);
    eval($code);
}


function kwartz_build_testmethods_with_each_lang($testdata, $classname, $langs=null, $parent_classname=null) {
    if (! $langs)
        $langs = array('php', 'eruby', 'jstl', 'eperl');
    if (! $parent_classname)
        $parent_classname = $classname . '_';
    $sb = array();
    $sb[] = "class {$classname} extends {$parent_classname} {\n\n\n";
    foreach ($langs as $lang) {
        foreach ($testdata as $data) {
            $sb[] =     "  function test_{$data['name']}_{$lang}(){\n";
            $sb[] =     "    \$this->lang = '{$lang}';\n";
            foreach ($data as $key=>$val) {
                if ($key[strlen($key)-1] == '*') {
                    $key = substr($key, 0, strlen($key)-1);
                    $val = $val[$lang];
                }
                $val = preg_replace('/\{\{\*|\*\}\}/', '', $val);
                $expr = var_export($val, true);
                $sb[] = "    \$this->{$key} = {$expr};\n";
            }
            $sb[] =     "    \$this->_test();\n";
            $sb[] =     "  }\n";
            $sb[] =     "\n\n";
        }
    }
    $sb[] = "}\n";
    return join($sb);
}


function kwartz_define_testmethods_with_each_lang($testdata, $classname, $langs=null) {
    if (! $langs)
        $langs = array('php', 'eruby', 'jstl');
    $code = kwartz_build_testmethods_with_each_lang($testdata, $classname, $langs);
    eval($code);
}


error_reporting(E_ALL);


?>