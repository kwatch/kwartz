/**
 *  @(#) ExecutionException.java
 *  @Id  $Id$
 *  @copyright (C)2005 kuwata-lab.com all rights reserverd
 */

package com.kuwata_lab.kwartz;

public class ExecutionException extends BaseException {
    public ExecutionException(String message) {
        super(message);
    }
    public ExecutionException(String message, Exception cause) {
        super(message, cause);
    }
    public ExecutionException(Exception cause) {
        super(cause);
    }
}
