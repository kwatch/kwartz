<?php

###
### Kwartz.inc -- library for Kwartz-php
###


//$kwartz_dir = '/usr/local/lib/php/kwartz/';
//ini_set("include_path", ini_get("include_path").PATH_SEPARATOR.$kwartz_dir);


//namespace Kwartz {

	//class Kwartz {
	//	const VERSION	 = '$Revision$';
	//	const LASTUPDATE = '$Date$';
	//}
	
//} // end of namespace Kwartz


require_once('KwartzException.inc');
require_once('KwartzUtility.inc');
require_once('KwartzVisitor.inc');
require_once('kwartzNode.inc');
require_once('KwartzScanner.inc');
require_once('KwartzParser.inc');
require_once('KwartzConverter.inc');
require_once('KwartzTranslator.inc');
require_once('KwartzErubyTranslator.inc');
require_once('KwartzJspTranslator.inc');
require_once('KwartzPlphpTranslator.inc');
require_once('KwartzCompiler.inc');
require_once('KwartzAnalyzer.inc');

?>