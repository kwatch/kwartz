<?PHP

###
### test.php - test for kwartz.inc
###
### $Id: test.php,v 0.1 2004/08/15 08:47:17 kwatch Exp kwatch $
###

require_once('PHPUnit.php');
//require_once('kwartz.inc');

$filenames = array(
	'KwartzElementTest.php',
	'KwartzScannerTest.php',
	'KwartzParserTest.php',
);

foreach ($filenames as $filename) {
	echo "--- $filename ---\n";
	require_once($filename);
}

?>
