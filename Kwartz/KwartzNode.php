<?php
// vim: set expandtab tabstop=4 shiftwidth=4 softtabstop=4:

// $Rev$
// $Release$
// $Copyright$


require_once 'Kwartz/KwartzUtility.php';


abstract class KwartzNode {


    /**
     *  accept visitor
     */
    abstract function accept($translator);


}



/**
 *  expression class
 */
abstract class KwartzExpression extends KwartzNode {
}



/**
 *  represents expression in target language code
 */
class KwartzNativeExpression extends KwartzExpression {


    var $code;         // string
    var $escape;       // boolean


    function __construct($code, $flag_escape=null) {
        $this->code = $code;
        if ($flag_escape !== null) {
            $this->escape = $flag_escape;
        }
    }


    function _inspect($depth=0) {
        return '<%=' . $this->code . '%>';
    }


    function accept($translator) {
        $translator->translate_native_expr($this);
    }


}


/**
 *  statement class
 */
abstract class KwartzStatement extends KwartzNode {
}



/**
 *  represents statement in target language code
 */
class KwartzNativeStatement extends KwartzStatement {


    var $code;         // string
    var $kind;         // string
    var $no_newline;   // boolean


    function __construct($code, $kind=null) {
        $this->code = $code;
        $this->kind = $kind;
    }


    static function new_without_newline($code, $kind=null) {
        $stmt = new KwartzNativeStatement($code, $kind);
        $stmt->no_newline = true;
        return $stmt;
    }


    function _inspect($depth=0) {
        return str_repeat(' ', $depth) . '<%' . $this->code . "%>\n";
    }


    function accept($translator) {
        $translator->translate_native_stmt($this);
    }


}



/**
 *  represents _stag, _cont, _etag, _elem, _element(name), and _content(name)
 */
class KwartzExpandStatement extends KwartzStatement {


    var $kind;    // string ('stag', 'cont', 'etag', 'elem', 'element', 'content')
    var $name;    // string


    function __construct($kind, $name) {
        $this->kind = $kind;
        $this->name = $name;
    }


    function _inspect($depth=0) {
        if ($this->kind == 'element' || $this->kind == 'content') {
            return "_{$this->kind}($this->name)\n";
        } else {
            return "_{$this->kind}\n";
        }
    }


    function accept($translator) {
        assert(true);
    }


}



/**
 * represents print statement for String and NativeExpression
 */
class KwartzPrintStatement extends KwartzStatement {


    var $args;     // list of expression or string


    function __construct($args) {
        $this->args = $args;
    }


    function _inspect($depth=0) {
        $list = array();
        $list[] = str_repeat(' ', $depth);
        $list[] = 'print(';
        foreach ($this->args as $arg) {
            if (is_string($arg)) {
                $list[] = kwartz_inspect_str($arg);
            } else {
                assert('$arg instanceof KwartzNativeExpression');
                $list[] = $arg->_inspect();
            }
        }
        $list[] = ")\n";
        return join($list);
        //$space = str_repeat(' ', $depth);
        //$list = array($space . "- print");
        //foreach ($this->args as $arg) {
        //    if (is_string($arg)) {
        //        $list[] = $space . "  - " . kwartz_inspect_str($arg);
        //    } else {
        //        assert('$arg instanceof KwartzNativeExpression');
        //        $list[] = $space . "  - {$arg->code}";
        //    }
        //}
        //$list[] = '';
        //return join($list, "\n") ;
    }


    function accept($translator) {
        $translator->translate_print_stmt($this);
    }


}



/**
 *  ruleset entry in presentation logic file
 */
abstract class KwartzRuleset {
}



/**
 *  represents '#name { ... }' entry in presentation logic file
 */
class KwartzElementRuleset extends KwartzRuleset {


    var $name;    // KwartzNativeExpression
    var $stag;    // KwartzNativeExpression
    var $cont;    // KwartzNativeExpression
    var $etag;    // KwartzNativeExpression
    var $elem;    // KwartzNativeExpression
    var $value;   // KwartzNativeExpression
    var $attrs;     // hash of string=>KwartzNativeExpression
    var $append;    // list of KwartzNativeExpression
    var $remove;    // list of string
    var $tagname;   // string
    var $logic;     // list of KwartzStatement

