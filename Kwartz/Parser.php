<?php
// vim: set expandtab tabstop=4 shiftwidth=4 softtabstop=4:

// $Rev$
// $Release$
// $Copyright$


require_once('Kwartz/Exception.php');
require_once('Kwartz/Node.php');
require_once('Kwartz/Utility.php');


class KwartzParseException extends KwartzBaseException {


    var $column;


    function __construct($message, $filename, $linenum, $column) {
        parent::__construct($message, $filename, $linenum);
        $this->column = $column;
    }


    function __toString() {
        $mesg = $this->getMessage();
        return "{$this->filename}:{$this->linenum}:{$this->column}: {$mesg}";
    }


}



/**
 *  parser class for presentation logic
 */
abstract class KwartzPresentationLogicParser {


    var $properties;

    var $_input;
    var $filename;
    var $linenum;
    var $column;
    var $_pos;
    var $_max_pos;
    var $token;
    var $value;
    var $error;
    var $_ch;

    var $_keywords;


    function __construct($properties=array()) {
        $this->properties = $properties;
        $this->_keywords = KwartzPresentationLogicParser::_get_keyword_table();
        $this->_escapes  = KwartzPresentationLogicParser::_get_escape_table();
    }


    /**
     *  called from parse() and initialize parser object
     */
    function _reset($plogic_str, $filename=null) {
        $this->_input   = $plogic_str;
        $this->filename = $filename;
        $this->linenum = 1;       // 1 start
        $this->column  = 0;       // 1 start
        $this->_pos     = -1;      // 0 start
        $this->_max_pos = strlen($plogic_str) - 1;
        $this->token    = null;
        $this->value    = null;
        $this->error    = null;
        $this->_ch      = null;
        $this->_getch();
    }


    static $_keyword_table;
    static function _get_keyword_table() {
        if (! self::$_keyword_table) {
            $list = array(
                'stag', 'Stag', 'STAG', 'cont', 'Cont', 'CONT', 'etag', 'Etag', 'ETAG',
                'elem', 'Elem', 'ELEM', 'value', 'Value', 'VALUE',
                'attrs', 'Attrs', 'ATTRS', 'append', 'Append', 'APPEND',
                'element', 'remove', 'tagname', 'logic',
                'document', 'global', 'local', 'fixture', 'before', 'after'
                );
            foreach ($list as $keyword) {
                self::$_keyword_table[$keyword] = strtolower($keyword);
            }
        }
        return self::$_keyword_table;
    }


    static $_escape_table;
    static function _get_escape_table() {
        if (! self::$_escape_table) {
            $list = array('stag', 'cont', 'etag', 'elem', 'value', 'attrs', 'append');
            foreach ($list as $keyword) {
                self::$_escape_table[$keyword]             = null;   // ex. value
                self::$_escape_table[ucfirst($keyword)]    = true;   // ex. Value
                self::$_escape_table[strtoupper($keyword)] = false;  // ex. VALUE
            }
        }
        return self::$_escape_table;
    }


    function _getch() {
        if ($this->_pos >= $this->_max_pos) {
            return $this->_ch = null;
        }
        if ($this->_ch == "\n") {
            $this->linenum += 1;
            $this->column = 0;
        }
        $this->_pos += 1;
        $this->column += 1;
        $this->_ch = $this->_input[$this->_pos];
        return $this->_ch;
    }


    function _scan_ident() {
        $ch = $this->_ch;
        if (ctype_alpha($ch) || $ch == '_') {
            $sb = $ch;
            while (($ch = $this->_getch()) !== null && (ctype_alnum($ch) || $ch == '_')) {
                $sb .= $ch;
            }
            $this->value = $sb;
            return $this->token = ':ident';
        }
        return null;
    }


