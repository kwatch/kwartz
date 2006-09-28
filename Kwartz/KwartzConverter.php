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
 *  exception class for convertion
 */
class KwartzConvertionException extends KwartzBaseException {


    function __construct($msg, $filename=null, $linenum=null) {
        parent::__construct($msg, $filename, $linenum);
    }


}



/**
 *  tag info
 */
class KwartzTagInfo {


    var $prev_text;
    var $tag_text;
    var $head_space;
    var $is_etag;
    var $tagname;
    var $attr_str;
    var $extra_space;
    var $is_empty;
    var $tail_space;
    var $linenum;


    function __construct($matched, $linenum=null) {
        $this->prev_text   = $matched[1];
        $this->tag_text    = $matched[2];
        $this->head_space  = $matched[3];
        $this->is_etag     = $matched[4] == '/';
        $this->tagname     = $matched[5];
        $this->attr_str    = $matched[6];
        $this->extra_space = $matched[7];
        $this->is_empty    = $matched[8] == '/';
        $this->tail_space  = kwartz_array_get($matched, 9);
        $this->linenum = $linenum;
    }


    function set_tagname($tagname) {
        $this->tagname = $tagname;
        $this->rebuild_tag_text();
        return $tagname;
    }


    function rebuild_tag_text($attr_info=null) {
        if ($attr_info) {
            $buf = array();
            $n = count($attr_info->names);
            for ($i = 0; $i < $n; $i++) {
                $name  = $attr_info->names[$i];
                $space = $attr_info->spaces[$name];
                $value = $attr_info->values[$name];
                $buf[] = "$space$name=\"$value\"";
            }
            $this->attr_str = join($buf);
        }
        $slash1 = $this->is_etag ? '/' : '';
        $slash2 = $this->is_empty ? '/' : '';
        $this->tag_text = "{$this->head_space}<{$slash1}{$this->tagname}{$this->attr_str}{$this->extra_space}{$slash2}>{$this->tail_space}";
    }


    function _inspect() {
        return array($this->prev_text, $this->head_space, $this->is_etag,
                     $this->tagname, $this->attr-str, $this->extra_space,
                     $this->is_empty, $this->tail_space);
    }


}



/**
 *  attribute info
 */
class KwartzAttrInfo {


    var $names;
    var $values;
    var $spaces;
    var $directive;
    var $linenum;


    function __construct($attr_str) {
        $this->names  = array();   // list
        $this->values = array();   // hash
        $this->spaces = array();   // hash
        if (preg_match_all('/(\s+)([-:_\w]+)="([^"]*?)"/', $attr_str, $matches)) {
            $i = -1;
            $len = count($matches[0]);
            while (++$i < $len) {
                $space = $matches[1][$i];
                $name  = $matches[2][$i];
                $value = $matches[3][$i];
                $this->names[] = $name;
                $this->values[$name] = $value;
                $this->spaces[$name] = $space;
            }
        }
    }


    function get_value($name) {
        return kwartz_array_get($this->values, $name);
    }


    function set_value($name, $value) {
        if (!in_array($name, $this->names)) {
            $this->names[] = $name;
            $this->spaces[$name] = ' ';
        }
        $this->values[$name] = $value;
    }


    function tuples() {
        $tuples = array();
        foreach ($this->names as $name) {
            $tuples[] = array($this->spaces[$name], $name, $this->values[$name]);
        }
        return $tuples;
    }


    function delete($name) {
        $i = 0;
        foreach ($this->names as $item) {
            if ($item == $name) {
                array_splice($this->names, $i, 1);
                $this->values[$name] = NULL;
                $this->spaces[$name] = NULL;
                return;
            }
            $i++;
        }
    }


    function is_empty() {
        return count($this->names) == 0;
    }


}



class KwartzElementInfo {


    var $name;              // string
    var $stag_info;         // TagInfo
    var $etag_info;         // TagInfo
    var $cont_stmts;        // list of Statement
    var $attr_info;         // AttrInfo
    var $append_exprs;      // list of NativeExpression
    var $logic;             // list of Statement
    //
    var $merged;            // ElementRuleset
    var $stag_expr;
    var $cont_expr;
    var $etag_expr;
    var $elem_expr;


    function __construct($name, $stag_info, $etag_info, $cont_stmts, $attr_info, $append_exprs) {
        $this->name         = $name;
        $this->stag_info    = $stag_info;
        $this->etag_info    = $etag_info;
        $this->cont_stmts   = $cont_stmts;
        $this->attr_info    = $attr_info;
        $this->append_exprs = $append_exprs;
        $this->logic        = array( new KwartzExpandStatement('elem', $name) );
        $this->merged       = NULL;
    }


    function is_merged() {
        return $this->merged;
    }


    // create from hash
    static function create($hash) {
        $h = $hash;
        return new ElementInfo($h['name'], $h['stag'], $h['etag'],
                               $h['cont'], $h['attr'], $h['append']);
    }


