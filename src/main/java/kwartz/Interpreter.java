/**
 *  @(#) Interpreter.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz;
import java.util.Map;
import java.util.Properties;
import java.io.Writer;
import java.io.PrintWriter;

import kwartz.node.Statement;

public class Interpreter {
    private StatementParser _parser;
    private Statement _stmt = null;
    private Properties _props;

    public Interpreter() {
        _parser = new StatementParser();
        _props = _parser.getProperties();
    }

    public Interpreter(Properties props) {
        _props = props;
        _parser = new StatementParser(_props);
    }

    public Statement compile(String code) {
        _stmt = _parser.parse(code);
        return _stmt;
    }

    public Object execute(Map context) throws java.io.IOException  {
        return execute(context, new PrintWriter(System.out));
    }

    public Object execute(Map context, Writer writer) throws java.io.IOException {
        if (_stmt == null) return null;
        return _stmt.execute(context, writer);
    }
}
