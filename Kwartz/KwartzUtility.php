<?php
// vim: set expandtab tabstop=4 shiftwidth=4 softtabstop=4:

// $Id$

//namespace Kwartz {


/**
 *  inspect string
 */
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


/**
 *  detect which is the newline "\n" or "\r\n"
 */
function kwartz_detect_newline_char(&$str) {
    if (!$str || ($pos = strpos($str, "\n")) == NULL) {
        return NULL;
    }
    return $str{$pos-1} == "\r" ? "\r\n" : "\n";
}

//} // end of namespace Kwartz
?>