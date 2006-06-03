<?php
// vim: set expandtab tabstop=4 shiftwidth=4 softtabstop=4:

// $Rev$
// $Release$
// $Copyright$


require_once('Kwartz/KwartzException.php');
require_once('Kwartz/KwartzNode.php');
require_once('Kwartz/KwartzUtility.php');
require_once('Kwartz/KwartzConfig.php');


/**
 *  translate list of Statement into target code (eRuby, PHP, ...)
 */
abstract class KwartzTranslator {

    /**
     *  translate list of Statement into String and return it
     */
    abstract function translate($stmt_list);


    /**
     *  translate NativeStatement using visitor pattern
     */
    abstract function translate_native_stmt($stmt);


    /**
     *  translate PrintStatement using visitor pattern
     */
    abstract function translate_print_stmt($stmt);


    /**
     *  translate NativeExpression using visitor pattern
     */
    abstract function translate_native_expr($expr);


    /**
     *  translate String using visitor pattern
     */
    abstract function translate_string($str);


}



/**
 * concrete class for visitor pattern
 *
 * see ErbTranslator, PhpTranslator, JstlTranslator, and so on for detail.
 */
class KwartzBaseTranslator extends KwartzTranslator {


    var $stmt_l;
    var $stmt_r;
    var $expr_l;
    var $expr_r;
    var $escape_l;
    var $escape_r;
    var $nl;
    var $escape;
    var $header;
    var $footer;

    var $buf;

    function __construct($marks, $properties=array()) {
        global $KWARTZ_PROPERTY_ESCAPE;
        list($this->stmt_l, $this->stmt_r, $this->expr_l, $this->expr_r,
             $this->escape_l, $this->escape_r) = $marks;
        $this->nl = kwartz_array_get($properties, 'nl', "\n");
        $this->escape = kwartz_array_get($properties, 'escape', $KWARTZ_PROPERTY_ESCAPE);
        $this->header = kwartz_array_get($properties, 'header', null);
        $this->footer = kwartz_array_get($properties, 'footer', null);
    }


    function translate($stmt_list) {
        $this->buf = array();
        if ($this->header)
            $this->buf[] = $this->header;
        foreach ($stmt_list as $stmt) {
            $stmt->accept($this);
        }
        if ($this->footer)
            $this->buf[] = $this->footer;
        return join($this->buf);
    }


    function translate_native_stmt($stmt) {
        $this->buf[] = $this->stmt_l;   // ex. '<%' . $stmt->code . '%>'
        $this->buf[] = $stmt->code;
        $this->buf[] = $this->stmt_r;
        if (! $stmt->no_newline)
            $this->buf[] = $this->nl;
    }


    function translate_print_stmt($stmt) {
        foreach ($stmt->args as $arg) {
            if (is_string($arg)) {
                $this->translate_string($arg);
            } else {
                assert('$arg instanceof KwartzNativeExpression');
                $this->translate_native_expr($arg);
            }
        }
    }


    function translate_native_expr($expr) {
        assert('$expr instanceof KwartzNativeExpression');
        $flag_escape = $expr->escape;
        if ($flag_escape === null) $flag_escape = $this->escape;
        if ($flag_escape) {   // ex. "<\?php echo htmlspecialchars(".$expr->code)."; ?\>"
            $this->buf[] = $this->escape_l;
            $this->buf[] = $expr->code;
            $this->buf[] = $this->escape_r;
        } else {              // ex. "<\?php echo " . $expr->code . "; ?\>"
            $this->buf[] = $this->expr_l;
            $this->buf[] = $expr->code;
            $this->buf[] = $this->expr_r;
        }
    }


    function translate_string($str) {
        $this->buf[] = $str;
    }

}



?>