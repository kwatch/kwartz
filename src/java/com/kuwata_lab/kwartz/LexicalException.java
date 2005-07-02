/**
 *  @(#) LexicalException.java
 *  @Id  $Id$
 *  @copyright (C)2005 kuwata-lab.com all rights reserverd
 */
package com.kuwata_lab.kwartz;

public class LexicalException extends SyntaxException {
    public LexicalException(String message, String filename, int linenum, int column) {
        super(message, filename, linenum, column);
    }
}
