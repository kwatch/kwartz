<?php
// vim: set expandtab tabstop=4 shiftwidth=4 softtabstop=4:

// $Id$
//
// Copyright (C) 2004 kuwata-lab All rights reserved.

/*
 * Development of Kwartz-php is subsidized by Exploratory Software Project of
 * IPA (Information-Technology Promotion Agency Japan).
 * See http://www.ipa.go.jp/about/english/index.html
 */

/*
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
 */

//namespace Kwartz {

/**
 *    
 */
class Kwartz {
    const REVISION   = '$Rev$';
    const LASTUPDATE = '$Date$';
}

//} // end of namespace Kwartz


require_once('Kwartz/KwartzException.php');
require_once('Kwartz/KwartzUtility.php');
require_once('Kwartz/KwartzVisitor.php');
require_once('Kwartz/KwartzNode.php');
require_once('Kwartz/KwartzScanner.php');
require_once('Kwartz/KwartzParser.php');
require_once('Kwartz/KwartzConverter.php');
require_once('Kwartz/KwartzTranslator.php');
require_once('Kwartz/KwartzErubyTranslator.php');
require_once('Kwartz/KwartzJstlTranslator.php');
require_once('Kwartz/KwartzPlphpTranslator.php');
require_once('Kwartz/KwartzCompiler.php');
require_once('Kwartz/KwartzAnalyzer.php');
require_once('Kwartz/KwartzHelper.php');

?>