<?php
// refere $_REQUST as $params
$params =& $_REQUEST;

// action for submit button
$error_list = NULL;
$filename = 'register.view';
if (count($params) > 0) {
    // check input data
    $error_list = array();
    if (! $params['name']) {
        $error_list[] = 'Name is empty.';
    }
    switch ($params['gender']) {
    case 'M':  case 'W':
	break;   // OK
    default:
        $error_list[] = 'Gender is not selected.';
    }

    // if input parameter is valid then print the finished page (finish.rhtml),
    // else print the sampe page(register.rhtml)
    if (count($error_list) == 0) {
        $error_list = NULL;
        $filename = 'finish.view';
        //... data registration process ...
	$f = fopen("php://stderr", "w");
	fwrite($f, "*** name = '{$params['name']}', gender= '{$params['gender']}'\n");
	fclose($f);
    }
}

// print web page
include($filename);
