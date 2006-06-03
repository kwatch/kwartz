<?php
// vim: set expandtab tabstop=4 shiftwidth=4 softtabstop=4:

// $Rev$
// $Release$
// $Copyright$



/**
 *  directive handler for PHP
 */
class KwartzPhpHandler extends KwartzHandler {


    function directive_pattern() {
        return '/\A(\w+)(?:\s*\(\s*(.*)\))?\z/';
    }


    function mapping_pattern() {
        return '/\A\'([-:\w]+)\',\s*(.*)\z/';
    }


    function directive_format() {
        return '%s(%s)';
    }


    function handle($directive_name, $directive_arg, $directive_str,
                    $stag_info, $etag_info, $cont_stmts,
                    $attr_info, $append_exprs, &$stmt_list) {

        $ret = parent::handle($directive_name, $directive_arg, $directive_str,
                              $stag_info, $etag_info, $cont_stmts,
                              $attr_info, $append_exprs, $stmt_list);
        if ($ret) return $ret;

        $d_name = $directive_name;
        $d_arg  = $directive_arg;
        $d_str  = $directive_str;

        $b = $this->builder;
        $stag_stmt = $b->build_print_stmt($stag_info, $attr_info, $append_exprs);
        $etag_stmt = $b->build_print_stmt($etag_info, null, null);

        switch ($d_name) {
        case 'foreach':
        case 'Foreach':
        case 'FOREACH':
        case 'LIST':
        case 'List':
        case 'LIST':
            $is_foreach = strlen($d_name) == 7;
            if (! preg_match('/\A.*\s+as\s+(\$\w+)(?:\s*=>\s*\$\w+)?\z/', $d_arg, $m)) {
                throw $this->_error("'{$d_str}': invalid argument.", $stag_info->linenum);
            }
            $loopvar = $m[1];
            $counter = $d_name == 'foreach' || $d_name == 'list' ? null : "{$loopvar}_ctr";
            $toggle  = $d_name != 'FOREACH' && $d_name != 'LIST' ? null : "{$loopvar}_tgl";
            if (! $is_foreach) $stmt_list[] = $stag_stmt;
            if ($counter)      $stmt_list[] = new KwartzNativeStatement("{$counter} = 0;");
            if (true)          $stmt_list[] = new KwartzNativeStatement("foreach ({$d_arg}) {", 'foreach');
            if ($counter)      $stmt_list[] = new KwartzNativeStatement("  {$counter}++;");
            if ($toggle)       $stmt_list[] = new KwartzNativeStatement("  {$toggle} = {$counter}%2==0 ? {$this->even} : {$this->odd};");
            if ($is_foreach)   $stmt_list[] = $stag_stmt;
            kwartz_array_concat($stmt_list, $cont_stmts);
            if ($is_foreach)   $stmt_list[] = $etag_stmt;
            if (true)          $stmt_list[] = new KwartzNativeStatement("}", 'foreach');
            if (! $is_foreach) $stmt_list[] = $etag_stmt;
            break;

        case 'while':
            $stmt_list[] = new KwartzNativeStatement("while ({$_arg}) {", 'while');
            $stmt_list[] = $stag_stmt;
            kwartz_array_concat($stmt_list, $cont_stmts);
            $stmt_list[] = $etag_stmt;
            $stmt_list[] = new KwartzNativeStatement("}", 'while');

        case 'loop':
            $stmt_list[] = $stag_stmt;
            $stmt_list[] = new KwartzNativeStatement("while ({$_arg}) {", 'while');
            kwartz_array_concat($stmt_list, $cont_stmts);
            $stmt_list[] = new KwartzNativeStatement("}", 'while');
            $stmt_list[] = $etag_stmt;
            break;

        case 'set':
            $stmt_list[] = new KwartzNativeStatement("{$d_arg}", 'set');
            $stmt_list[] = $stag_stmt;
            kwartz_array_concat($stmt_list, $cont_stmts);
            $stmt_list[] = $etag_stmt;
            break;

        case 'if':
            $stmt_list[] = new KwartzNativeStatement("if ({$d_arg}) {", 'if');
            $stmt_list[] = $stag_stmt;
            kwartz_array_concat($stmt_list, $cont_stmts);
            $stmt_list[] = $etag_stmt;
            $smtt_list[] = new KwartzNativeStatement("}", 'if');
            break;

        case 'elseif':
        case 'else':
            $n = count($stmt_list);
            if ($n && ($st = $stmt_list[$n-1]) instanceof KwartzNativeStatement
                && ($st->kind == 'if' || $st->kind == 'elseif')) {
                // ok
            } else {
                $msg = "'{$d_str}': previous statement should be 'if' or 'elsif'.";
                throw $this->_error($msg, $stag_info->linenum);
            }
            array_pop($stmt_list);    // delete '}'
            $kind = $d_name;
            $code = $d_name == 'else' ? "} else {" : "} elseif ({$d_arg}) {";
            $stmt_list[] = new KwartzNativeStatement($code, $kind);
            $stmt_list[] = $stag_stmt;
            kwartz_array_concat($stmt_list, $cont_stmts);
            $stmt_list[] = $etag_stmt;
            $stmt_list[] = new KwartzNativeStatement("}", $kind);
            break;

        case 'default':
        case 'Default':
        case 'DEFAULT':
            $this->_error_if_empty_tag($stag_info, $etag_info, $d_name, $d_arg);
            $stmt_list[] = $stag_stmt;
            $stmt = new KwartzNativeStatement("if ({$d_arg}) {", 'if');
            $stmt->no_newline = true;
            $stmt_list[] = $stmt;
            $flag_escape = $d_name == 'default' ? null : ($d_name == 'Default');
            $args = array(new KwartzNativeExpression($d_arg, $flag_escape));
            $stmt_list[] = new KwartzPrintStatement($args);
            $stmt = new KwartzNativeStatement("} else {", 'else');
            $stmt->no_newline = true;
            $stmt_list[] = $stmt;
            kwartz_array_concat($stmt_list, $cont_stmts);
            $stmt = new KwartzNativeStatement("}", 'else');
            $stmt->no_newline = true;
            $stmt_list[] = $stmt;
            $stmt_list[] = $etag_stmt;
            break;

        default:
            return false;
        }
        return true;
    }


}



/**
 *  translator class for PHP
 */
class KwartzPhpTranslator extends KwartzBaseTranslator {


    function __construct($properties=array()) {
        $marks = array("<"."?php ", " ?".">",
                       "<"."?php echo ", "; ?".">",
                       "<"."?php echo htmlspecialchars(", "); ?".">");
        parent::__construct($marks, $properties);
    }


    function translate_string($str) {
        if (preg_match('/<\?xml/', $str)) {
            $str = preg_replace('/<\?xml/', "<<"."?php ?".">?xml", $str);
        }
        parent::translate_string($str);
    }


}


?>