<?php
// vim: set expandtab tabstop=4 shiftwidth=4 softtabstop=4:

// $Rev$
// $Release$
// $Copyright$

//namespace Kwartz {


/**
 *  inspect string
 */
function kwartz_inspect_str($str) {
    $str = str_replace('\\', '\\\\', $str);
    $str = str_replace('"',  '\\"',  $str);
    //$str = addcslashes($str, '\\"');
    $str = str_replace("\n", '\n',   $str);
    $str = str_replace("\r", '\r',   $str);
    $str = str_replace("\t", '\t',   $str);
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


/**
 *  expand tab characters
 */
function kwartz_untabify($str, $width=8) {
    $splitted = preg_split('/\t/', $str);
    $last = array_pop($splitted);
    $buf = array();
    foreach ($splitted as $s) {
        $buf[] = $s;
        if (($rindex = strrpos($s, "\n")) !== false)
            $column = strlen($s) - $rindex - 1;
        else
            $column = strlen($s);
        $n = $width - ($column % $width);
        $buf[] = str_repeat(' ', $n);
    }
    $buf[] = $last;
    return join($buf);
}

//function kwartz_untabify($str, $width=8) {
//    //if (! preg_match_all('/[^\t]*\t/', $str, $m)) {
//    if (! preg_match_all('/.*?\t/s', $str, $m)) {
//        return $str;
//    }
//    $sb = array();
//    $pos = 0;
//    $matches = $m[0];
//    foreach ($matches as $s) {
//        $len = strlen($s);
//        $pos += $len;
//        $len -= 1;
//        $sb[] = substr($s, 0, $len);
//        if (($rindex = strrpos($s, "\n")) !== false) {
//            $len -= $rindex + 1;
//        }
//        $n = $width - ($len % $width);
//        $sb[] = str_repeat(' ', $n);
//    }
//    $sb[] = substr($str, $pos);
//    return join($sb, '');
//}



/**
 *  get array item
 */
function kwartz_array_get(&$array, $key, $default=NULL) {
    return array_key_exists($key, $array) ? $array[$key] : $default;
}


/**
 *  append other array
 */
function kwartz_array_concat(&$array, &$other_array) {
    foreach ($other_array as $item) {
        $array[] = $item;
    }
    return $array;
}

//} // end of namespace Kwartz
?>