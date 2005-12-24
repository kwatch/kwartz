/**
 *  @(#) DeclarationParser.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz;

import java.util.List;
import java.util.ArrayList;
import java.util.Map;
import java.util.HashMap;
import java.util.Properties;

public class DeclarationParser extends Parser {

    private StatementParser  _stmtParser;
    private ExpressionParser _exprParser;

    public DeclarationParser() {
        this(new Scanner());
    }

    public DeclarationParser(Properties props) {
        this(new Scanner(props));
    }

    public DeclarationParser(Scanner scanner) {
        this(scanner, scanner.getProperties());
    }
    public DeclarationParser(Scanner scanner, Properties props) {
        this(scanner, props, true);
    }
    public DeclarationParser(Scanner scanner, Properties props, boolean flagInit) {
        super(scanner, props);
        _stmtParser = new StatementParser(scanner, props, false);
        _exprParser = _stmtParser.getExpressionParser();
        if (flagInit) _scanner.scan();
    }

    public StatementParser getStatementParser()   { return _stmtParser; }
    public ExpressionParser getExpressionParser() { return _exprParser; }

    public Properties getProperties() { return _props; }
    public String getProperty(String key) { return _props.getProperty(key); }
    //public String setProperty(String key, String value) { _props.setProperty(key, value); }


    public String getFilename() { return _stmtParser.getFilename(); }
    public void setFilename(String filename) { _stmtParser.setFilename(filename); }

    public List parse(String input) {
        _scanner.reset(input, 1);
        scan();
        List decls = parsePresentationDeclarations();
        if (getToken() != TokenType.EOF) {
            syntaxError("'" + TokenType.inspect(getToken(), getValue()) + "': unexpected token.");
        }
        return decls;
    }

    public List parsePresentationDeclarations() {
        List decls = new ArrayList();
        while (getToken() == TokenType.SHARP) {
            PresentationDeclaration decl = parsePresentationDeclaration();
            decls.add(decl);
        }
        return decls;
    }

    public PresentationDeclaration parsePresentationDeclaration() {
        assert getToken() == TokenType.SHARP;
        String name;
        List nameList = new ArrayList();
        int i = 0;
        while (true) {
            i += 1;
            if (getToken() != TokenType.SHARP)
                syntaxError("'#' required.");
            scan();
            if (getToken() != TokenType.NAME)
                syntaxError("'#': marking name required.");
            name = getValue();
            nameList.add(name);
            scan();
            if (getToken() != TokenType.COMMA) break;
            scan();
        }
        if (getToken() != TokenType.L_CURLY)
            syntaxError("presentation declaration '#" + name + "' requires '{'.");
        scan();
        PresentationDeclaration decl = parseDeclarationParts();
        String[] names = new String[nameList.size()];
        nameList.toArray(names);
        decl.names = names;
        if (getToken() != TokenType.R_CURLY)
            syntaxError("presentation declaration '#" + name + "' is not closed by '}'."
                        + "(token=" + TokenType.inspect(getToken(),getValue()) + ")");
        scan();
        return decl;
    }

    public static final Object PART_TAGNAME = "tagname";
    public static final Object PART_REMOVE  = "remove";
    public static final Object PART_ATTRS   = "attrs";
    public static final Object PART_APPEND  = "append";
    public static final Object PART_VALUE   = "value";
    public static final Object PART_PLOGIC  = "plogic";

    public static final Map _parts = new HashMap();
    static {
        _parts.put("tagname", PART_TAGNAME);
        _parts.put("remove",  PART_REMOVE);
        _parts.put("attrs",   PART_ATTRS);
        _parts.put("append",  PART_APPEND);
        _parts.put("value",   PART_VALUE);
        _parts.put("plogic",  PART_PLOGIC);
    }

    public PresentationDeclaration parseDeclarationParts() {
        PresentationDeclaration decl = new PresentationDeclaration();
        while (getToken() == TokenType.NAME) {
            Object part = _parts.get(getValue());
            if (part == null)
                syntaxError("part name required but got '" + getValue() + "'.");
            scan();
            if (getToken() != TokenType.COLON)
                syntaxError("'" + part + "' part requires ':'.");
            scan();
            if (false) /* nothing */ ;
            else if (part == PART_TAGNAME) parseTagnamePart(decl);
            else if (part == PART_REMOVE)  parseRemovePart(decl);
            else if (part == PART_ATTRS)   parseAttrsPart(decl);
            else if (part == PART_APPEND)  parseAppendPart(decl);
            else if (part == PART_VALUE)   parseValuePart(decl);
            else if (part == PART_PLOGIC)  parsePlogicPart(decl);
            else
              assert false;
        }
        return decl;
    }

    private void parseTagnamePart(PresentationDeclaration decl) {
        Expression expr = _exprParser.parseExpression();
        if (getToken() != TokenType.SEMICOLON)
          syntaxError("tagname part requires ';'.");
        scan();
        decl.tagname = expr;
    }

    private void parseRemovePart(PresentationDeclaration decl) {
        while (true) {
            Expression expr = _exprParser.parseExpression();
            if (expr.getToken() != TokenType.STRING)
              syntaxError("remove part requires attribute name.");
            String aname = ((StringExpression)expr).getValue();
            decl.remove.add(aname);
            if (getToken() != TokenType.COMMA) break;
            scan();
        }
        if (getToken() != TokenType.SEMICOLON)
          syntaxError("remove part requires ';'.");
        scan();
    }

    private void parseAttrsPart(PresentationDeclaration decl) {
        while (true) {
            Expression expr = _exprParser.parseExpression();
            if (expr.getToken() != TokenType.STRING)
              syntaxError("attrs part requires attribute name.");
            String aname = ((StringExpression)expr).getValue();
            expr = _exprParser.parseExpression();
            decl.attrs.put(aname, expr);
            if (getToken() != TokenType.COMMA) break;
            scan();
        }
        if (getToken() != TokenType.SEMICOLON)
          syntaxError("attrs part requires ';'.");
        scan();
    }

    private void parseAppendPart(PresentationDeclaration decl) {
        while (true) {
            Expression expr = _exprParser.parseExpression();
            decl.append.add(expr);
            if (getToken() != TokenType.COMMA) break;
            scan();
        }
        if (getToken() != TokenType.SEMICOLON)
          syntaxError("append part requires ';'.");
        scan();
    }

    private void parseValuePart(PresentationDeclaration decl) {
        Expression expr = _exprParser.parseExpression();
        decl.value = expr;
        if (getToken() != TokenType.SEMICOLON)
          syntaxError("value part requires ';'.");
        scan();
    }

    private void parsePlogicPart(PresentationDeclaration decl) {
        if (getToken() != TokenType.L_CURLY)
          syntaxError("plogic part requires '{'.");
        BlockStatement stmt = (BlockStatement)_stmtParser.parseBlockStatement();
        decl.plogic = stmt;
    }

}
