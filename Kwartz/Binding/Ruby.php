<?php
// vim: set expandtab tabstop=4 shiftwidth=4 softtabstop=4:

// $Rev$
// $Release$
// $Copyright$

require_once 'Kwartz/KwartzConverter.php';
require_once 'Kwartz/KwartzTranslator.php';


/**
 *  directive handler for Ruby
 */
class KwartzRubyHandler extends KwartzHandler {


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
            $toggle_code = "  {$toggle} = {$counter}%2==0 ? {$this->even} : {$this->odd}";
            $code = array();
            if ($counter)  $code[] = "{$counter} = 0";
            if (true)      $code[] = $foreach_code;
            if ($counter)  $code[] = "  {$counter} += 1";
            if ($toggle)   $code[] = $toggle_code;
            if ($content_only) {
                $this->helper->wrap_content_with_native_stmt($stmt_list, $arg,
                                                             $code, "end", 'foreach');
            } else {
                $this->helper->wrap_element_with_native_stmt($stmt_list, $arg,
                                                             $code, "end", 'foreach');
            }
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
            $this->helper->error_when_last_stmt_is_not_if($stmt_list, $arg);
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
class KwartzRubyTranslator extends KwartzBaseTranslator {


    function __construct($properties=array()) {
        $escapefunc = kwartz_array_get($properties, 'escapefunc', 'ERB::Util.h');
        $marks = array(
            '',  '',                            // statement
            '_buf << (',  ').to_s; ',           // expression
            "_buf << {$escapefunc}(", '); ',    // escaped expression
            );
        parent::__construct($marks, $properties);
        if ($this->header !== false)
            $this->header = '_buf = ""; ';
        if ($this->footer !== false)
            $this->footer = '; _buf' . $this->nl;
    }


    function translate_string($str) {
        if (! $str) return;
        $str = preg_replace('/["\\\\]/', '\\\\$0', $str);
        if (substr($str, -1) == "\n") {
            $str = rtrim($str, "\n");
            $this->buf[] = "_buf << \"{$str}\\n\";{$this->nl}";
        }
        else {
            $this->buf[] = "_buf << \"{$str}\"; ";
        }
    }


    function translate($stmt_list) {
        $stmt_list2 = $this->optimize_print_stmts($stmt_list);
        return parent::translate($stmt_list2);
    }


}


?>