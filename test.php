<?php

###
### test.php - test for Kwartz*Test.php
###

require_once('PHPUnit.php');
//require_once('Kwartz.inc');

$filenames = array(
	'KwartzNodeTest.php',
	'KwartzScannerTest.php',
	'KwartzParserTest.php',
	'KwartzConverterTest.php',
	'KwartzTranslatorTest.php',
	'KwartzCompilerTest.php',
);

foreach ($filenames as $filename) {
	echo "--- $filename ---\n";
	require_once($filename);
}

?>