    function merge($elem_ruleset) {
        if ($elem_ruleset->name != $this->name)
            return;
        $this->merged = $elem_ruleset;
        $this->stag_expr = $this->_to_native_expr($elem_ruleset->stag);
        $this->cont_expr = $this->_to_native_expr($elem_ruleset->cont ? $elem_ruleset->cont : $elem_ruleset->value);
        $this->etag_expr = $this->_to_native_expr($elem_ruleset->etag);
        $this->elem_expr = $this->_to_native_expr($elem_ruleset->elem);
        if ($this->cont_expr) {
            $this->cont_stmts = array( new KwartzPrintStatement(array($this->cont_expr)) );
            $this->stag_info->tail_space = '';
            $this->etag_info->head_space = '';
            $this->etag_info->rebuild_tag_text();
        }
        if ($elem_ruleset->remove) {
            foreach ($elem_ruleset->remove as $aname) {
                $this->attr_info->delete($aname);
            }
        }
        if ($elem_ruleset->attrs) {
            foreach ($elem_ruleset->attrs as $aname=>$native_expr) {
                $this->attr_info->set_value($aname, $native_expr);
            }
        }
        if ($elem_ruleset->append) {
            foreach ($elem_ruleset->append as $expr) {
                if (! $this->append_exprs)
                    $this->append_exprs = array();
                $this->append_exprs[] = $this->_to_native_expr($expr);
            }
        }
        $this->tagname = $elem_ruleset->tagname;
        if ($elem_ruleset->logic !== null)
            $this->logic = $elem_ruleset->logic;
    }


    function _to_native_expr($value) {
        return $value && is_string($value) ? new NativeExpression($value) : $value;
    }


}



/**
 *  helper module for Converter and Handler
 *
 *  Handler and Converter class include this module.
 */
class KwartzStatementBuilder {


    /**
     *  return PrintStatement instance
     */
    function create_text_print_stmt($text) {
        return new KwartzPrintStatement(array($text));
        //return PritnStatement.new(array(new TextExpression($text)))
    }


    /**
     *  create array of String and NativeExpression for PrintStatement
     */
    function build_print_args($taginfo, $attr_info, $append_exprs) {
        if ($taginfo === null) {
            throw new KwartzException("debug: append_exprs=" . var_export($append_exprs, true));
        }
        if (! $taginfo->tagname) {
            return array();
        }
        if (! ($attr_info || $append_exprs)) {
            return array($taginfo->tag_text);
        }
        $args = array();
        $t = $taginfo;
        $slash = $t->is_etag ? '/' : '';
        $sb = "{$t->head_space}<{$slash}{$t->tagname}";
        if ($attr_info) {
            foreach ($attr_info->names as $aname) {
                $space = $attr_info->spaces[$aname];
                $avalue = $attr_info->values[$aname];
                $sb .= "{$space}{$aname}=\"";
                if ($avalue instanceof KwartzNativeExpression) {
                    $args[] = $sb;
                    $args[] = $avalue;
                    $sb = '';
                } else {
                    $sb .= $avalue;
                }
                $sb .= '"';
            }
        }
        if ($append_exprs) {
            if ($sb) {
                $args[] = $sb;
                $sb = '';
            }
            $args = array_merge($args, $append_exprs);
        }
        $slash = $t->is_empty ? '/' : '';
        $sb .= "{$t->extra_space}{$slash}>{$t->tail_space}";
        $args[] = $sb;
        return $args;
    }


    /**
     *  create PrintStatement for TagInfo
     */
    function build_print_stmt($taginfo, $attr_info, $append_exprs) {
        //$args = $this->build_print_args($taginfo, $attr_info, $append_exprs);
        $args = KwartzStatementBuilder::build_print_args($taginfo, $attr_info, $append_exprs);
        return new KwartzPrintStatement($args);
    }


    /**
     *  create PrintStatement for NativeExpression
     */
    function build_print_expr_stmt($native_expr, $stag_info, $etag_info) {
        $taginfo = $stag_info ? $stag_info : $etag_info;
        $head_space = $taginfo->head_space;
        $taginfo = $etag_info ? $etag_info : $stag_info;
        $tail_space = $taginfo->tail_space;
        $args = array();
        if ($head_space)
            $args[] = $head_space;
        $args[] = $native_expr;
        if ($tail_space)
            $args[] = $tail_space;
        return new KwartzPrintStatement($args);
    }


}



/**
 *  arguments for handler
 */
class KwartzHandlerArgument {


    var $directive_name;
    var $directive_arg;
    var $directive_str;
    var $stag_info;
    var $etag_info;
    var $cont_stmts;
    var $attr_info;
    var $append_exprs;


