<?php

###
### KwartzUtility.inc
###
### $Id: KwartzUtility.inc,v 0.1 2004/08/16 14:03:32 kwatch Exp kwatch $
###

//namespace Kwartz {

	function kwartz_inspect_str($str) {
		$str = str_replace('\\', '\\\\', $str);
		$str = str_replace('"',  '\\"',  $str);
		//$str = addcslashes($str, '\\"');
		$str = str_replace("\n", '\n',	 $str);
		$str = str_replace("\r", '\r',	 $str);
		$str = str_replace("\t", '\t',	 $str);
		$str = '"' . $str . '"';
		return $str;
	}

//} // end of namespace Kwartz
?>