    function scan_string_dquoted() {
        if ($this->_ch != '"') return null;
        $sb = '';
        while (($ch = $this->_getch()) !== null && $ch != '"') {
            if ($ch == '\\') {
                $ch = $this->_getch();
                if ($ch === null) break;
                switch ($ch) {
                case 'n':   $sb .= "\n";  break;
                case 't':   $sb .= "\t";  break;
                case 'r':   $sb .= "\r";  break;
                case 'b':   $sb .= "\b";  break;
                case '\\':  $sb .= "\\";  break;
                case '"':   $sb .= '"';   break;
                default:    $sb .= $ch;
                }
            } else {
                $sb .= $ch;
            }
        }
        if ($ch === null) {
            $this->_error = ':string_unclosed';
            return $this->token = ':error';
        }
        assert('$ch == \'"\'');
        $this->_getch();
        $this->value = $sb;
        return $this->token = ':string';
    }


    function scan_string() {
        if ($this->_ch == "'") {
            return $this->scan_string_quoted();
        } elseif ($this->_ch == '"') {
            return $this->scan_string_dquoted();
        } else {
            return null;
        }
    }


    function scan_string_quoted() {
        if ($this->_ch != "'") {
            return null;
        }
        $sb = '';
        while (($ch = $this->_getch()) !== null && $ch != "'") {
            if ($ch == '\\') {
                $ch = $this->_getch();
                if ($ch === null) break;
                switch ($ch) {
                case '\\':   $sb .= '\\';  break;
                case "'":    $sb .= "'";   break;
                default:     $sb .= '\\' + $ch;
                }
            } else {
                $sb .= $ch;
            }
        }
        if ($ch === null) {
            $this->error = ':string_unclosed';
            return $this->token = ':error';
        }
        $this->_getch();
        $this->value = $sb;
        return $this->token = ':string';
    }


    /**
     *  called from scan() , return false when not hooked
     */
    abstract function scan_hook();


    /**
     *  detect parser-specific keywords
     *
     *  return symbol if keyword is token, else return nil
     */
    abstract function keywords($keyword);


    /**
     *  scan token
     */
    function scan() {
        // skip whitespace
        $c = $this->_ch;
        while (ctype_space($c)) {
            $c = $this->_getch();
        }

        // return null when EOF
        if ($c == null) {
            $this->value = null;
            return $this->token = null;
        }

        // scan hook
        $ret = $this->scan_hook();  // scan_hook() is overrided in subclass
        if ($ret !== false) return $ret;

        // keyword or identifier
        if (ctype_alpha($c) || $c == '_') {
            $this->_scan_ident();
            $v = $this->value;
            if (($t = $this->keywords($v)) !== null) {
                return $this->token = $t;
            } elseif (array_key_exists($v, $this->_keywords)) {
                return $this->token = $this->_keywords[$v];
            } else {
                return $this->token = ':ident';
            }
        }

        // "string"
        if ($c == '"') {
            return $this->_scan_string_dquoted();
        }

        // 'string'
        if ($c == "'") {
            return $this->_scan_string_quoted();
        }

        // '{', '}', ','
        if ($c == '{' || $c == '}' || $c == ',') {
            $this->value = $c;
            $this->_getch();
            return $this->token = $c;
        }

        // invalid char
        $this->value = $c;
        $this->error = ':invalid_char';
        return $this->token = ':error';
    }


    function scan_block($skip_open_curly=fase) {
        if (! $skip_open_curly) {
            $t = $this->scan();
            if ($t != '{') {
                $this->error = ':block_notfound';
                $this->token = ':error';
            }
        }
        $start_pos = $this->_pos;
        $count = 1;
        while (($c = $this->_getch()) !== null) {
            if ($c == '{') {
                $count++;
            } elseif ($c == '}') {
                $count--;
                if ($count == 0) break;
            }
        }
        if ($c === null) {
            $this->error = ':block_unclosed';
            return $this->token = ':error';
        }
        assert('$c == "}"');
        $this->value = substr($this->_input, $start_pos, $this->_pos - $start_pos);
        $this->token = ':block';
        $this->_getch();
        return $this->value;
    }


