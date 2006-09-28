<?php
// vim: set expandtab tabstop=4 shiftwidth=4 softtabstop=4:

// $Rev$
// $Release$
// $Copyright$

require_once 'Kwartz/Converter.php';
require_once 'Kwartz/Translator.php';
require_once 'Kwartz/Binding/Ruby.php';


/**
 *  directive handler for PIEruby
 */
class KwartzPierubisHandler extends KwartzRubyHandler {
}



/**
 *  translator for eRuby
 */
class KwartzPierubisTranslator extends KwartzBaseTranslator {


    function __construct($properties=array()) {
        $marks = array(
            '<?rb ',  ' ?>',    // statement
            '@!{',    '}@',     // expression
            '@{',     '}@',     // escaped expression
            );
        parent::__construct($marks, $properties);
        //if ($this->escape === null)
        //    $this->escape = true;
    }


}


?>
