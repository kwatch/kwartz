<?php

// menu
$menulist = array(
    array('label' => 'Mail',     'url' => '/cgi-bin/mail.cgi'     ),
    array('label' => 'Calnedar', 'url' => '/cgi-bin/calendar.cgi' ),
    array('label' => 'Todo',     'url' => '/cgi-bin/todo.cgi'     ),
    array('label' => 'Stock',    'url' => '/cgi-bin/stock.cgi'    ),
    );


// contents data
$stocks = array(
    array('symbol' => "AAPL", 'price' => 62.94, 'rate' => -0.23,
          'company' => "Apple Computer, Inc." ),
    array('symbol' => "MSFT", 'price' => 22.53, 'rate' =>  0.64,
          'company' => "Microsoft Corp." ),
    array('symbol' => "ORCL", 'price' => 12.89, 'rate' => -2.02,
          'company' => "Oracle Corporation" ),
    array('symbol' => "SUNW", 'price' =>  4.12, 'rate' =>  0.28,
          'company' => "Sun Microsystems, Inc." ),
    array('symbol' => "INTC", 'price' => 18.61, 'rate' =>  1.01,
          'company' => "Intel Corporation" ),
    );


// stock symbol
$symbol = NULL;
if ($_REQUEST['symbol']) {
    $symbol = $_REQUEST['symbol'];
} elseif ($argv[1]) {
    $symbol = $argv[1];
} else {
    $symbol = NULL;
}

// filename
if ($symbol) {
    $stock = NULL;
    foreach ($stocks as $arr) {
        if ($arr['symbol'] == $symbol) {
            $stock = $arr;
            break;
        }
    }
    $filename = 'content2.php';
} else {
    $filename = 'content1.php';
}


// output
include($filename);

?>