<?php

###
### KwartzUtility.inc
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