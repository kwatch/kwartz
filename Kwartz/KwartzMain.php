<?php
// vim: set expandtab tabstop=4 shiftwidth=4 softtabstop=4:

// $Rev$
// $Release$
// $Copyright$


require_once('Kwartz/KwartzConfig.php');
require_once('Kwartz/KwartzException.php');
require_once('Kwartz/KwartzNode.php');
require_once('Kwartz/KwartzUtility.php');
require_once('Kwartz/KwartzParser.php');
require_once('Kwartz/KwartzConverter.php');
require_once('Kwartz/KwartzTranslator.php');

require_once('Kwartz/Binding/Php.php');
require_once('Kwartz/Binding/Eruby.php');
require_once('Kwartz/Binding/Ruby.php');
require_once('Kwartz/Binding/Erubis.php');
require_once('Kwartz/Binding/Pierubis.php');
require_once('Kwartz/Binding/Jstl.php');
require_once('Kwartz/Binding/Eperl.php');

error_reporting(E_ALL);



class KwartzCommandOptionException extends KwartzException {


    function __construct($message) {
        parent::__construct($message);
    }


    function __toString() {
        return $this->getMessage();
    }


}



class KwartzMain {


    var $args;
    var $command;
    var $options;
    var $properties;
    var $filenames;
    var $_optchars;
    var $_argnames;


    function __construct($args) {
        $this->args = $args;
        $this->_optchars = array(
            'single'=>'hvet',
            'argument'=>'pliLXxf',
            'optional'=>'',
            );
        $this->_argnames = array(
            'l' => 'lang name',
            //'k' => 'kanji code',
            'r' => 'library name',
            'p' => 'file name',
            //'P' => 'parser style',
            'x' => 'element id',
            'X' => 'element id',
            'i' => 'file name',
            'L' => 'file name',
            'f' => 'yaml file',
            );
    }


    function _error($msg) {
        return new KwartzCommandOptionException($msg);
    }


    static function main($args) {
        $main = new KwartzMain($args);
        $output = $main->execute();
        if ($output) {
            echo $output;
        }
    }


