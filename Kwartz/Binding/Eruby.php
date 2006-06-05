<?php
// vim: set expandtab tabstop=4 shiftwidth=4 softtabstop=4:

// $Rev$
// $Release$
// $Copyright$

require_once 'Kwartz/KwartzConverter.php';
require_once 'Kwartz/KwartzTranslator.php';


/**
 *  directive handler for eRuby
 */
class KwartzErubyHandler extends KwartzHandler {


    function directive_pattern() {
        return '/\A(\w+)(?:[:\s]\s*(.*))?\z/';
    }


    function mapping_pattern() {
        return '/\A\'([-:\w]+)\'\s+(.*)\z/';
    }


    function directive_format() {
        return '%s: %s';
    }


    function handle($handler_arg, &$stmt_list) {
        $ret = parent::handle($handler_arg, $stmt_list);
        if ($ret) return $ret;

        $arg = $handler_arg;
        $d_name = $arg->directive_name;
        $d_arg  = $arg->directive_arg;
        $d_str  = $arg->directive_str;

        switch ($d_name) {

        case 'for':   case 'For':   case 'FOR':
        case 'list':  case 'List':  case 'LIST':
            $content_only = strtolower($d_name) == 'list';
            if ($content_only) {
                $this->helper->error_if_empty_tag($arg);
            }
            if (! preg_match('/\A(\w+)(?:,\s*(\w+))?\s+in\s+(.*)\z/', $d_arg, $m)
                && ! preg_match('/\A(\w+)(?:,(\w+))?\s*[:=]\s*(.*)\z/', $d_arg, $m)) {
                $msg = "'{$d_str}': invalid argument.";
                throw $this->_error($msg, $arg->stag_info->linenum);
            }
            list($dummy, $loopvar, $loopval, $looplist) = $m;
            $counter = $d_name == 'for' || $d_name == 'list' ? null : "{$loopvar}_ctr";
            $toggle  = $d_name != 'FOR' && $d_name != 'LIST' ? null : "{$loopvar}_tgl";
            $foreach_code = $loopval ? "{$looplist}.each do |{$loopvar}, {$loopval}|"
                                     : "for {$loopvar} in {$looplist} do";
            $init_code = "{$counter} = 0";
            $incr_code = "  {$counter} += 1";
            $toggle_code = "  {$toggle} = {$counter}%2==0 ? {$this->even} : {$this->odd}";
            $this->helper->add_foreach_stmts($stmt_list, $arg, $foreach_code, "end",
                                             $content_only, $counter, $toggle,
                                             $init_code, $incr_code, $toggle_code);
            break;

        case 'while':
            $this->helper->wrap_element_with_native_stmt($stmt_list, $arg,
                                                  "while {$d_arg} do", "end", 'while');
            break;

        case 'loop':
            $this->helper->error_if_empty_tag($arg);
            $this->helper->wrap_content_with_native_stmt($stmt_list, $arg,
                                                  "while {$d_arg} do", "end", 'while');
            break;

        case 'set':
            $this->helper->wrap_element_with_native_stmt($stmt_list, $arg, $d_arg, null, 'set');
            break;

        case 'if':
            $this->helper->wrap_element_with_native_stmt($stmt_list, $arg,
                                                  "if {$d_arg} then", "end", 'if');
            break;

        case 'elsif':
        case 'else':
            $last_stmt_kind = $this->helper->last_stmt_kind($stmt_list);
            if ($last_stmt_kind != 'if' && $last_stmt_kind != 'elseif') {
                $msg = "'{$d_str}': previous statement should be 'if' or 'elsif'.";
                throw $this->_error($msg, $arg->stag_info->linenum);
            }
            array_pop($stmt_list);    // delete 'end'
            $kind = $d_name == 'else' ? 'else' : 'elseif';
            $code = $d_name == 'else' ? "else" : "elsif {$d_arg} then";
            $this->helper->wrap_element_with_native_stmt($stmt_list, $arg, $code, "end", $kind);
            break;

        case 'default':
        case 'Default':
        case 'DEFAULT':
            $this->helper->error_if_empty_tag($arg);
            $escape = $d_name == 'default' ? null : ($d_name == 'Default');
            $code = "if ({$d_arg}) && !({$d_arg}).to_s.empty? then";
            $this->helper->add_native_expr_with_default($stmt_list, $arg, $d_arg, $escape,
                                                        $code, "else", "end");
            break;

        default:
            return false;
        }

        return true;
    }


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