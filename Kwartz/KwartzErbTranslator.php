<?php
// vim: set expandtab tabstop=4 shiftwidth=4 softtabstop=4:

// $Id$

require_once('Kwartz/KwartzErubyTranslator.php');

// namespace Kwartz {

/**
 *  translate node tree into ERB code
 */
class KwartzErbTranslator extends KwartzErubyTranslator {
    function __construct($block, $flag_escape=FALSE, $toppings=NULL) {
        parent::__construct($block, $flag_escape, $toppings);
        $this->keywords[':eprint']    = '<%= h(';
        $this->keywords[':endeprint'] = ') %>';
        $this->keywords['E(']         = 'h(';
        $this->keywords['E)']         = ')';
    }
}

// }  // end of namespace Kwartz
?>