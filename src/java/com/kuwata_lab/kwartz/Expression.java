/**
 *  @(#) Expression.java
 *  @Id  $Id$
 *  @copyright (C)2005 kuwata-lab.com all rights reserverd
 */

package com.kuwata_lab.kwartz;

abstract public class Expression extends Node {
    public Expression(int token) {
        super(token);
    }

    public Object accept(Visitor visitor) {
        return visitor.visitExpression(this);
    }
}