    function __construct($directive_name, $directive_arg, $directive_str,
                         $stag_info, $etag_info, &$cont_stmts, $attr_info, &$append_exprs) {
        $this->directive_name = $directive_name;
        $this->directive_arg  = $directive_arg;
        $this->directive_str  = $directive_str;
        $this->stag_info      = $stag_info;
        $this->etag_info      = $etag_info;
        $this->cont_stmts     =& $cont_stmts;
        $this->attr_info      = $attr_info;
        $this->append_exprs   =& $append_exprs;
        //
        $this->builder = new KwartzStatementBuilder();
    }


}



/**
 *  helper methods for Handler
 */
class KwartzHandlerHelper {


    var $hander;


    function __construct($handler) {
        $this->handler = $handler;
    }


    function _error($message, $linenum=null) {
        $filename = $this->handler->filename;
        return new KwartzConvertionException($message, $filename, $linenum);
    }


    function error_if_empty_tag($handler_arg) {
        if (! $handler_arg->etag_info) {
            $d_name = $handler_arg->directive_name;
            $d_str  = $handler_arg->directive_str;
            $msg = "'{$d_str}': {$d_name} directive is not available with empty tag.";
            throw $this->_error($msg, $handler_arg->stag_info->linenum);
        }
    }


    function last_stmt_kind(&$stmt_list) {
        $n = count($stmt_list);
        if (! $n)
            return null;
        $stmt = $stmt_list[$n - 1];
        if (! ($stmt instanceof KwartzNativeStatement))
            return null;
        return $stmt->kind;
    }


    function error_when_last_stmt_is_not_if(&$stmt_list, $arg) {
        $last_stmt_kind = $this->last_stmt_kind($stmt_list);
        if ($last_stmt_kind != 'if' && $last_stmt_kind != 'elseif') {
            $d_str = $handler_arg->directive_str;
            $linenum = $handler_arg->stag_info->linenum;
            $msg = "'{$d_str}': previous statement must be 'if' or 'else if'.";
            throw $this->_error($msg, $linenum);
        }
    }


    function stag_stmt($handler_arg) {
        return KwartzStatementBuilder::build_print_stmt($handler_arg->stag_info,
                                                        $handler_arg->attr_info,
                                                        $handler_arg->append_exprs);
    }


    function etag_stmt($handler_arg) {
        return KwartzStatementBuilder::build_print_stmt($handler_arg->etag_info,
                                                        null, null);
    }


    function add_native_stmt(&$stmt_list, $code, $kind) {
        if (is_string($code)) {
            $stmt_list[] = new KwartzNativeStatement($code, $kind);
        } elseif (is_array($code)) {
            foreach ($code as $line) {
                $stmt_list[] = new KwartzNativeStatement($line, $kind);
            }
        }
    }


    function wrap_element_with_native_stmt(&$stmt_list, $handler_arg,
                                           $start_code, $end_code, $kind=null) {
        $this->add_native_stmt($stmt_list, $start_code, $kind);
        $stmt_list[] = $this->stag_stmt($handler_arg);
        foreach ($handler_arg->cont_stmts as $stmt)
            $stmt_list[] = $stmt;
        $stmt_list[] = $this->etag_stmt($handler_arg);
        $this->add_native_stmt($stmt_list, $end_code, $kind);
    }


    function wrap_content_with_native_stmt(&$stmt_list, $handler_arg,
                                           $start_code, $end_code, $kind=null) {
        $stmt_list[] = $this->stag_stmt($handler_arg);
        $this->add_native_stmt($stmt_list, $start_code, $kind);
        foreach ($handler_arg->cont_stmts as $stmt)
            $stmt_list[] = $stmt;
        $this->add_native_stmt($stmt_list, $end_code, $kind);
        $stmt_list[] = $this->etag_stmt($handler_arg);
    }


    function add_native_expr_with_default(&$stmt_list, $handler_arg,
                                          $expr_code, $flag_escape,
                                          $if_code, $else_code, $endif_code) {
        $stmt_list[] = $this->stag_stmt($handler_arg);
        $stmt = new KwartzNativeStatement($if_code, 'if');
        $stmt->no_newline = true;
        $stmt_list[] = $stmt;
        $pargs = array(new KwartzNativeExpression($expr_code, $flag_escape));
        $stmt_list[] = new KwartzPrintStatement($pargs);
        $stmt = new KwartzNativeStatement($else_code, 'else');
        $stmt->no_newline = true;
        $stmt_list[] = $stmt;
        kwartz_array_concat($stmt_list, $handler_arg->cont_stmts);
        $stmt = new KwartzNativeStatement($endif_code, 'else');
        $stmt->no_newline = true;
        $stmt_list[] = $stmt;
        $stmt_list[] = $this->etag_stmt($handler_arg);
    }


}



/**
 *  [abstract] handle directives
 */
abstract class KwartzHandler {


    var $elem_rulesets;     // list of KwartzElementRuleset
    var $_elem_ruleset_table;  // hash
    var $_elem_info_table;     // hash
    var $_dattr;     // string ('table')
    var $_delspan;   // boolean (false)
    var $odd;       // string ("'odd'")
    var $even;      // string ("'even'")
    var $filename;
    var $builder;   // KwartzStatementBuilder
    var $helper;    // KwartzHandlerHelper


