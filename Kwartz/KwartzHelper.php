<?php
// vim: set expandtab tabstop=4 shiftwidth=4 softtabstop=4:

// $Id$

require_once('Kwartz/KwartzException.php');
require_once('Kwartz/KwartzCompiler.php');

//namespace Kwartz {

class KwartzHelperError extends KwartzException {
    function __construct($msg) {
        parent::__construct($msg);
    }
}


function kwartz_compile_template($pdata_filename, $plogic_filename, $output_filename, $flag_escape, $lang='php', $toppings=NULL) {
    
    if ($pdata_filename && ! file_exists($pdata_filename)) {
        $msg = "'$pdata_filename': presentation data file not found.";
        throw new KwartzHelperError($msg);
    }
    if ($plogic_filename && ! file_exists($plogic_filename)) {
        $msg = "'$plogic_filename': presentation logic file not found.";
        throw new KwartzHelperError($msg);
    }
    
    // comparing timestamp
    $flag_compile = FALSE;
    if (! file_exists($output_filename)) {
        $flag_compile = TRUE;
    } elseif ($pdata_filename && (filemtime($pdata_filename) > filemtime($output_filename))) {
        $flag_compile = TRUE;
    } elseif ($plogic_filename && (filemtime($plogic_filename) > filemtime($output_filename))) {
        $flag_compile = TRUE;
    }
    if (! $flag_compile) {
        return;
    }
    
    // toppings
    if ($toppings === NULL) {
        $toppings = array();
    }
    if (! array_key_exists('pdata_filename', $toppings)) {
        $toppings['pdata_filename'] = $pdata_filename;
    }
    if (! array_key_exists('plogic_filename', $toppings)) {
        $toppings['plogic_filename'] = $plogic_filename;
    }
    
    // compile
    $pdata_str = '';
    if ($pdata_filename) {
        $pdata_str  = file_get_contents($pdata_filename);
    }
    $pdata_str  = $pdata_filename  ? file_get_contents($pdata_filename)  : '';
    $plogic_str = $plogic_filename ? file_get_contents($plogic_filename) : NULL;
    $compiler = new KwartzCompiler($pdata_str, $plogic_str, $lang, $flag_escape, $toppings);
    $output_str = $compiler->compile();
    
    // write into output script
    $f = fopen($output_filename, 'wb');
    if (! $f) {
        $msg = "'$output_filename': cannot open output script for writing.";
        throw new KwartzHelperError($msg);
    }
    fwrite($f, $output_str);
    fclose($f);
}

//}  // end of namespace
?>