    var $filename;


    function __construct($name, $filename=null) {
        $this->name = $name;
        $this->filename = $filename;
    }


    function set_properties($hash) {
        $keys = array('stag', 'cont', 'etag', 'elem', 'value', 'attrs', 'append');
        foreach ($keys as $key) {
            $method = 'set_' . $key;
            if (array_key_exists($key, $hash)) $this->$method($hash[$key], null);
            $key = ucfirst($key);
            if (array_key_exists($key, $hash)) $this->$method($hash[$key], false);
            $key = strtoupper($key);
            if (array_key_exists($key, $hash)) $this->$method($hash[$key], true);
        }
        $keys = array('remove', 'tagname', 'logic');
        foreach ($keys as $key) {
            $method = 'set_' . $key;
            if (array_key_exists($key, $hash)) $this->$method($hash[$key]);
        }
    }


    function set_stag($str, $flag_escape=null) {
        $this->stag = new KwartzNativeExpression($str, $flag_escape);
    }


    function set_cont($str, $flag_escape=null) {
        $this->cont = new KwartzNativeExpression($str, $flag_escape);
    }


    function set_etag($str, $flag_escape=null) {
        $this->etag = new KwartzNativeExpression($str, $flag_escape);
    }


    function set_elem($str, $flag_escape=null) {
        $this->elem = new KwartzNativeExpression($str, $flag_escape);
    }


    function set_value($str, $flag_escape=null) {
        $this->set_cont($str, $flag_escape);
    }


    function set_attrs($hash, $flag_escape=null) {
        if ($hash) {
            foreach ($hash as $name => $code) {
                if ($code) {
                    $this->attrs[$name] = new KwartzNativeExpression($code, $flag_escape);
                }
            }
        }
    }


    function set_append($list, $flag_escape=null) {
        foreach ($list as $code) {
            if ($code) {
                $this->append[] = new KwartzNativeExpression($code, $flag_escape);
            }
        }
    }


    function set_remove($list) {
        if ($list) {
            $this->remove = $list;
        }
    }


    function set_tagname($name) {
        if ($name) {
            $this->tagname = $name;
        }
    }


    function set_logic($code) {
        if (! $code) return;
        $stmt_list = array();
        $lines = preg_split('/\n/', $code);
        if (! $lines[count($lines) - 1]) {
            array_pop($lines);
        }
        foreach ($lines as $line) {
            if (preg_match('/^\s*_(stag|cont|etag|elem)(?:\(\))?;?\s*(?:\/\/.*)?$/', $line, $m)) {
                $kind = $m[1];
                $stmt_list[] = new KwartzExpandStatement($kind, $this->name);
            }
            elseif (preg_match('/^\s*(_(element|content)([()\'"\w\s]*));?\s*(?:\/\/.*)?$/', $line, $m)) {
                $str = $m[1];  $kind = $m[2];  $arg = trim($m[3]);
                if (preg_match('/\A\((.*)\)\z/', $arg, $m)) {
                    $arg = $m[1];
                }
                if (! $arg) {
                    $msg = "'{$str}': element name required.";
                    throw $this->_error($msg, null);
                }
                if (preg_match('/\A\w+\z/', $arg)) {
                    $name = $arg;
                } elseif (preg_match('/\A"(\w+)"\z/', $arg, $m)) {
                    $name = $m[1];
                } elseif (preg_match('/\A\'(\w+)\'\z/', $arg, $m)) {
                    $name = $m[1];
                } else {
                    $msg = "'{$str}': invalid name or pattern.";
                    throw $this->_error($msg, null);
                }
                $stmt_list[] = new KwartzExpandStatement($kind, $name);
            }
            elseif (preg_match('/\A\s*print(?:\s+(.*?)|\((.+)\))\s*;?\s*\z/', $line, $m)) {
                $arg = $m[1] ? $m[1] : $m[2];
                $args = array(new KwartzNativeExpression($arg));
                $stmt_list[] = new KwartzPrintStatement($args);
            }
            else {
                $stmt_list[] = new KwartzNativeStatement($line, null);
            }
        }
        $this->logic = $stmt_list;
    }


