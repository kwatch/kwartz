/**
 *  @(#) Node.java
 *  @Id  $Id$
 *  @copyright (C)2005 kuwata-lab.com all rights reserverd
 */
package com.kuwata_lab.kwartz;
import java.util.Map;

abstract class Node {
    protected int _token;
    public Node(int token) {
        _token = token;
    }
    public int getToken() { return _token; }
    public void setToken(int token) { _token = token; }

    abstract public Object evaluate(Map context);
    abstract public Object accept(Visitor visitor);

    public StringBuffer _inspect(int level, StringBuffer sb) {
        for (int i = 0; i < level; i++) sb.append("  ");
        sb.append(TokenType.tokenText(_token));
        sb.append("\n");
        return sb;
    }
    public StringBuffer _inspect() {
        return _inspect(0, new StringBuffer());
    }
}
