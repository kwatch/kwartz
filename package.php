<?php


$files = array(
	'kwartz-php',
        'mkmethod-php',
);
$script_list = array();
foreach ($files as $file) {
	$script_list[] = array('name' => $file, 'md5sum' => md5_file($file));
}


$files = array(
	'Kwartz.php',
	'Kwartz/KwartzAnalyzer.php',
	'Kwartz/KwartzCompiler.php',
	'Kwartz/KwartzConverter.php',
	'Kwartz/KwartzErubyTranslator.php',
	'Kwartz/KwartzException.php',
	'Kwartz/KwartzJspTranslator.php',
	'Kwartz/KwartzNode.php',
	'Kwartz/KwartzParser.php',
	'Kwartz/KwartzPlphpTranslator.php',
	'Kwartz/KwartzScanner.php',
	'Kwartz/KwartzTranslator.php',
	'Kwartz/KwartzUtility.php',
	'Kwartz/KwartzVisitor.php',
	'Kwartz/KwartzHelper.php',
);
$file_list = array();
foreach ($files as $file) {
    //$dir = $file == 'Kwartz.php' ? '/' : 'Kwartz';
    $dir = '/';
    $file_list[] = array('name' => $file, 'dir' => $dir, 'md5sum' => md5_file("$file"));
}


$changelog_list = array();
$changelog_list[] = array(
	'version' => '0.1.0',
	'date'    => '2004-09-19',
	'state'   => 'beta',
	'notes'   => 'public beta release',
);

$last_changelog = $changelog_list[0];

$release = array();
//$release['version']   = '0.1.0';
//$release['date']      = '2004-09-19';
//$release['state']     = 'beta';
$release['version']   = $last_changelog['version'];
$release['date']      = $last_changelog['date'];
$release['state']     = $last_changelog['state'];
$release['license']   = 'GPL ver.2';
$release['notes']     = 'First public beta version.';


include('package.view');

?>
