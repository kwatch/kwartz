<?php

###
### Kwartz.php -- library for Kwartz-php
###
### $Id$
###


//$kwartz_dir = '/usr/local/lib/php/kwartz/';
//ini_set("include_path", ini_get("include_path").PATH_SEPARATOR.$kwartz_dir);


//namespace Kwartz {

class Kwartz {
    const REVISION   = '$Rev$';
    const LASTUPDATE = '$Date$';
}
	
//} // end of namespace Kwartz


require_once('Kwartz/KwartzException.php');
require_once('Kwartz/KwartzUtility.php');
require_once('Kwartz/KwartzVisitor.php');
require_once('Kwartz/KwartzNode.php');
require_once('Kwartz/KwartzScanner.php');
require_once('Kwartz/KwartzParser.php');
require_once('Kwartz/KwartzConverter.php');
require_once('Kwartz/KwartzTranslator.php');
require_once('Kwartz/KwartzErubyTranslator.php');
require_once('Kwartz/KwartzJspTranslator.php');
require_once('Kwartz/KwartzPlphpTranslator.php');
require_once('Kwartz/KwartzCompiler.php');
require_once('Kwartz/KwartzAnalyzer.php');

?>