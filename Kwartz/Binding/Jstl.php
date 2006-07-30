<?php
// vim: set expandtab tabstop=4 shiftwidth=4 softtabstop=4:

// $Rev$
// $Release$
// $Copyright$


require_once('Kwartz/KwartzConverter.php');
require_once('Kwartz/KwartzTranslator.php');
require_once('Kwartz/KwartzUtility.php');


/**
 *  directive handler for JSTL
 */
class KwartzJstlHandler extends KwartzHandler {


    var $jstl_version;


    function __construct($ruleset_list=array(), $properties=array()) {
        parent::__construct($ruleset_list, $properties);
        $this->jstl_version = kwartz_array_get($properties, 'jstl', KWARTZ_PROPERTY_JSTL);
    }


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

        case 'for':   case 'For':   case 'FOR':
        case 'list':  case 'List':  case 'LIST':
            $content_only = strtolower($d_name) == 'list';
            if ($content_only) {
                $this->helper->error_if_empty_tag($arg);
            }
            if (! preg_match('/\A(\w+)\s*:\s*(.*)\z/', $d_arg, $m)) {
                $msg = "'{$d_str}': invalid argument.";
                throw convert_error($msg, $arg->stag_info->linenum);
            }
            $loopvar = $m[1];  $looplist = $m[2];
            $counter = $d_name == 'for' || $d_name == 'list' ? null : "{$loopvar}_ctr";
            $toggle  = $d_name != 'FOR' && $d_name != 'LIST' ? null : "{$loopvar}_tgl";
            $status  = $d_name == 'for' || $d_name == 'list' ? null : "{$loopvar}_status";
            //
            $code = array();
            $s = "<c:forEach var=\"{$loopvar}\" items=\"\${{$looplist}}\"";
            if ($status) $s .= " varStatus=\"{$status}\"";
            $s .= ">";
            $code[] = $s;
            if ($counter)
                $code[] = "<c:set var=\"{$counter}\" value=\"\${{$status}.count}\"/>";
            if ($toggle) {
                if ($this->jstl_version < 1.2) {
                    $code[] = "<c:choose><c:when test=\"\${{$status}.count%2==0}\">";
                    $code[] = "<c:set var=\"{$toggle}\" value=\"\${{$this->even}}\"/>";
                    $code[] = "</c:when><c:otherwise>";
                    $code[] = "<c:set var=\"{$toggle}\" value=\"\${{$this->odd}}\"/>";
                    $code[] = "</c:otherwise></c:choose>";
                } else {
                    $code[] = "<c:set var=\"{$toggle}\" value=\"\${{$status}.count%2==0 ?"
                            . " {$this->even} : {$this->odd}}\"/>";
                }
            }
            if ($content_only) {
                $this->helper->wrap_content_with_native_stmt($stmt_list, $arg,
                                                      $code, "</c:forEach>", 'foreach');
            } else {
                $this->helper->wrap_element_with_native_stmt($stmt_list, $arg,
                                                      $code, "</c:forEach>", 'foreach');
            }
            break;

        case 'while':
        case 'loop':
            $msg = "'{$d_str}': jstl doesn't support '{$d_arg}' directive.";
            throw $this->_error($msg, $arg->stag_info->linenum);
            break;

        case 'set':
            if (! preg_match('/\A(\S+)\s*=\s*(.*)\z/', $d_arg, $m)) {
                $msg = "'{$d_str}': invalid argument.";
                throw $this->_error($msg, $arg->stag_info->linenum);
            }
            $lhs = $m[1];  $rhs = $m[2];
            $code = "<c:set var=\"{$lhs}\" value=\"\${{$rhs}}\"/>";
            $this->helper->wrap_element_with_native_stmt($stmt_list, $arg,
                                                         $code, null, 'set');
            break;

        case 'if':
            $code = "<c:choose><c:when test=\"\${{$d_arg}}\">";
            $this->helper->wrap_element_with_native_stmt($stmt_list, $arg,
                                               $code, "</c:when></c:choose>", 'if');
            break;

        case 'elseif':
        case 'else':
            $this->helper->error_when_last_stmt_is_not_if($stmt_list, $arg);
            array_pop($stmt_list);  // delete '</c:when></c:choose>'
            if ($d_name == 'else') {
                $kind = 'else';
                $start_code = "</c:when><c:otherwise>";
                $end_code   = "</c:otherwise></c:choose>";
            } else {
                $kind = 'elseif';
                $start_code = "</c:when><c:when test=\"\${{$d_arg}}\">";
                $end_code   = "</c:when></c:choose>";
            }
            $this->helper->wrap_element_with_native_stmt($stmt_list, $arg,
                                                         $start_code, $end_code, $kind);
            break;

        case 'default':
        case 'Default':
        case 'DEFAULT':
            $this->helper->error_if_empty_tag($arg);
            $stmt_list[] = $this->helper->stag_stmt($arg);
            $flag_escape = $d_name == 'default' ? null : ($d_name == 'Default');
            $argstr = $arg->cont_stmts[0]->args[0];
            $code = "<c:out value=\"\${{$d_arg}}\"";
            if ($flag_escape !== null)
                $code .= " escapeXml=\"{$flag_escape}\"";
            $code .= " default=\"{$argstr}\"/>";
            $stmt = new KwartzNativeStatement($code);
            $stmt->no_newline = true;
            $stmt_list[] = $stmt;
            $stmt_list[] = $this->helper->etag_stmt($arg);
            break;

