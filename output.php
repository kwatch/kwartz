#!/usr/bin/env php
<?php

ob_start();
require_once('kwartz-php');
ob_end_clean();

$i   = 0;
$pos = null;
foreach ($argv as $arg) {
    if ($arg == '-l') {
        $pos = $i + 1;
        break;
    }
    $i += 1;
}
if ($pos) {
    $langs = preg_split('/,/', $argv[$pos]);
} else {
    $langs = array('php', 'eruby', 'jstl');
    array_splice($argv, 1, 0, array('-l', '*dummy*'));
    $pos = 2;
}
array_splice($argv, $pos+1, 0, array('--header='));

$names = array(
    'php'    => 'PHP',
    'eruby'  => 'eRuby',
    'jstl'   => 'JSTL 1.1 & 1.0',
    'jstl11' => 'JSTL 1.1',
    'jstl10' => 'JSTL 1.0',
    );

try {
    $i = 0;
    foreach ($langs as $lang) {
        if (++$i > 1) {
            echo "\n";
        }
        $args = $argv;
        $args[$pos] = ($lang == 'jstl' ? 'jstl11' : $lang);
        $name = $names[$lang];
        echo "### for {$name}\n";
        $kwartz = new KwartzCommand($args);
        $s = $kwartz->main();
        echo $s;
        if ($s[strlen($s)-1] != "\n") {
            echo "\n";
        }
    }
} catch (KwartzException $ex) {
    fwrite(STDERR, "ERROR: " . $ex->getMessage() . "\n");
    exit(1);
}
exit(0);
?>