    function _scan_line() {
        $sb = $this->_ch;
        while (($c = $this->_getch()) !== null && $c != "\n") {
            $sb .= $c;
        }
        $sb = rtrim($sb, "\r");
        $this->_getch();
        return $sb;
    }


    // parser

    function _error($message, $linenum=null, $column=null) {
        if ($linenum === null) $linenum = $this->linenum;
        if ($column === null)  $column = $this->column;
        return new KwartzParseException($message, $this->filename, $linenum, $column);
    }


    /**
     *  parse input string and return list of ElementRuleset
     */
    abstract function parse($plogic_str, $filename='');


    function _parse_block() {
        $this->scan();
        if ($this->token != '{') {
            throw $this->_error("'{$this->value}': '{' expected.");
        }
        $start_linenum = $this->linenum;
        $start_column = $this->column;
        $t = $this->scan_block(true);
        if ($t == ':error') {
            assert('$this->error == ":block_unclosed"');
            throw $this->_error("'{': not closed by '}'.", $start_linenum, $start_column);
        }
        $v = preg_replace('/\A\s*\n/', '', $this->value);
        $v = preg_replace('/[ \t]+\z/', '', $v);
        return $this->value = $v;
    }


}



/**
 * css style presentation logic parser
 *
 * example of presentation logic in css style:
 *
 *   // comment
 *   #list {
 *     value:   $var;
 *     attrs:   "class" $classname, "bgcolro" $color;
 *     append:  $value==$item['list'] ? ' checked' : '';
 *     logic:   {
 *       foreach ($list as $item) {
 *         _stag();
 *         _cont();
 *         _etag();
 *       }
 *     }
 *   }
 */
class KwartzCssStyleParser extends KwartzPresentationLogicParser {


    function parse($plogic_str, $filename='') {
        $this->_reset($plogic_str, $filename);
        $this->scan();
        $rulesets = array();
        while ($this->token == '@') {
            $c = $this->_getch();
            $this->_scan_ident();
            $name = $this->value;
            if ($name == 'import') {
                $imported_rulesets = $this->parse_import_command();
                $rulesets = array_merge($rulesets, $imported_rulesets);
            } else {
                throw $this->_error("@#{name}: unsupported command.");
            }
        }
        while ($this->token == '#') {
            $this->_scan_ident();
            $name = $this->value;
            if ($name == 'DOCUMENT') {
                $rulesets[] = $this->parse_document_ruleset();
            } else {
                $rsets = $this->parse_element_ruleset();
                $rulesets = array_merge($rulesets, $rsets);
            }
        }
        if ($this->token !== null) {
            throw $this->_error("'{$this->value}': '#name' is expected.");
        }
        return $rulesets;
    }


    /**
     *  return false when not hooked
     */
    function scan_hook() {
        // comment
        $c = $this->_ch;
        if ($c == '/') {
            $c = $this->_getch();
            if ($c == '/') {    // line comment
                $this->_scan_line();
                $this->_getch();
                return $this->scan();
            }
            elseif ($c == '*') {  // region comment
                $start_linenum = $this->linenum;
                while (true) {
                    do {
                        $c = $this->_getch();
                    } while ($c != '*');
                    if ($c === null) break;
                    $c = $this->_getch();
                    if ($c == '/') break;
                }
                if ($c === null) {
                    $this->error = ':comment_unclosed';
                    $this->value = $start_linenum;
                    return $this->token = ':error';
                }
                $this->_getch();
                return $this->scan();
            }
            else {
                $this->value = '/';
                return $this->token = '/';
            }
        }

        // selector
        if ($c == '#') {
            $c = $this->_getch();
            if (! ctype_alpha($c)) {
                $this->error = ':invalid_char';
                $this->value = '#';
                return $this->token = ':error';
            }
            $this->value = '#';
            return $this->token = '#';
        }

        // @import "foo.plogic"
        if ($c == '@') {
            $this->value = '@';
            return $this->token = '@';
        }

        return false;
    }