        case 'catch':
            if ($d_arg && ! preg_match('/\A\w+\z/', $d_arg)) {
                $msg = "'{$d_str}': invalid varname.";
                throw $this->_error($msg, $arg->stag_info->linenum);
            }
            $code = "<c:catch";
            if ($d_arg) $code .= " var=\"{$d_arg}\"";
            $code .= ">";
            $stmt_list[] = new KwartzNativeStatement($code);
            kwartz_array_concat($stmt_list, $arg->cont_stmts);
            $stmt_list[] = new KwartzNativeStatement("</c:catch>");
            break;

        case 'forEach':
        case 'forToken':
            eval("\$options=array({$d_arg});");
            $method = "handle_jstl_{$d_name}";
            list($stag, $etag) = $this->$method($options);
            $this->helper->wrap_element_with_native_stmt($stmt_list, $arg,
                                                         $stag, $etag, null);
            break;

        case 'redirect':
        case 'import':
        case 'url':
        case 'remove':
            $options = eval("array({$d_arg})");
            $method = "handle_jstl_{$d_name}";
            $lines = $this->$method($d_arg);
            foreach ($lines as $line) {
                $stmt_list[] = new KwartzNativeStatement($line);
            }
            break;

        default:
            return false;
        }

        return true;
    }


    function handle_jstl_redirect($options) {
        $params = array('url', 'context');
        return $this->_handle_jstl_params('redirect', $params, $options);
    }


    function handle_jstl_import($options) {
        $params = array('url', 'context', 'charEncoding', 'var', 'scope');
        return $this->_handle_jstl_params('import', $params, $options);
    }


    function handle_jstl_url($options) {
        $params = array('value', 'context', 'var', 'scope');
        return $this->_handle_jstl_params('url', $params, $options);
    }


    function handle_jstl_remove($options) {
        $params = array('var', 'scope');
        return $this->_handle_jstl_params('remove', $params, $options);
    }


    function handle_jstl_forEach($options) {
        $params = array('var', 'items', 'varStatus', 'begin', 'end', 'step');
        return $this->_handle_jstl_tag('forEach', $params, $options);
    }


    function handle_jstl_forTokens($options) {
        $params = array('items', 'delims', 'var', 'varStatus', 'begin', 'end', 'step');
        return $this->_handle_jstl_tag('forTokens', $params, $options);
    }


    function _handle_jstl_params($tagname, $params, $options) {
        $option_names = array_keys($options);
        $known_names = array_intersect($params, $option_names);  // params ^ option_names
        $unknown_names = array_diff($option_names, $known_names);
        list($stag, $etag) = $this->_handle_jstl_tag($tagname, $params, $known_names);
        $lines = array();
        if ($unkown_names) {
            $lines[] = $stag;
            foreach ($unkown_names as $option_name) {
                $lines[] = " <c:param name=\"{$name}\" value=\"{$value}\"/>";
            }
            $lines[] = $etag;
        } else {
            $lines[] = preg_replace('/>\z/', '/>', $stag);
        }
        return $lines;
    }


    function _handle_jstl_tag($tagname, $params, $options) {
        $option_names = array_keys($options);
        $unknown_names = array_diff($option_names, $params);
        if ($unknown_names) {
            $msg = "'{$unknown_names[0]}': unknown option for '{$tagname}' directive.";
            throw $this->_error($msg, null);
        }
        $sb = array("<c:{$tagname}");
        $known_names = array_intersect($params, $option_names);
        foreach ($known_names as $name) {
            $value = $options[$name];
            $sb[] = " {$name}=\"{$value}\"";
        }
        $sb[] = ">";
        $stag = join($sb);
        $etag = "</c:{$tagname}>";
        return array($stag, $etag);
    }


}



/**
 *  translator for php
 */
class KwartzJstlTranslator extends KwartzBaseTranslator {


    var $jstl_version;


    function __construct($properties=array()) {
        $this->jstl_version = kwartz_array_get($properties, 'jstl', KWARTZ_PROPERTY_JSTL);
        $marks = $this->jstl_version < 1.2
            ?
            array('', '',                                       // statement
                  '<c:out value="${', '}" escapeXml="false"/>', // expression
                  '<c:out value="${', '}"/>')                   // escaped expression
            :
            array('', '',                                       // statement
                  '<c:out value="${', '}" escapeXml="false"/>', // expression
                  '${', '}')                                    // escaped expression
            ;
        parent::__construct($marks, $properties);
        if ($this->header === null) {
            $buf = array();
            if ($charset = kwartz_array_get($properties, 'charset')) {
                $buf[] = "<%@ page contentType=\"text/html; charset={$charset}\" %>";
            }
            if ($this->jstl_version < 1.2) {
                $buf[] = '<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core" %>';
            } else {
                $buf[] = '<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core" %>';
                $buf[] = '<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>';
            }
            $buf[] = '';
            $this->header = join($buf, $this->nl);
        }
    }


    function translate_native_expr($expr) {
        assert('$expr instanceof KwartzNativeExpression');
        $code = $expr->code;
        if (preg_match('/\A"(.*)"\z/', $code, $m)
            || preg_match('/\A\'(.*)\'\z/', $code, $m)) {
            $this->buf[] = $m[1];
            return;
        }
        $flag_escape = $expr->escape;
        if ($flag_escape === null)
            $flag_escape = $this->escape;
        if ($flag_escape === false) {   # ex. <c:out value="${expr}" escapeXml="false"/>
            $this->buf[] = $this->expr_l . $code . $this->expr_r;
        } else {                        # ex. ${expr} or <c:out value="${expr}"/>
            $this->buf[] = $this->escape_l . $code . $this->escape_r;
        }
    }


}

?>