<?php
// vim: set expandtab tabstop=4 shiftwidth=4 softtabstop=4:

// $Rev$
// $Release$
// $Copyright$



class KwartzException extends Exception {

    function __construct($message) {
        parent::__construct($message);
    }

}


class KwartzBaseException extends KwartzException {


    var $filename;
    var $linenum;


    function __construct($message, $filename=null, $linenum=NULL) {
        parent::__construct($message);
        $this->filename = $filename;
        $this->linenum = $linenum;
    }


    function __toString() {
        return "{$this->filename}:{$this->linenum}: " . $this->getMessage();
    }


}

?>