    function __construct($elem_rulesets=array(), $properties=array()) {
        $this->elem_rulesets = $elem_rulesets;
        $this->_elem_ruleset_table = array(); // hash
        foreach ($elem_rulesets as $ruleset) {
            $this->_elem_ruleset_table[$ruleset->name] = $ruleset;
        }
        $this->_elem_info_table = array();    // hash
        $this->_dattr   = kwartz_array_get($properties, 'dattr',   KWARTZ_PROPERTY_DATTR);
        $this->_delspan = kwartz_array_get($properties, 'delspan', KWARTZ_PROPERTY_DELSPAN);
        $this->odd      = kwartz_array_get($properties, 'odd',  KWARTZ_PROPERTY_ODD);
        $this->even     = kwartz_array_get($properties, 'even', KWARTZ_PROPERTY_EVEN);
        $this->filename = null;
        $this->builder  = new KwartzStatementBuilder();
        $this->helper   = new KwartzHandlerHelper($this);
    }


    function get_element_ruleset($name) { // for ElementExpander module and Converter class
        return kwartz_array_get($this->_elem_ruleset_table, $name, null);
    }


    function get_element_info($name) {  // for ElementExpander module
        return kwartz_array_get($this->_elem_info_table, $name, null);
    }


    /**
     *  directive pattern, which is used to detect directives.
     *  ex. '/\A(\w+):\s*(.*)/'
     */
    abstract function directive_pattern();


    /**
     *  mapping pattern, which is used to parse 'attr' directive.
     *  ex. '/\A\'([-:\w]+)\'\s+(.*)/'
     */
    abstract function mapping_pattern();


    /**
     *  directive format, which is used at has_directive?() method.
     *  ex. '%s: %s'
     */
    abstract function directive_format();


    function _error($message, $linenum=null) {
        return new KwartzConvertionException($message, $this->filename, $linenum);
    }



