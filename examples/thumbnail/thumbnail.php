<?php

	$params = &$_REQUEST;
	$script = $_SERVER['SCRIPT_NAME'];
	
	// set url format of images
	$base_url  = "http://www.kuwata-lab.com/kwartz/kwartz-overview/images";
	$image_url_format = "{$base_url}/image%02d.png";
	
	// get parameters
	$first = 1;
	$last  = 20;
	$page = $params['page'];
	if (!$page || !($first <= $page && $page <=  $last)) {
		$page = 0;
	}
	
	// set URLs of previous, next, first, last, and index page
	$prev_url  = $page > $first ? "${script}?page=${".($page-1)."}" : NULL;
	$next_url  = $page < $last  ? "${script}?page=${".($page+1)."}" : NULL;
	$first_url = $page > $first ? "${script}?page=${first}"         : NULL;
	$last_url  = $page < $last  ? "${script}?page=${last}"          : NULL;
	$index_url = $page != 0     ? "${script}?page=0"                : NULL;
	
	if ($page > 0) {
		$image_url = sprintf($image_url_format, $page);
	} elseif ($page == 0) {
		$thumb_list = array();
		for ($i = $first; $i <= $last; $i++) {
			$image_url = sprintf($image_url_format, $i);
			$link_url  = sprintf("${script}?page=${i}");
			$thumb_list[] = array('image_url' => $image_url,
					      'link_url'  => $link_url);
		}
	} else {
		## internal error
	}

	// load view
	include('thumbnail.view');
?>
