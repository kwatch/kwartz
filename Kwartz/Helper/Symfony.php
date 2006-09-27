<?php
// vim: set expandtab tabstop=4 shiftwidth=4 softtabstop=4:

// $Rev$
// $Release$
// $Copyright$


function start_link_tag($options = '', $html_options = array()) {
   $s = link_to('', $options, $html_options);
   return preg_replace('/<\/a>\z/', '', $s);
}

function start_remote_link_tag($options = array(), $html_options = array()) {
   $s = link_to_remote('', $options, $html_options);
   return preg_replace('/<\a>\z/', '', $s);
}

function start_function_link_tag($function, $html_options = array()) {
   $s = link_to_function('', $function, $html_options);
   return preg_replace('/<\a>\z/', '', $s);
}

?>