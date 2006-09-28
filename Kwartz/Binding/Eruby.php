<?php
// vim: set expandtab tabstop=4 shiftwidth=4 softtabstop=4:

// $Rev$
// $Release$
// $Copyright$

require_once 'Kwartz/Converter.php';
require_once 'Kwartz/Translator.php';
require_once 'Kwartz/Binding/Ruby.php';


/**
 *  directive handler for eRuby
 */
class KwartzErubyHandler extends KwartzRubyHandler {
}



/**
 *  translator for eRuby
 */
class KwartzErubyTranslator extends KwartzBaseTranslator {


    function __construct($properties=array()) {
        $marks = array(
            '<% ',   ' %>',    // statement
            '<%= ',  ' %>',    // expression
            '<%=h ', ' %>',    // escaped expression
            );
        parent::__construct($marks, $properties);
    }


}


?>