    /**
     * handle directives ('stag', 'etag', 'elem', 'cont'(='value')).
     * return true if directive name is one of 'stag', 'etag', 'elem', 'cont', and 'value',
     * else return false.
     */
    function handle($handler_arg, &$stmt_list) {
        $arg = $handler_arg;
        $d_name = $arg->directive_name;
        $d_arg  = $arg->directive_arg;
        $d_str  = $arg->directive_str;
        $stag_info    = $arg->stag_info;
        $etag_info    = $arg->etag_info;
        $cont_stmts   =& $arg->cont_stmts;
        $attr_info    = $arg->attr_info;
        $append_exprs =& $arg->append_exprs;

        switch ($d_name) {
        case NULL:
            assert($attr_info || $append_exprs);
            $stmt_list[] = $this->builder->build_print_stmt($stag_info, $attr_info, $append_exprs);
            kwartz_array_concat($stmt_list, $cont_stmts);
            if ($etag_info) {
                $stmt_list[] = $this->builder->build_print_stmt($etag_info, null, null);
            }
            break;

        case 'dummy':
            // nothing
            break;

        case 'id':
        case 'mark':
            if (preg_match('/\A(\w+)\z/', $d_arg)) {
                $name = $d_arg;
            } elseif (preg_match('/\A\'(\w+)\'\z/', $d_arg, $m)) {
                $name = $m[1];
            } else {
                $msg = "'{$d_str}': invalid marking name.";
                throw $this->_error($msg, $stag_info->linenum);
            }
            $elem_info = new KwartzElementInfo($name, $stag_info, $etag_info, $cont_stmts, $attr_info, $append_exprs);
            if (array_key_exists($name, $this->_elem_info_table)) {
                $previous_linenum = $_elem_info_table[$name]->stag_info->linenum;
                $msg = "'{$d_str}': id '{$name}' is already used ad line {$previous_linenum}.";
                throw $this->_error($msg, $stag_info->linenum);
            } else {
                $this->_elem_info_table[$name] = $elem_info;
            }
            //$stmt_list[] = new ExpandStatement('element', $name);  // lazy expantion
            $this->expand_element_info($elem_info, $stmt_list);
            break;

        case 'stag':
        case 'Stag':
        case 'STAG':
            $this->helper->error_if_empty_tag($arg);
            $flag_escape = $d_name == 'stag' ? null : ($d_name == 'Stag');
            $expr = new KwartzNativeExpression($d_arg, $flag_escape);
            $stmt_list[] = $this->builder->build_print_expr_stmt($expr, $stag_info, null);
            kwartz_array_concat($stmt_list, $cont_stmts);
            $stmt_list[] = $this->builder->build_print_stmt($etag_info, null, null);
            break;

        case 'etag':
        case 'Etag':
        case 'ETAG':
            $this->helper->error_if_empty_tag($arg);
            $flag_escape = $d_name == 'etag' ? null : ($d_name == 'Etag');
            $expr = new KwartzNativeExpression($d_arg, $flag_escape);
            $stmt_list[] = $this->builder->build_print_stmt($stag_info, $attr_info, $append_exprs);
            kwartz_array_concat($stmt_list, $cont_stmts);
            $stmt_list[] = $this->builder->build_print_expr_stmt($expr, null, $etag_info);
            break;

        case 'elem':
        case 'Elem':
        case 'ELEM':
            $flag_escape = $d_name == 'elem' ? null : ($d_name == 'Elem');
            $expr = new KwartzNativeExpression($d_arg, $flag_escape);
            $stmt_list[] = $this->builder->build_print_expr_stmt($expr, $stag_info, $etag_info);
            break;

        case 'cont':
        case 'Cont':
        case 'CONT':
        case 'value':
        case 'Value':
        case 'VALUE':
            $this->helper->error_if_empty_tag($arg);
            $stag_info->tail_space = $etag_ifo->head_space = null;   // delete spaces
            $args = $this->builder->build_print_args($stag_info, $attr_info, $append_exprs);
            $flag_escape = ($d_name == 'cont' || $d_name == 'value') ? null : ($d_name == 'Cont' || $d_name == 'Value');
            $args[] = new KwartzNativeExpression($d_arg, $flag_escape);
            if ($etag_info->tagname) {
                $args[] = $etag_info->tag_text;
            }
            $stmt_list[] = new KwartzPrintStatement($args);
            break;

        case 'attr':
        case 'Attr':
        case 'ATTR':
            if (! preg_match($this->mapping_pattern(), $d_arg, $m)) {
                $msg = "'{$d_str}': invalid attr pattern.";
                throw $this->_error($msg, $stag_info->linenum);
            }
            $aname = $m[1];  $avalue = $m[2];
            $flag_escape = $d_name == 'attr' ? null : ($d_name == 'Attr');
            $attr_info->set_value($aname, new KwartzNativeExpression($avalue, $flag_escape));
            break;

        case 'append':
        case 'Append':
        case 'APPEND':
            $flag_escape = $d_name == 'append' ? null : ($d_name == 'Append');
            $arg->append_exprs[] = new KwartzNativeExpression($d_arg, $flag_escape);
            break;

        case 'replace_element_with_element':
        case 'replace_element_with_content':
        case 'replace_content_with_element':
        case 'replace_content_with_content':
            $replace_cont = preg_match('/^replace_content_/', $d_name);
            $with_content = preg_match('/_content$/', $d_name);
            $name = $d_arg;
            if ($replace_cont) {
                $this->helper->error_if_empty_tag($arg);
                $stmt_list[] = $this->helper->stag_stmt($arg);
            }
            if (array_key_exists($name, $this->_elem_info_table)) {
                $elem_info = $this->_elem_info_table[$name];
            } else {
                $msg = "'{$d_str}': element '{$name}' not found.";
                throw $this->_error($msg, $stag_info->linenum);
            }
            $this->expand_element_info($elem_info, $stmt_list, $with_content);
            if ($replace_cont) {
                $stmt_list[] = $this->helper->etag_stmt($arg);
            }
            break;

        case 'replace_element_with':
        case 'replace_content_with':
        case 'replace':
        case 'placeholder':
            if (! preg_match('/\A_?(element|content)\(["\']?(\w+)["\']?\)\z/', $d_arg, $m)) {
                $msg = "'{$d_str}': invalid {$d_name} format.";
                throw $this->_error($msg, $arg->stag_info->linenum);
            }
            $kind = $m[1];
            $name = $m[2];
            $replace_cont = $d_name == 'replace_content_with' || $d_name == 'placeholder';
            $with_content = $kind == 'content';
            //
            if ($replace_cont) {
                $this->helper->error_if_empty_tag($arg);
                $stmt_list[] = $this->helper->stag_stmt($arg);
            }
            $elem_info = kwartz_array_get($this->_elem_info_table, $name);
            if (! $elem_info) {
                $msg = "'{$d_str}': element '{$name}' not found.";
                throw $this->_error($msg, $arg->stag_info->linenum);
            }
            $this->expand_element_info($elem_info, $stmt_list, $with_content);
            if ($replace_cont) {
                $stmt_list[] = $this->helper->etag_stmt($arg);
            }
            break;

        default:
            return false;
        }

        return true;
    }


    function extract($elem_name, $content_only=false) {
        if (array_key_exists($elem_name, $this->_elem_info_table)) {
            $elem_info = $this->_elem_info_table[$elem_name];
        } else {
            $msg = "element '{$elem_name}' not found.";
            throw $this->_error($msg, null);
        }
        $stmt_list = array();
        $this->expand_element_info($elem_info, $stmt_list, $content_only);
        return $stmt_list;
    }


