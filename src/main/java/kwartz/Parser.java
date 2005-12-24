/**
 *  @(#) Parser.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz;

import java.util.Properties;

abstract public class Parser {
    protected Scanner _scanner;
    protected Properties _props;

    public Parser() {
        this(new Scanner());
    }

    public Parser(Properties props) {
        this(new Scanner(props), props);
    }

    public Parser(Scanner scanner) {
        this(scanner, scanner.getProperties());
    }

    public Parser(Scanner scanner, Properties props) {
        _scanner = scanner;
        _props   = props;
    }

    public Scanner getScanner() { return _scanner; }

    public Properties getProperties() { return _props; }
    public String getProperty(String key) { return _props.getProperty(key); }
    //public String setProperty(String key, String value) { _props.setProperty(key, value); }

    public int getToken() {
        return _scanner.getToken();
    }
    public String getValue() {
        return _scanner.getValue();
    }
    public int getLinenum() {
        return _scanner.getLinenum();
    }
    public int getColumn() {
        return _scanner.getColumn();
    }
    public int scan() {
        return _scanner.scan();
    }

    public String getFilename() {
        return _scanner.getFilename();
    }
    public void setFilename(String filename) {
        _scanner.setFilename(filename);
    }

    public void reset(String input, int linenum) {
        _scanner.reset(input, linenum);
        _scanner.scan();
    }


    //abstract public Node parse(String code) throws SyntaxExpression;


    public void syntaxError(String msg) {
        throw new SyntaxException(msg, getFilename(), getLinenum(), getColumn());
    }

    public void semanticError(String msg) {
        throw new SemanticException(msg, getFilename(), getLinenum(), getColumn());
    }
}