    function execute() {
        global $KWARTZ_PROPERTY_LANG;

        // parse command-line options
        $opts_single   = $this->_optchars['single'];
        $opts_argument = $this->_optchars['argument'];
        $argnames      = $this->_argnames;
        $this->_parse_argv($this->args, $opts_single, $opts_argument, $argnames);
        $options    = $this->options;
        $properties = $this->properties;
        $filenames  = $this->filenames;
        if (kwartz_array_get($properties, 'help')) {
            $options['h'] = true;
        }

        // help
        $help = kwartz_array_get($options, 'h');
        $version = kwartz_array_get($options, 'v');
        if ($help || $version) {
            $s = '';
            if (kwartz_array_get($options, 'v'))
                $s .= $this->_version() . "\n";
            if (kwartz_array_get($options, 'h'))
                $s .= $this->_help();
            file_put_contents('php://stderr', $s);
            return null;
        }

        // check filenames
        if (! $filenames) {
            $msg = "filename of presentation data is required.";
            throw $this->_error($msg);
        }
        foreach ($filenames as $filename) {
            if (! file_exists($filename)) {
                $msg = "{$filename}: file not found.";
                throw $this->_error($msg);
            }
        }
        $pdata_filenames = $filenames;

        // options

        // parse class, hander class, translator class
        //$style = kwartz_array_get($options, 'P', 'css');
        //$parse_class = PresentationLogicParser::get_class($style);
        //if (! $parser_class) {
        //    $msg = "-P {$style}: unknown style name (paresr class not registered).";
        //    throw $this->_error($msg);
        //}
        $lang = kwartz_array_get($options, 'l', KWARTZ_PROPERTY_LANG);
        switch ($lang) {
        case 'php':
        case 'ruby':
        case 'eruby':
        case 'jstl':
        case 'eperl':
        case 'erubis':
        case 'pierubis':
            // ok
            break;
        default:
            $msg = "-l {$lang}: unknown lang name.";
            throw $this->_error($msg);
        }
        $Lang = ucfirst($lang);
        $handler_klass = "Kwartz{$Lang}Handler";
        $translator_klass = "Kwartz{$Lang}Translator";

        // require libraries
        $requires = kwartz_array_get($options, 'r');
        if ($requires) {
            $libraries = preg_split('/,/', $requires);
            foreach ($libraries as $library) {
                require_once(trim($library));
            }
        }

        // parse presentation logic file
        $ruleset_list = array();
        $plogics = kwartz_array_get($options, 'p');
        if ($plogics) {
            $parser = new KwartzCssStyleParser($properties);
            foreach (preg_split('/,/', $plogics) as $filename) {
                $filename = trim($filename);
                if (file_exists($filename)) {
                    // ok
                } elseif (file_exists($filename . '.plogic')) {
                    $filename .= '.plogic';
                } else {
                    $msg = "-p {$filename}[.plogic]: file not found.";
                    throw $this->_error($msg);
                }
                $plogic = file_get_contents($filename);
                $rulesets = $parser->parse($plogic, $filename);
                $ruleset_list = array_merge($ruleset_list, $rulesets);
            }
        }

        // properties
        if (kwartz_array_get($options, 'e') && ! array_key_exists('escape', $properties)) {
            $properties['escape'] = true;
        }

        // create converter
        $handler = new $handler_klass($ruleset_list, $properties);
        $converter = new KwartzTextConverter($handler, $properties);

        // import-files and layout-file
        $import_filenames = array();
        $imports = kwartz_array_get($options, 'i');
        if ($imports) {
            $import_filenames = preg_split('/,/', $imports);
            foreach ($import_filenames as $filename) {
                if (! file_exists($filename)) {
                    $msg = "-i {$filename}: file not found.";
                    throw $this->_error($msg);
                }
            }
        }
        $layout = kwartz_array_get($options, 'L');
        if ($layout) {
            if (! file_exists($layout)) {
                $msg = "-L {$layout}: file not found.";
                throw $this->_error($msg);
            }
            $import_filenames = array_merge($import_filenames, $pdata_filenames);
            $pdata_filenames = array($layout);
        }
        foreach ($import_filenames as $filename) {
            $pdata = file_get_contents($filename);
            $converter->convert($pdata, $filename);
        }

        // convert presentation data file
        $stmt_list = array();
        $pdata = null;
        foreach ($pdata_filenames as $filename) {
            if (! file_exists($filename)) {
                $msg = "{$filename}: file not found.";
                throw $this->_error($msg);
            }
            $pdata = file_get_contents($filename);
            $list = $converter->convert($pdata, $filename);
            $stmt_list = array_merge($stmt_list, $list);
        }

        // extract element or content
        $elem_id = kwartz_array_get($options, 'X');
        $cont_id = kwartz_array_get($options, 'x');
        if ($elem_id) {
            $stmt_list = $handler->extract($elem_id, false);
        } elseif ($cont_id) {
            $stmt_list = $handler->extract($cont_id, true);
        }

        // translate statements into target code(eRuby, PHP, JSP)
        $nl = kwartz_detect_newline_char($pdata);
        if ($nl == "\r\n" && ! array_key_exists('nl', $properties)) {
            $properties['nl'] = $nl;
        }
        $translator = new $translator_klass($properties);
        $output = $translator->translate($stmt_list);

        // load YAML file and evaluate PHP script
        $yamlfile = kwartz_array_get($options, 'f');
        if ($yamlfile) {
            if ($lang != 'php') {
                $msg = "-f: not available with lang '{$lang}'";
                throw $this->_error($msg);
            }
            if (! file_exists($yamlfile)) {
                $msg = "-f {$yamlfile}: file not found.";
                throw $this->_error($msg);
            }
            $str = file_get_contents($yamlfile);
            if (kwartz_array_get($options, 't')) {
                $str = kwartz_untabify($str);
            }
            if (! extension_loaded('syck')) {
                if (! dl('syck.so')) {   // or dl('/some/where/to/syck.so')
                    $msg = "cannot load syck extentsion.";
                    throw $this->_error($msg);
                }
            }
            $php_script = $output;
            $context = syck_load($str);
            if (! $this->_is_mapping($context)) {
                $msg = "-f {$yamlfile}: not a mapping.";
                throw $this->_error($msg);
            }
            $output = $this->_eval_php_script($php_script, $context);
        }

        return $output;
    }


    function _is_mapping(&$obj) {
        if (! is_array($obj))
            return false;
        foreach ($obj as $key => $val) {
            if (! is_string($key))
                return false;
        }
        return true;
    }


