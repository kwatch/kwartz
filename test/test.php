<?php

###
### test.php - test for Kwartz*Test.php
###

require_once('PHPUnit.php');
//require_once('Kwartz/Kwartz.php');

$filenames = array(
	'KwartzNodeTest.php',
	'KwartzScannerTest.php',
	'KwartzParserTest.php',
	'KwartzConverterTest.php',
	'KwartzTranslatorTest.php',
	'KwartzCompilerTest.php',
	'KwartzAnalyzerTest.php',
	'KwartzCommandTest.php',
	'KwartzHelperTest.php',
);

$path = ini_get('include_path');
$path .= PATH_SEPARATOR . '..' . PATH_SEPARATOR . 'test';
ini_set('include_path', $path);

foreach ($filenames as $filename) {
	echo "--- $filename ---\n";
        require_once($filename);
}

?>