    /**
     *  expand ElementInfo
     */
    function expand_element_info($elem_info, &$stmt_list, $content_only=false) {
        $elem_ruleset = kwartz_array_get($this->_elem_ruleset_table, $elem_info->name);
        if ($elem_ruleset && ! $elem_info->merged) {
            $elem_info->merge($elem_ruleset);
        }
        if ($content_only) {
            $stmt = new KwartzExpandStatement('cont', $elem_info->name);
            $this->expand_statement($stmt, $stmt_list, $elem_info);
        } else {
            $logic = $elem_info->logic;
            if ($logic === null) {
                $logic = array(new KwartzExpandStatement('elem', $elem_info->name));
            }
            foreach ($logic as $stmt) {
                $this->expand_statement($stmt, $stmt_list, $elem_info);
            }
        }
    }


    function expand_statement($stmt, &$stmt_list, $elem_info) {
        if (! ($stmt instanceof KwartzExpandStatement)) {
            $stmt_list[] = $stmt;
            return;
        }

        $e = $elem_info;
        // delete dummy '<span>' tag
        if ($this->_delspan && $e->stag_info->tagname == 'span' && $e->attr_info->is_empty() && ! $e->append_exprs) {
            $e->stag_info->tagname = null;
            $e->etag_info->tagname = null;
        }

        switch ($stmt->kind) {
        case 'stag':
            if ($e->stag_expr) {
                assert('$e->stag_expr instanceof KwartzNativeExpression');
                $stmt_list[] = $this->builder->build_print_expr_stmt($e->stag_expr, $e->stag_info, null);
            } else {
                $stmt_list[] = $this->builder->build_print_stmt($e->stag_info, $e->attr_info, $e->append_exprs);
            }
            break;

        case 'etag':
            if ($e->etag_expr) {
                assert('$e->etag_expr instanceof KwartzNativeExpression');
                $stmt_list[] = $this->builder->build_print_expr_stmt($e->etag_expr, null, $e->etag_info);
            } elseif ($e->etag_info) { // e.etag_info is null when <br>,<input>,<hr>,<img>,<meta>
                $stmt_list[] = $this->builder->build_print_stmt($e->etag_info, null, null);
            }
            break;

        case 'cont':
            if ($e->cont_expr) {
                assert('$e->cont_expr instanceof KwartzNativeExpression');
                $stmt_list[] = new KwartzPrintStatement(array($e->cont_expr));
            } else {
                foreach ($elem_info->cont_stmts as $cont_stmt) {
                    $this->expand_statement($cont_stmt, $stmt_list, null);
                }
            }
            break;

        case 'elem':
            assert('$elem_info');
            if ($e->elem_expr) {
                assert('$e->elem_expr instanceof KwartzNativeExpression');
                $stmt_list[] = $this->builder->build_print_expr_stmt($e->elem_expr, $e->stag_info, $e->etag_info);
            } else {
                $stmt->kind = 'stag';
                $this->expand_statement($stmt, $stmt_list, $elem_info);
                $stmt->kind = 'cont';
                $this->expand_statement($stmt, $stmt_list, $elem_info);
                $stmt->kind = 'etag';
                $this->expand_statement($stmt, $stmt_list, $elem_info);
                $stmt->kind = 'elem';
            }
            break;

        case 'element':
        case 'content':
            $content_only = $stmt->kind == 'content';
            if (array_key_exists($stmt->name, $this->_elem_info_table)) {
                $elem_info = $this->_elem_info_table[$stmt->name];
            } else {
                $msg = "element '{$stmt->name}' is not found.";
                throw $this->_error($msg, null);
            }
            $this->expand_element_info($elem_info, $stmt_list, $content_only);
            break;

        default:
            assert(true);
        }
    }


}



/**
 *  dummy handler class for test
 */
class KwartzTestHandler extends KwartzHandler {


    /**
     *  directive pattern, which is used to detect directives.
     *  ex. '/\A(\w+):\s*(.*)/'
     */
    function directive_pattern() {
        return '/\A(\w+):\s*(.*)/';
    }


    /**
     *  mapping pattern, which is used to parse 'attr' directive.
     *  ex. '/\A\'([-:\w]+)\'\s+(.*)/'
     */
    function mapping_pattern() {
        return '/\A\'([-:\w]+)\'\s+(.*)/';
    }


    /**
     *  directive format, which is used at has_directive?() method.
     *  ex. '%s: %s'
     */
    function directive_format() {
        return '%s: %s';
    }


}



/**
 *  converter class
 */
abstract class KwartzConverter {

    var $handler;    // KwartzHandler

    function __construct($handler, $properties=array()) {
        $this->handler = $handler;
        $this->handler->converter = $this;
    }


    function _error($message, $linenum) {
        return new KwartzConvertionException($message, $this->filename, $linenum);
    }


    /**
     *  convert string into list of Statement.
     */
    abstract function convert($input, $filename='');


}



