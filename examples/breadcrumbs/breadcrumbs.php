<?php

// set breadcrumbs
$breadcrumbs = array();
$breadcrumbs[] = array('path' => '/', 'name' => 'Home');
$breadcrumbs[] = array('path' => '/kwartz-php',	'name' => 'Kwartz-php');
$breadcrumbs[] = array('path' => '/kwartz-php/examples/', 'name' => 'Examples');
$breadcrumbs[] = array('path' => '/kwartz-php/examples/breacrumbs', 'name' => 'Breadcrumbs');

// set title
$title = 'Example: Breadcrumbs';

// output
include('breadcrumbs.view');

?>