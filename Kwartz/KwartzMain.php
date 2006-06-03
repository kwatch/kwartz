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

error_reporting(E_ALL);



class KwartzCommandOptionException extends KwartzException {

    function __construct($message) {
        parent::__construct($message);
    }

}



class KwartzMain {

    var $args;
    var $command;
    var $options;
    var $properties;
    var $filenames;


    function __construct($args) {
        $this->args = $args;
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
        $this->_parse_argv($this->args, 'hve', 'piL');
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
            if ($options['v']) $s .= $this->_version() . "\n";
            if ($options['h']) $s .= $this->_help();
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
        $lang = kwartz_array_get($options, 'l', $KWARTZ_PROPERTY_LANG);
        //$handler_class = KwartzHander::get_class($lang);
        //if (! $handler_class) {
        //    $msg = "-l {$lang}: unknown lang name (handler class not registered).";
        //    throw $this->_error($msg);
        //}
        //$translator_class = KwartzTranslator::get_class($lang);
        //if (! $translator_class) {
        //    $msg = "-l {$lang}: unknown lang name (translator class not registered).";
        //    throw $this->_error($msg);
        //}

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
        $handler = new KwartzPhpHandler($ruleset_list, $properties);
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
        $translator = new KwartzPhpTranslator($properties);
        $output = $translator->translate($stmt_list);

        // load YAML file and evaluate eRuby script
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
            $output = $this->_eval_php_script($php_script, $context);
        }

        return $output;
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
        $this->_include_php_script($filename, $context);
        fclose($f);
        unlink($filename);
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
        $sb[] = "kwartz-php - a template system realized 'Independence of Presentation Logic'\n";
        $sb[] = "Usage: {$command} [..options..] [-p plogic] file.html [file2.html ...]\n";
        $sb[] = "  -h             : help\n";
        $sb[] = "  -v             : version\n";
        $sb[] = "  -e             : alias of '--escape=true'\n";
        $sb[] = "  -l lang        : eruby/php/eperl/rails/jstl (default 'eruby')\n";
        #$sb[] = "  -k kanji       : euc/sjis/utf8 (default nil)\n";
        $sb[] = "  -r library,... : require libraries\n";
        $sb[] = "  -p plogic,...  : presentation logic files\n";
        $sb[] = "  -i pdata,...   : import presentation data files\n";
        $sb[] = "  -L layoutfile  : layout file ('-L f1 f2' is equivalent to '-i f2 f1')\n";
        $sb[] = "  -x elem-id     : extract content of element marked by elem-id\n";
        $sb[] = "  -X elem-id     : extract element marked by elem-id\n";
        $sb[] = "  -f yamlfile    : YAML file for context values\n";
        $sb[] = "  -t             : expand tab character in YAML file\n";
        #$sb[] = "  -S             : convert mapping key from string to symbol in YAML file\n";
        $sb[] = "  --dattr=str    : directive attribute name\n";
        $sb[] = "  --odd=value    : odd value for FOREACH/LOOP directive (default \"'odd'\")\n";
        $sb[] = "  --even=value   : even value for FOREACH/LOOP directive (default \"'even'\")\n";
        $sb[] = "  --header=str   : header text\n";
        $sb[] = "  --footer=str   : footer text\n";
        $sb[] = "  --delspan={true|false} : delete dummy span tag (default false)\n";
        $sb[] = "  --escape={true|false}  : escape (sanitize) (default false)\n";
        $sb[] = "  --jstl={1.2|1.1}       : JSTL version (default 1.2)\n";
        $sb[] = "  --charset=charset      : character set for JSTL (default none)\n";
        return join($sb);
    }


    function _parse_argv($args, $single_optstr, $argument_optstr) {
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
                $value = $m[3];
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
                if (strpos($single_optstr, $optch) !== false) {
                    $this->options[$optch] = true;
                } elseif (strpos($argument_optstr, $optch) !== false) {
                    $optarg = $i + 1 < $len ? substr($optstr, $i+1) : array_shift($args);
                    if ($optarg === null) {
                        $msg = "-{$optch}: argument required.";
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