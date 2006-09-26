<?php

/// $Rev$
/// $Release$
/// $Copyright$


// you need to install PHPUnit2 by 'sudo pear install --alldeps PHPUnit2'
// see http://www.phpunit.de/pocket_guide/2.3/en/installation.html

require_once 'KwartzTest.inc';
require_once 'PHPUnit2/Framework/TestSuite.php';


class KwartzTest extends PHPUnit2_Framework_TestCase {

    //public static function main() {
    //    PHPUnit2_TextUI_TestRunner::run(self::suite());
    //}

    public static function suite() {
        //$filenames = array(
        //    'KwartzCompileTest.php',
        //    'KwartzParserTest.php',
        //    'KwartzConverterTest.php',
        //    'KwartzRulesetTest.php',
        //    'KwartzDirectiveTest.php',
        //    'KwartzMainTest.php',
        //    );
        $filenames = glob("Kwartz?*Test.php");
        $suite = new PHPUnit2_Framework_TestSuite('Kwartz');
        $suite->addTestFiles($filenames);
        return $suite;
    }

}

?>