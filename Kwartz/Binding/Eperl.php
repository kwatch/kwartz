<?php
// vim: set expandtab tabstop=4 shiftwidth=4 softtabstop=4:

// $Rev$
// $Release$
// $Copyright$

require_once 'Kwartz/Converter.php';
require_once 'Kwartz/Translator.php';


/**
 *  directive handler for ePerl
 */
class KwartzEperlHandler extends KwartzHandler {


    function directive_pattern() {
        return '/\A(\w+)(?:\s*\(\s*(.*)\))?\z/';
    }


    function mapping_pattern() {
        return '/\A\'([-:\w]+)\',\s*(.*)\z/';
    }


    function directive_format() {
        return '%s(%s)';
    }


    function handle($handler_arg, &$stmt_list) {
        $ret = parent::handle($handler_arg, $stmt_list);
        if ($ret) return $ret;

        $arg = $handler_arg;
        $d_name = $arg->directive_name;
        $d_arg  = $arg->directive_arg;
        $d_str  = $arg->directive_str;

        switch ($d_name) {

        case 'foreach':  case 'Foreach':  case 'FOREACH':
        case 'list':     case 'List':     case 'LIST':
            $content_only = strtolower($d_name) == 'list';
            if ($content_only) {
                $this->helper->error_if_empty_tag($arg);
            }
            if (! preg_match('/\A(\$\w+)(?:,\s*(\$\w+))?\s+in\s+(.*)\z/', $d_arg, $m)) {
                $msg = "'{$d_str}': invalid argument.";
                throw $this->_error($msg, $arg->stag_info->linenum);
            }
            list($dummy, $loopvar, $loopval, $looplist) = $m;
            $counter = $d_name == 'foreach' || $d_name == 'list' ? null : "{$loopvar}_ctr";
            $toggle  = $d_name != 'FOREACH' && $d_name != 'LIST' ? null : "{$loopvar}_tgl";
            $code = array();
            if ($counter)   $code[] = "my {$counter} = 0;";
            if ($loopval) { $looplist2 = preg_replace('/\A%/', '$', $looplist);
                            $code[] = "foreach my {$loopvar} (keys {$looplist}) {";
                            $code[] = "  my {$loopval} = {$looplist2}{{$loopvar}};";
            } else {        $code[] = "foreach my {$loopvar} ({$looplist}) {";
            }
            if ($counter)   $code[] = "  {$counter}++;";
            if ($toggle)    $code[] = "  my {$toggle} = {$counter}%2==0 ? {$this->even} : {$this->odd};";
            if ($content_only) {
                $this->helper->wrap_content_with_native_stmt($stmt_list, $arg,
                                                             $code, "}", 'foreach');
            } else {
                $this->helper->wrap_element_with_native_stmt($stmt_list, $arg,
                                                             $code, "}", 'foreach');
            }
            break;

        case 'while':
            $this->helper->wrap_element_with_native_stmt($stmt_list, $arg,
                                                  "while ({$d_arg}) {", "}", 'while');
            break;

        case 'loop':
            $this->helper->error_if_empty_tag($arg);
            $this->helper->wrap_content_with_native_stmt($stmt_list, $arg,
                                                   "while ({$d_arg}) {", "}", 'while');
            break;

        case 'set':
            $this->helper->wrap_element_with_native_stmt($stmt_list, $arg,
                                                         "{$d_arg};", null, 'set');
            break;

        case 'if':
            $this->helper->wrap_element_with_native_stmt($stmt_list, $arg,
                                                         "if ({$d_arg}) {", "}", 'if');
            break;

        case 'elsif':
        case 'else':
            $this->helper->error_when_last_stmt_is_not_if($stmt_list, $arg);
            array_pop($stmt_list);    // delete '}'
            $kind = $d_name == 'else' ? 'else' : 'elseif';
            $code = $d_name == 'else' ? "} else {" : "} elsif ({$d_arg}) {";
            $this->helper->wrap_element_with_native_stmt($stmt_list, $arg,
                                                         $code, "}", $kind);
            break;

        case 'default':
        case 'Default':
        case 'DEFAULT':
            $this->helper->error_if_empty_tag($arg);
            $escape = $d_name == 'default' ? null : ($d_name == 'Default');
            $code = "if ({$d_arg}) {";
            $this->helper->add_native_expr_with_default($stmt_list, $arg, $d_arg, $escape,
                                                        $code, "} else {", "}");
            break;

        default:
            return false;
        }

        return true;
    }


}



/**
 *  translator for ePerl
 */
class KwartzEperlTranslator extends KwartzBaseTranslator {


    function __construct($properties=array()) {
        $marks = array(
            '<'.'? ',   ' !>',                   // statement
            '<'.'?= ',  ' !>',                   // expression
            '<'.'?= encode_entities(', ') !>',   // escaped expression
            );
        parent::__construct($marks, $properties);
    }


}


?>