/**
 * convert presentation data (html) into a list of Statement.
 * notice that TextConverter class hanlde html file as text format, not html format.
 */
class KwartzTextConverter extends KwartzConverter {

    var $_dattr;      // string ('kw:d')
    var $_delspan;    // boolean (false)
    var $filename;    // string
    var $_linenum;    // integer
    var $_linenum_delta;   // integer
    var $_rest;       // string
    var $_fetch_list;    // list of list
    var $_fetch_index;
    var $_fetch_count;
    var $_skip_etag_table;
    var $_builder;


    function __construct($handler, $properties=array()) {
        parent::__construct($handler, $properties);
        $this->_dattr   = kwartz_array_get($properties, 'dattr',   KWARTZ_PROPERTY_DATTR);
        $this->_delspan = kwartz_array_get($properties, 'delspan', KWARTZ_PROPERTY_DELSPAN);
        $this->_skip_etag_table = array('input'=>true, 'img'=>true, 'br'=>true,
                                        'hr'=>true, 'meta'=>true, 'link'=>true);
        $this->_builder = new KwartzStatementBuilder();
    }


    /**
     *  called from convert() and initialize converter object
     */
    function _reset($pdata_str, $filename) {
        $this->filename = $filename;
        $this->handler->filename = $filename;
        $this->_linenum = 1;
        $this->_linenum_delta = 0;
        //
        $pattern = '/(.*?)((^[ \t]*)?<(\/?)([-:_\w]+)((?:\s+[-:_\w]+="[^"]*?")*)(\s*)(\/?)>([ \t]*\r?\n)?)/ms';
        preg_match_all($pattern, $pdata_str, $matched, PREG_SET_ORDER);
        $len = 0;
        foreach ($matched as $m)
            $len += strlen($m[0]);
        $this->_rest = substr($pdata_str, $len);
        $this->_fetch_list  = $matched;
        $this->_fetch_index = 0;
        $this->_fetch_count = count($this->_fetch_list);
    }


    /**
     *  convert presentation data string into list of statement
     */
    function convert($pdata_str, $filename='') {
        $this->_reset($pdata_str, $filename);
        $stmt_list = array();
        $doc_ruleset = $this->handler->get_element_ruleset('DOCUMENT');
        if ($doc_ruleset && $doc_ruleset->begin) {
            $stmt_list = array_merge($stmt_list, $doc_ruleset->begin);
        }
        $this->_convert($stmt_list);
        if ($doc_ruleset && $doc_ruleset->end) {
            $stmt_list = array_merge($stmt_list, $doc_ruleset->end);
        }
        return $stmt_list;
    }


    function _fetch() {
        if ($this->_fetch_index >= $this->_fetch_count) {
            return null;
        }
        $m = $this->_fetch_list[$this->_fetch_index++];
        $taginfo = new KwartzTagInfo($m);
        $this->_linenum += $this->_linenum_delta + substr_count($taginfo->prev_text, "\n");
        $this->_linenum_delta = substr_count($taginfo->tag_text, "\n");
        $taginfo->linenum = $this->_linenum;
        return $taginfo;
    }



    function _convert(&$stmt_list, $start_tag_info=null, $start_attr_info=null) {
        $start_tagname = $start_tag_info ? $start_tag_info->tagname : null;
        $start_linenum = $this->_linenum;
        //
        while ($taginfo = $this->_fetch()) {
            $prev_text = $taginfo->prev_text;
            if ($prev_text) {
                $stmt_list[] = $this->_builder->create_text_print_stmt($prev_text);
            }

            // end tag
            if ($taginfo->is_etag) {
                if ($taginfo->tagname == $start_tagname) {
                    $etag_info = $taginfo;
                    return $etag_info;
                } else {
                    $stmt_list[] = $this->_builder->create_text_print_stmt($taginfo->tag_text);
                }
            }

            // empty tag
            else if ($taginfo->is_empty || $this->_skip_etag_p($taginfo)) {
                $attr_info = new KwartzAttrInfo($taginfo->attr_str);
                if ($this->has_directive($attr_info, $taginfo)) {
                    $stag_info  = $taginfo;
                    $cont_stmts = array();
                    $etag_info  = null;
                    $this->handle_directive($stag_info, $etag_info, $cont_stmts, $attr_info, $stmt_list);
                } else {
                    $stmt_list[] = $this->_builder->create_text_print_stmt($taginfo->tag_text);
                }
            }

            // start tag
            else {
                $attr_info = new KwartzAttrInfo($taginfo->attr_str);
                if ($this->has_directive($attr_info, $taginfo)) {
                    $stag_info = $taginfo;
                    $cont_stmts = array();
                    $etag_info = $this->_convert($cont_stmts, $taginfo);
                    $this->handle_directive($stag_info, $etag_info, $cont_stmts, $attr_info, $stmt_list);
                } elseif ($taginfo->tagname == $start_tagname) {
                    $stag_info = $taginfo;
                    $stmt_list[] = $this->_builder->create_text_print_stmt($stag_info->tag_text);
                    $etag_info = $this->_convert($stmt_list, $stag_info);
                    $stmt_list[] = $this->_builder->create_text_print_stmt($etag_info->tag_text);
                } else {
                    $stmt_list[] = $this->_builder->create_text_print_stmt($taginfo->tag_text);
                }
            }
        }

        if ($start_tag_info) {
            $msg = "'<{$start_tagname}>' is not closed.";
            throw $this->_error($msg, $start_tag_info->linenum);
        }

        if ($this->_rest) {
            $stmt_list[] = $this->_builder->create_text_print_stmt($this->_rest);
        }
    }