    function _eval_php_script($php_script, $context) {
        //$f = tmpfile();
        //$tmpdir = php_get_tmpdir();  // undefined function
        foreach (array("/tmp", "/var/tmp", "/TEMP", '.') as $tmpdir) {
            if (file_exists($tmpdir)) break;
        }
        $filename = tempnam($tmpdir, "kwartz.tmpfile");
        $f = fopen($filename, 'w');
        fwrite($f, $php_script);
        ob_start();
        $this->_include_php_script($filename, $context);
        $output = ob_get_clean();
        fclose($f);
        unlink($filename);
        return $output;
    }


    function _include_php_script($_filename, $_context) {
        extract($_context);
        include($_filename);
    }


    function _version() {
        preg_match('/[.\d]+/', '$Release: 0.0.0 $', $m);
        return $m[0];
    }


    function _help() {
        $command = basename($this->command);
        $sb = array();
        $sb[] = "kwartz-php - a template system realized 'Independence of Presentation Logic'";
        $sb[] = "Usage: {$command} [..options..] [-p plogic] file.html [file2.html ...]";
        $sb[] = "  -h             : help";
        $sb[] = "  -v             : version";
        $sb[] = "  -e             : alias of '--escape=true'";
        $sb[] = "  -l lang        : php/eruby/ruby/jstl/eperl/erubis/pierubis (default 'php')";
        #$sb[] = "  -k kanji       : euc/sjis/utf8 (default nil)";
        #$sb[] = "  -r library,... : require libraries";
        $sb[] = "  -p plogic,...  : presentation logic files";
        $sb[] = "  -i pdata,...   : import presentation data files";
        $sb[] = "  -L layoutfile  : layout file ('-L f1 f2' is equivalent to '-i f2 f1')";
        $sb[] = "  -x elem-id     : extract content of element marked by elem-id";
        $sb[] = "  -X elem-id     : extract element marked by elem-id";
        $sb[] = "  -f yamlfile    : YAML file for context values";
        $sb[] = "  -t             : expand tab character in YAML file";
        #$sb[] = "  -S             : convert mapping key from string to symbol in YAML file";
        $sb[] = "  --dattr=str    : directive attribute name";
        $sb[] = "  --odd=value    : odd value for FOREACH/LOOP directive (default \"'odd'\")";
        $sb[] = "  --even=value   : even value for FOREACH/LOOP directive (default \"'even'\")";
        $sb[] = "  --header=str   : header text";
        $sb[] = "  --footer=str   : footer text";
        $sb[] = "  --delspan={true|false} : delete dummy span tag (default false)";
        $sb[] = "  --escape={true|false}  : escape (sanitize) (default false)";
        $sb[] = "  --jstl={1.2|1.1}       : JSTL version (default 1.2)";
        $sb[] = "  --charset=charset      : character set for JSTL (default none)";
        $sb[] = '';
        return join($sb, "\n");
    }


    function _parse_argv($args, $opts_single, $opts_argument, $argnames) {
        $this->options    = array();   // hash
        $this->properties = array();   // hash
        $this->command    = array_shift($args);
        while ($args && $args[0] && $args[0][0] == '-') {
            $optstr = array_shift($args);
            $len = strlen($optstr);
            if ($len >= 2 && $optstr[1] == '-') {
                if (! preg_match('/^--([-\w]+)(=(.*))?$/', $optstr, $m)) {
                    $msg = "{$optstr}: invalid property format.";
                    $this->_error($msg);
                }
                $name = $m[1];
                $value = kwartz_array_get($m, 3);
                if ($value === null) {
                    $value = true;
                } elseif (preg_match('/^\d+$/', $value)) {
                    $value = intval($value);
                } elseif ($value == 'true' || $value == 'yes') {
                    $value = true;
                } elseif ($value == 'false' || $value == 'no') {
                    $value = false;
                } elseif ($value == 'null' || $value == 'nil') {
                    $value = null;
                }
                $this->properties[$name] = $value;
                continue;
            }
            for ($i = 1; $i < $len; $i++) {
                $optch = $optstr[$i];
                if (strpos($opts_single, $optch) !== false) {
                    $this->options[$optch] = true;
                } elseif (strpos($opts_argument, $optch) !== false) {
                    $optarg = $i + 1 < $len ? substr($optstr, $i+1) : array_shift($args);
                    if ($optarg === null) {
                        $msg = "-{$optch}: {$argnames[$optch]} required.";
                        throw $this->_error($msg);
                    }
                    $this->options[$optch] = $optarg;
                    break;
                } else {
                    $msg = "-{$optch}: invalid otpion.";
                    throw $this->_error($msg);
                }
            }
        }
        $this->filenames = $args;
    }


}


?>