    function keywords($keyword) {
        return $keyword == 'begin' || $keyword == 'end' ? $keyword : null;
    }


    function parse_document_ruleset() {
        assert('$this->value == "DOCUMENT"');
        $start_linenum = $this->linenum;
        $this->scan();
        if ($this->token != '{') {
            throw $this->_error("'{$this->value}': '{' is expected.");
        }
        $ruleset = new KwartzDocumentRuleset($this->filename);
        while ($this->token !== null) {
            $this->scan();
            $t = $this->token;
            if ($t == '}') {
                break;
            } elseif ($t == 'global') {
                $this->_has_colon();
                $ruleset->set_global($this->_parse_words());
            } elseif ($t == 'local') {
                $this->_has_colon();
                $ruleset->set_local($this->_parse_words());
            } elseif ($t == 'fixture') {
                $this->_has_colon();
                $ruleset->set_fixture($this->_parse_block());
            } elseif ($t == 'begin') {
                $this->_has_colon();
                $ruleset->set_begin($this->_parse_block());
            } elseif ($t == 'end') {
                $this->_has_colon();
                $ruleset->set_end($this->_parse_block());
            } else {
                if ($this->token === null) {
                    throw $this->_error("'#DOCUMENT': is not closed by '}'.", $start_linenum);
                } else {
                    throw $this->_error("'{$this->value}': unexpected token.");
                }
            }
        }
        assert('$this->token == "}"');
        $this->scan();
        return $ruleset;
    }


    function _has_colon() {
        if ($this->_ch != ':') {
            throw $this->_error("'{$this->value}': ':' is required.");
        }
        $this->_getch();
    }


    function parse_element_ruleset() {
        assert('$this->token == ":ident"');
        $start_linenum = $this->linenum;
        $name = $this->value;
        $names = array($name);
        $this->scan();
        while ($this->token == ',') {
            $this->scan();
            if ($this->token != '#') {
                throw $this->_error("'{$this->value}': '#name' is expected.");
            }
            $this->_scan_ident();
            $names[] = $this->value;
            $this->scan();
        }
        if ($this->token != '{') {
            throw $this->_error("'{$this->value}': '{' is expected.");
        }
        // parse properties
        $props = array();  // hash
        while (true) {
            $this->scan();
            $t = $this->token;
            $v = $this->value;
            $flag_escape = kwartz_array_get($this->_escapes, $v);
            if ($t === null || $t == '}') break;
            switch ($t) {
            case 'stag':
            case 'cont':
            case 'etag':
            case 'elem':
            case 'value':
                $this->_has_colon();
                $props[$v] = $this->_parse_expr();
                break;
            case 'attrs':
                $this->_has_colon();
                $props[$v] = $this->_parse_pairs();
                break;
            case 'append':
                $this->_has_colon();
                $props[$v] = $this->_parse_exprs();
                break;
            case 'remove':
                $this->_has_colon();
                $props[$v] = $this->_parse_strs();
                break;
            case 'tagname':
                $this->_has_colon();
                $props[$v] = $this->_parse_str();
                break;
            case 'logic':
                $this->_has_colon();
                $props[$v] = $this->_parse_block();
                break;
            default:
                throw $this->_error("'{$this->value}': unexpected token.");
            }
        }
        if ($this->token === null) {
            $msg = "'#{$name}': is not closed by '}'.";
            throw $this->_error($msg, $start_linenum);
        }
        assert('$this->token == "}"');
        $this->scan();
        //
        $rulesets = array();
        foreach ($names as $name) {
            $ruleset = new KwartzElementRuleset($name);
            $ruleset->set_properties($props);
            $rulesets[] = $ruleset;
        }
        return $rulesets;
    }


