<?php
// vim: set expandtab tabstop=4 shiftwidth=4 softtabstop=4:

// $Id$


//namespace Kwartz {

/**
 *  base exception class of KwartzPHP
 */
abstract class KwartzException extends exception {
    
}

/**
 *  base exception class of KwartzPHP
 */
abstract class KwartzError extends KwartzException {
    protected $msg;
    protected $linenum;
    protected $filename;
    
    function __construct($msg, $linenum=NULL, $filename=NULL) {
        $s = "";
        if ($filename) { $s .= "$filename"; }
        if ($linenum)  { $s .= "(line $linenum)"; }
        if ($s)        { $s .= ": "; }
        parent::__construct($s . $msg);
        
        $this->msg = $msg;
        $this->linenum = $linenum;
        $this->filename = $filename;
    }
    
    function linenum() { return $this->linenum; }
    function msg() { return $this->msg; }
    function filename() { return $this->filename; }
}

//} // end of namespace Kwartz

?>