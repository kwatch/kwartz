<?php

## set year
$year = $_REQUEST['year'];
if (! $year) {
	$year = date('Y', time());
}

## output buffering start
ob_start();

## set calendar_list
$calendar_list = array();
for ($i = 1; $i <= 12; $i++) {
    $t = mktime(0, 0, 0, $i, 1, $year);
    $month         = date("F", $t);   # 'January', 'February', ...
    $num_days      = date("t", $t);   # 28, 29, 30, or 31
    $first_weekday = date("w", $t)+1; # 1 (Sun) to 7 (Sat)
    
    ## get calendar month
    include('calendar-month.view');
    $str = ob_get_contents();
    ob_clean();
    
    $calendar_list[]  = $str;
}

## output buffering stop
ob_end_clean();

## include main page, with $calendar_list[]
$prev_link = "calendar.php?year=" . ($year-1);
$next_link = "calendar.php?year=" . ($year+1);
$colnum = 4;
include('calendar-page.view');

 ?>
