<?php
// vim: set expandtab tabstop=4 shiftwidth=4 softtabstop=4:

// $Id$

require_once('Kwartz/KwartzException.php');
require_once('Kwartz/KwartzParser.php');
require_once('Kwartz/KwartzConverter.php');
require_once('Kwartz/KwartzTranslator.php');
require_once('Kwartz/KwartzErubyTranslator.php');
require_once('Kwartz/KwartzJspTranslator.php');
require_once('Kwartz/KwartzPlphpTranslator.php');
require_once('Kwartz/KwartzUtility.php');


//namespace Kwartz {

/**
 *  exception class for compilation
 */
class KwartzCompilationError extends KwartzError {
    function __construct($msg, $linenum=NULL, $filename=NULL) {
        parent::__construct($msg, $linenum, $filename);
    }
}


/**
 *  compile presentaion data and presentation logic, and generate view script
 */
class KwartzCompiler {
    private $pdata;
    private $plogic;
    private $lang;
    private $toppings;
    private $flag_escape;
    
    function __construct($pdata_str=NULL, $plogic_code=NULL, $lang='php', $flag_escape=FALSE, $toppings=NULL) {
        $this->pdata = $pdata_str;
        $this->plogic = $plogic_code;
        $this->toppings = $toppings ? $toppings : array();
        switch ($lang) {
          case 'php':
          case 'eruby':
          case 'jsp':
          case 'plphp':
            // OK
            break;
          default:
            $msg = "language '{$lang}' not supported.";
            throw new KwartzCompilationError($msg, $this);
        }
        $this->lang = $lang;
        $this->flag_escape = $flag_escape;
    }
    
    function topping($name) {
        if (array_key_exists($name, $this->toppings)) {
            return $this->toppings[$name];
        }
        return NULL;
    }
    
    function compile() {
        // convert presentation data into block
        $pdata_block = NULL;
        $newline_char = NULL;
        if ($this->pdata) {
            $newline_char = kwartz_detect_newline_char($this->pdata);
            if ($filename = $this->topping('pdata_filename')) {
                $this->toppings['filename'] = $filename;
            }
            $converter = new KwartzConverter($this->pdata, $this->toppings);
            $pdata_block = $converter->convert();
        }
        
        // convert presentation logic code into block
        $plogic_block = NULL;
        if ($this->plogic) {
            if ($filename = $this->topping('plogic_filename')) {
                $this->toppings['filename'] = $filename;
            }
            $parser = new KwartzParser($this->plogic, $this->toppings);
            $plogic_block = $parser->parse();
        }
        
        // merge blocks and create a new block
        if (! ($pdata_block || $plogic_block)) {
            return NULL;
        }
        if ($pdata_block && $plogic_block) {
            $block = $pdata_block->merge($plogic_block);
        } else {
            $block = $pdata_block ? $pdata_block : $plogic_block;
        }
        
        // translate block into PHP code
        switch ($this->lang) {
          case 'php':
            $translator = new KwartzPhpTranslator($block, $this->flag_escape, $this->toppings);
            break;
          case 'eruby':
            $translator = new KwartzErubyTranslator($block, $this->flag_escape, $this->toppings);
            break;
          case 'jsp':
            $translator = new KwartzJspTranslator($block, $this->flag_escape, $this->toppings);
            break;
          case 'plphp':
            $translator = new KwartzPlphpTranslator($block, $this->flag_escape, $this->toppings);
            break;
          default:
            assert(false);
        }
        if ($newline_char) {
            $translator->set_newline_char($newline_char);
        }
        $code = $translator->translate();
        
        return $code;
    }
    
}

//}  // end of namespace Kwartz

?>