/**
 *  @(#) SyntaxException.java
 *  @Id  $Id$
 *  @copyright (C)2005 kuwata-lab.com all rights reserverd
 */
package com.kuwata_lab.kwartz;

public class SyntaxException extends ParseException {
    public SyntaxException(String message, String filename, int linenum, int column) {
        super(message, filename, linenum, column);
    }
}
