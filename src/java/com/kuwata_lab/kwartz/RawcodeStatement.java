/**
 *  @(#) RawcodeStatement.java
 *  @Id  $Id$
 *  @copyright (C)2005 kuwata-lab.com all rights reserverd
 */
package com.kuwata_lab.kwartz;
import java.util.Map;
import java.io.Writer;
import java.io.IOException;

public class RawcodeStatement extends Statement {
    private String _rawcode;
    public RawcodeStatement(String rawcode) {
        super(TokenType.RAWSTMT);
        _rawcode = rawcode;
    }

    public String getRawcode() { return _rawcode; }
    public void setRawcode(String rawcode) { _rawcode = rawcode; }

    public Object execute(Map context, Writer writer) {
        throw new EvaluationException("cannot evaluate rawcode statement.");
        //return null;
    }
    public Object accept(Visitor visitor) {
        return visitor.visitRawcodeStatement(this);
    }
}
