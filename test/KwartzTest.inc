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


function kwartz_define_testmethods($testdata, $classname, $parent_classname=null, $flag_defun=true) {
    if (! $parent_classname)
        $parent_classname = $classname . '_';
    $sb = array();
    $sb[] = "class {$classname} extends {$parent_classname} {\n";
    foreach ($testdata as $data) {
        $sb[] =     "  function test_{$data['name']}(){\n";
        foreach ($data as $key=>$val) {
            $sb[] = "    \$this->{$key} = " . var_export($val, true) . ";\n";
        }
        $sb[] =     "    \$this->_test();\n";
        $sb[] =     "  }\n";
    }
    $sb[] = "}\n";
    $s = join($sb);
    if ($flag_defun)
        eval($s);
    return $s;
}


error_reporting(E_ALL);


?>