<?php
// vim: set expandtab tabstop=4 shiftwidth=4 softtabstop=4:

// $Rev$
// $Release$
// $Copyright$

require_once 'Kwartz/KwartzConverter.php';
require_once 'Kwartz/KwartzTranslator.php';
require_once 'Kwartz/Binding/Ruby.php';


/**
 *  directive handler for eRuby
 */
class KwartzErubisHandler extends KwartzRubyHandler {
}



/**
 *  translator for eRuby
 */
class KwartzErubisTranslator extends KwartzBaseTranslator {


    function __construct($properties=array()) {
        $marks = array(
            '<% ',   ' %>',    // statement
            '<%= ',  ' %>',    // expression
            '<%== ', ' %>',    // escaped expression
            );
        parent::__construct($marks, $properties);
    }


}


?>
