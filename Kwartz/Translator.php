<?php
// vim: set expandtab tabstop=4 shiftwidth=4 softtabstop=4:

// $Rev$
// $Release$
// $Copyright$


require_once('Kwartz/Exception.php');
require_once('Kwartz/Node.php');
require_once('Kwartz/Utility.php');
require_once('Kwartz/Config.php');


/**
 *  translate list of Statement into target code (eRuby, PHP, ...)
 */
abstract class KwartzTranslator {

    /**
     *  translate list of Statement into String and return it
     */
    public function translate($stmt_list) {}
    //abstract public function translate($stmt_list);    // pear package error


    /**
     *  translate NativeStatement using visitor pattern
     */
    function translate_native_stmt($stmt) {}
    //abstract function translate_native_stmt($stmt);    // pear package error


    /**
     *  translate PrintStatement using visitor pattern
     */
    function translate_print_stmt($stmt) {}
    //abstract function translate_print_stmt($stmt);    // pear package error


    /**
     *  translate NativeExpression using visitor pattern
     */
    function translate_native_expr($expr) {}
    //abstract function translate_native_expr($expr);    // pear package error


    /**
     *  translate String using visitor pattern
     */
    function translate_string($str) {}
    //abstract function translate_string($str);    // pear package error

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
        list($this->stmt_l, $this->stmt_r, $this->expr_l, $this->expr_r,
             $this->escape_l, $this->escape_r) = $marks;
        $this->nl = kwartz_array_get($properties, 'nl', "\n");
        $this->escape = kwartz_array_get($properties, 'escape', KWARTZ_PROPERTY_ESCAPE);
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
                //$this->translate_string($arg);
                $this->parse_embedded_expr($arg);
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
        if ($flag_escape) {
            $this->_add_escaped_expr($expr->code);
        } else {
            $this->_add_plain_expr($expr->code);
        }
    }


    function _add_plain_expr($expr_code) {
        // ex. "<\?php echo " . $expr->code . "; ?\>"
        $this->buf[] = $this->expr_l;
        $this->buf[] = $expr_code;
        $this->buf[] = $this->expr_r;
    }


    function _add_escaped_expr($expr_code) {
        // ex. "<\?php echo htmlspecialchars(".$expr->code)."; ?\>"
        $this->buf[] = $this->escape_l;
        $this->buf[] = $expr_code;
        $this->buf[] = $this->escape_r;
    }


    function _add_debug_expr($expr_code) {
        /* TBI */
    }


    function translate_string($str) {
        $this->buf[] = $str;
    }


    function parse_embedded_expr($text) {
        kwartz_scan_text('/@(!*)\{(.*?)\}@/', $text, $matched, $rest);
        foreach ($matched as $m) {
            $prev_text = $m[0];
            $indicator = $m[1];
            $expr_code = $m[2];
            $this->translate_string($prev_text);
            $len = strlen($indicator);
            switch ($len) {
            case 0:  $this->_add_escaped_expr($expr_code);  break;
            case 1:  $this->_add_plain_expr($expr_code);    break;
            case 1:  $this->_add_debug_expr($expr_code);    break;
            default:  // ignore
            }
        }
        if ($rest) {
            $this->translate_string($rest);
        }
    }



    // concat several print statements into a statement
    function optimize_print_stmts($stmt_list) {
        $stmt_list2 = array();   // list
        $args = array();  // list
        foreach ($stmt_list as $stmt) {
            if ($stmt instanceof KwartzPrintStatement) {
                kwartz_array_concat($args, $stmt->args);
            }
            else {
                if (count($args) != 0) {
                    $args = $this->_compact_args($args);
                    $stmt_list2[] = new KwartzPrintStatement($args);
                    $args = array();
                }
                $stmt_list2[] = $stmt;
            }
        }
        if (count($args) != 0) {
            $args = $this->_compact_args($args);
            $stmt_list2[] = new KwartzPrintStatement($args);
        }
        return $stmt_list2;
    }


    // concat several string arguments into a string in arguments
    function _compact_args(&$args) {
        $args2 = array();  // list
        $buf   = array();  // list
        foreach ($args as $arg) {
            if (is_string($arg)) {
                $buf[] = $arg;
            }
            else {
                assert('$arg instanceof KwartzNativeExpression');
                if (count($buf) > 0) {
                    $args2[] = join($buf);
                    $buf = array();
                }
                $args2[] = $arg;
            }
        }
        if (count($buf) > 0) {
            $args2[] = join($buf);
        }
        return $args2;
    }


}



?>