    function handle_directive($stag_info, $etag_info, &$cont_stmts, $attr_info, &$stmt_list) {
        $directive_name = $directive_arg = $directive_str = null;
        $append_exprs = null;

        // handle 'attr:' and 'append:' directives
        $d_str = null;
        if ($attr_info->directive) {
            $list = preg_split('/;/', $attr_info->directive);
            foreach ($list as $d_str) {
                $d_str = trim($d_str);
                if (! preg_match($this->handler->directive_pattern(), $d_str, $m)) {
                    $msg = "'{$d_str}': invalid directive pattern.";
                    throw $this->_error($msg, $stag_info->linenum);
                }
                $d_name = $m[1];
                $d_arg  = count($m) > 2 ? $m[2] : null;   // kwartz_array_get($m, 2);
                switch ($d_name) {
                case 'attr':
                case 'Attr':
                case 'ATTR':
                    $handler_arg = new KwartzHandlerArgument($d_name, $d_arg, $d_str,
                        $stag_info, $etag_info, $cont_stmts, $attr_info, $append_exprs);
                    $this->handler->handle($handler_arg, $stmt_list);
                    break;
                case 'append':
                case 'Append':
                case 'APPEND':
                    if ($append_exprs === null)
                        $append_exprs = array();
                    $handler_arg = new KwartzHandlerArgument($d_name, $d_arg, $d_str,
                        $stag_info, $etag_info, $cont_stmts, $attr_info, $append_exprs);
                    $this->handler->handle($handler_arg, $stmt_list);
                    break;
                default:
                    if ($directive_name) {
                        $msg = "'{$d_str}': not available with '{$directive_name}' direcitve.";
                        throw $this->_error($msg, $stag_info->linenum);
                    }
                    $directive_name = $d_name;
                    $directive_arg  = $d_arg;
                    $directive_str  = $d_str;
                }//switch
            }//foreach
        }//if

        // remove dummy <span> tag
        if ($this->_delspan && $stag_info->tagname == 'span'
            && $attr_info->is_empty() && ! $append_exprs && $directive_name != 'id') {
            $stag_info->tagname = null;
            $etag_info->tagname = null;
        }

        // handle other directives
        $handler_arg = new KwartzHandlerArgument($directive_name, $directive_arg, $directive_str,
                        $stag_info, $etag_info, $cont_stmts, $attr_info, $append_exprs);
        $ret = $this->handler->handle($handler_arg, $stmt_list);
        if ($directive_name && !$ret) {
            $msg = "'{$directive_str}': unknown directive.";
            throw $this->_error($msg, $stag_info->linenum);
        }
    }


    /**
     *  detect whether directive is exist or not
     */
    function has_directive($attr_info, $taginfo) {
        // kw:d attribute
        $val = $attr_info->get_value($this->_dattr);    // ex. _dattr == 'kw:d'
        if ($val && is_string($val)) {
            if ($val[0] == ' ') {
                $val = substr($val, 1);  // delete a space
                $attr_info->set_value($this->_dattr, $val);
                $taginfo->rebuild_tag_text($attr_info);
                //return false;
            } elseif (preg_match($this->handler->directive_pattern(), $val)) {
                $attr_info->delete($this->_dattr);
                $attr_info->directive = $val;
                return true;
            } else {
                $msg = "'{$this->_dattr}=\"{$val}\"': invalid directive pattern.";
                throw $this->_error($msg, $taginfo->linenum);
            }
        }
        // id attribute
        $val = $attr_info->get_value('id');
        if ($val) {
            if (preg_match('/\A\w+\z/', $val)) {
                $attr_info->directive = sprintf($this->handler->directive_format(), 'mark', $val);
                return true;
            } elseif (preg_match('/\A(mark|dummy):(\w+)\z/', $val, $m) ||
                      preg_match('/\A(replace_(?:element|content)_with_(?:element|content)):(\w+)\z/', $val, $m)) {
                $attr_info->directive = sprintf($this->handler->directive_format(), $m[1], $m[2]);
                $attr_info->delete('id');
                return true;
            }
        }
        return false;
    }


    function _skip_etag_p($taginfo) {
        return array_key_exists($taginfo->tagname, $this->_skip_etag_table);
    }

}


?>