    function _inspect($depth=0) {
        $space = str_repeat('  ', $depth);
        $sb = array();
        $sb[] = '';
        if ($this->name) $sb[] = $space . "- name: {$this->name}\n";
        if ($this->stag) $sb[] = $space . "  stag: {$this->stag->code}\n";
        if ($this->cont) $sb[] = $space . "  cont: {$this->cont->code}\n";
        if ($this->etag) $sb[] = $space . "  etag: {$this->etag->code}\n";
        if ($this->elem) $sb[] = $space . "  elem: {$this->elem->code}\n";
        if ($this->attrs) {
            $sb[] = $space . "  attrs:\n";
            ksort($this->attrs);
            foreach ($this->attrs as $name => $expr) {
                $sb[] = $space . "    - name:  {$name}\n";
                $sb[] = $space . "      value: {$expr->code}\n";
            }
        }
        if ($this->append) {
            $sb[] = $space . "  append:\n";
            foreach ($this->append as $expr) {
                $sb[] = $space . "    - {$expr->code}\n";
            }
        }
        if ($this->remove) {
            $sb[] = $space . "  remove:\n";
            foreach ($this->remove as $name) {
                $sb[] = $space . "    - {$name}\n";
            }
        }
        if ($this->tagname) {
            $sb[] = $space . "  tagname: {$this->tagname}\n";
        }
        if ($this->logic) {
            $sb[] = $space . "  logic:\n";
            foreach ($this->logic as $stmt) {
                $sb[] = $space . "    - " . $stmt->_inspect();
            }
        }
        return join($sb);
    }


    function _error($message, $linenum) {
        return new KwartzParseException($message, $this->filename, $linenum);
    }


}



/**
 *  represents '#DOUMENT { ... }' entry in presentation logic file
 */
class KwartzDocumentRuleset extends KwartzRuleset {

    var $name;
    var $_global;
    var $_local;
    var $fixture;
    var $begin;
    var $end;

    var $filename;


    function __construct($filename=null) {
        $this->name = 'DOCUMENT';
        $this->filename = $filename;
    }


    function set_global($list) {
        $this->_global = $list;
    }

    function set_local($list) {
        $this->_local = $list;
    }

    function set_fixture($code) {
        $this->fixture = new KwartzNativeStatement($code, null);
    }


    function set_begin($code) {
        $stmt_list = $this->_parse_code($code);
        $this->begin = $stmt_list;
    }


    function set_end($code) {
        $stmt_list = $this->_parse_code($code);
        $this->end = $stmt_list;
    }


    function _parse_code($code) {
        if (! $code) return;
        $stmt_list = array();
        $lines = preg_split('/\n/', $code);
        if (! $lines[count($lines) - 1]) {
            array_pop($lines);
        }
        foreach ($lines as $line) {
            if (preg_match('/^\s*print(?:\s+(.*?)|\((.+)\))\s*;?\s*$/', $line, $m)) {
                $arg = $m[1] ? $m[1] : $m[2];
                $args = array(new KwartzNativeExpression($arg));
                $stmt_list[] = new KwartzPrintStatement($args);
            } else {
                $stmt_list[] = new KwartzNativeStatement($line, null);
            }
        }
        return $stmt_list;
    }


    function _inspect($depth=0) {
        $space = str_repeat('  ', $depth);
        $sb = array();
        $sb[] = '';
        $sb[] = $space . "- name: {$this->name}\n";
        if ($this->_global) {
            $sb[] = $space . "  global:\n";
            foreach ($this->_global as $item) {
                $sb[] = $space . "    - {$item}\n";
            }
        }
        if ($this->_local) {
            $sb[] = $space . "  local:\n";
            foreach ($this->_local as $item) {
                $sb[] = $space . "    - {$item}\n";
            }
        }
        if ($this->begin) {
            $sb[] = $space . "  begin:\n";
            foreach ($this->begin as $stmt) {
                $sb[] = $space . "    - {$stmt->_inspect()}";
            }
        }
        if ($this->end) {
            $sb[] = $space . "  end:\n";
            foreach ($this->end as $stmt) {
                $sb[] = $space . "    - {$stmt->_inspect()}";
            }
        }
        return join($sb);
    }


}

?>