    function parse_import_command() {
        $c = $this->_ch;
        while (ctype_space($c)) {
            $c = $this->_getch();
        }
        $this->scan_string();
        if ($this->token != ':string') {
            throw $this->_error("@import: requires filename.");
        }
        $filename = $this->value;
        if (! file_exists($filename)) {
            $msg = "'{$filename}': import file not found.";
            throw $this->_error($msg);
        }
        $c = $this->_ch;
        while ($c !== null && ctype_space($c)) {
            $c = $this->_getch();
        }
        if ($c != ';') {
            throw $this->_error("';' required.");
        }
        $c = $this->_getch();
        $this->scan();
        $parser = $this->create_parser($this->properties);
        $ruleset_list = $parser->parse(file_get_contents($filename), $filename);
        return $ruleset_list;
    }


    function create_parser($properties=array()) {
        return new KwartzCssStyleParser($properties);
    }


    function _parse_expr() {
        $expr = '';
        while (true) {
            $line = $this->_scan_line();
            if ($line === null || ! preg_match('/(.*)([,;])[ \t]*(?:\/\/.*)?$/', $line, $m)) {
                throw $this->_error("'{$this->token}:': ';' is required.");
            }
            $expr .= $m[1];
            $indicator = $m[2];
            if ($indicator == ';') break;
            $expr .= ",\n";
        }
        return trim($expr);
    }


    function _parse_pairs() {
        $hash = array();
        while (true) {
            $line = $this->_scan_line();
            if ($line === null || ! preg_match('/(.*)([,;])[ \t]*(\/\/.*)?$/', $line, $m)) {
                throw $this->_error("'{$this->token}:': ';' is required.");
            }
            $str = $m[1];
            $indicator = $m[2];
            if (   preg_match('/\A\s*"([-:\w]+)"\s+(.*)/', $str, $m)
                || preg_match('/\A\s*\'([-:\w]+)\'\s+(.*)/', $str, $m)) {
                $aname = $m[1];  $avalue = $m[2];
            } else {
                throw $this->_error("'{$this->token}': invalid mapping pattern.");
            }
            $hash[$aname] = $avalue;
            if ($indicator == ';') break;
        }
        return $hash;
    }


    function _parse_words() {
        $list = array();
        while (true) {
            $line = $this->_scan_line();
            if ($line === null || ! preg_match('/(.*)([,;])[ \t]*(\/\/.*)?$/', $line, $m)) {
                throw $this->_error("'{$this->token}:': ';' is required.");
            }
            $str = $m[1];
            $indicator = $m[2];
            $words = preg_split('/,/', $str);
            foreach ($words as $word) {
                $list[] = trim($word);
            }
            if ($indicator == ';') break;
        }
        return $list;
    }


    function _parse_exprs() {
        $list = array();
        while (true) {
            $line = $this->_scan_line();
            if ($line === null || ! preg_match('/(.*)([,;])[ \t]*(\/\/.*)?$/', $line, $m)) {
                throw $this->_error("'{$this->token}:': ';' is required.");
            }
            $expr = $m[1];
            $indicator = $m[2];
            $list[] = trim($expr);
            if ($indicator == ';') break;
        }
        return $list;
    }


    function _parse_strs() {
        $list = array();
        while (true) {
            $line = $this->_scan_line();
            if ($line === null || ! preg_match('/(.*)([,;])[ \t]*(\/\/.*)?$/', $line, $m)) {
                throw $this->_error("'{$this->token}': ';' is required.");
            }
            $str = $m[1];
            $indicator = $m[2];
            $strs = preg_split('/,/', $str);
            foreach ($strs as $s) {
                $s = trim($s);
                if (preg_match('/\A\'(.*)\'\z/', $s, $m)) {
                    $list[] = $m[1];
                } elseif (preg_match('/\A"(.*)"\z/', $s, $m)) {
                    $list[] = $m[1];
                } else {
                    throw $this->_error("'{$this->token}': string list is expected.");
                }
            }
            if ($indicator == ';') break;
        }
        return $list;
    }


    function _parse_str() {
        $strs = $this->_parse_strs();
        return $strs[0];
    }


    function _parse_block() {
        return parent::_parse_block();
    }


}
