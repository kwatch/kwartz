/**
 *  @(#) ExpressionParser.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz;
import java.util.List;
import java.util.ArrayList;
import java.util.Properties;

public class ExpressionParser extends Parser {

    public ExpressionParser() {
        this(new Scanner());
    }
    public ExpressionParser(Properties props) {
        this(new Scanner(props));
    }
    public ExpressionParser(Scanner scanner) {
        this(scanner, scanner.getProperties());
    }
    public ExpressionParser(Scanner scanner, Properties props) {
        this(scanner, props, true);
    }
    public ExpressionParser(Scanner scanner, Properties props, boolean flagInit) {
        super(scanner, props);
        if (flagInit) _scanner.scan();
    }


    /*
     * BNF:
     *  arguments    ::=  expression | arguments ',' expression | e
     *               ::=  [ expression { ',' expression } ]
     */
    public Expression[] parseArguments() {
        if (getToken() == TokenType.R_PAREN) {
            Expression[] args = {};
            return args;
        }
        List list = new ArrayList();
        Expression expr = parseExpression();
        list.add(expr);
        while (getToken() == TokenType.COMMA) {
            scan();
            expr = parseExpression();
            list.add(expr);
        }
        Expression[] args = new Expression[list.size()];
        list.toArray(args);
        return args;
    }

    /*
     *
     * BNF:
     *  item         ::=  variable | function '(' arguments ')' | '(' expression ')'
     */
    public Expression parseItem() {
        int t = getToken();
        if (t == TokenType.NAME) {
            String name = getValue();
            t = scan();
            if (t != TokenType.L_PAREN)
                return new VariableExpression(name);
            scan();
            Expression[] args = parseArguments();
            if (getToken() != TokenType.R_PAREN)
                syntaxError("missing ')' of function '" + name + "().");
            scan();
            Macro macro = Macro.getInstance(name);
            if (macro != null) {
                if (macro.arity() != args.length)
                    semanticError(name + "(): number of arguments should be " + macro.arity() + " but got " + args.length + " argument(s).");
                return macro.expand(args);
            }
            Function function = Function.getInstance(name);
            if (function != null) {
                if (function.arity() != args.length)
                    semanticError(name + "(): number of arguments should be " + function.arity() + " but got " + args.length + " argument(s).");
                return new FunctionExpression(name, args, function);
            }
            // unregistered function
            return new FunctionExpression(name, args, null);
        }
        else if (t == TokenType.L_PAREN) {
            scan();
            Expression expr = parseExpression();
            if (getToken() != TokenType.R_PAREN)
                syntaxError("')' expected ('(' is not closed by ')').");
            scan();
            return expr;
        }
        assert false;
        return null;
    }

    /*
     *  BNF:
     *    literal      ::=  numeric | string | 'true' | 'false' | 'null' | 'empty' | rawcode-expr
     */
    public Expression parseLiteral() {
        int t = getToken();
        String val;
        switch (t) {
          case TokenType.INTEGER:
            val = getValue();
            scan();
            return new IntegerExpression(Integer.parseInt(val));
          case TokenType.DOUBLE:
            val = getValue();
            scan();
            return new DoubleExpression(Double.parseDouble(val));
          case TokenType.STRING:
            val = getValue();
            scan();
            return new StringExpression(val);
          case TokenType.TRUE:
          case TokenType.FALSE:
            scan();
            return new BooleanExpression(t == TokenType.TRUE);
          case TokenType.NULL:
            scan();
            return new NullExpression();
          case TokenType.EMPTY:
            syntaxError("'empty' is allowed only in right-side of '==' or '!='.");
            return null;
          case TokenType.RAWEXPR:
            val = getValue();
            scan();
            return new RawcodeExpression(val);
          default:
            assert false;
            return null;
        }
    }


    /*
     *  BNF:
     *   factor       ::=  literal | item | factor '[' expression ']' | factor '[:' name ']'
     *                  |  factor '.' property | factor '.' method '(' [ arguments ] ')'
     */
    public Expression parseFactor() {
        int t = getToken();
        Expression expr;
        switch (t) {
          case TokenType.INTEGER:
          case TokenType.DOUBLE:
          case TokenType.STRING:
          case TokenType.TRUE:
          case TokenType.FALSE:
          case TokenType.NULL:
          case TokenType.EMPTY:
          case TokenType.RAWEXPR:
            expr = parseLiteral();
            return expr;

          case TokenType.NAME:
          case TokenType.L_PAREN:
            expr = parseItem();
            while (true) {
                t = getToken();
                if (t == TokenType.L_BRACKET) {
                    scan();
                    Expression expr2 = parseExpression();
                    if (getToken() != TokenType.R_BRACKET)
                        syntaxError("']' expected ('[' is not closed by ']').");
                    scan();
                    expr = new IndexExpression(TokenType.ARRAY, expr, expr2);
                }
                else if (t == TokenType.L_BRACKETCOLON) {
                    scan();
                    if (getToken() != TokenType.NAME)
                        syntaxError("'[:' requires a word following.");
                    String word = getValue();
                    scan();
                    if (getToken() != TokenType.R_BRACKET)
                        syntaxError("'[:' is not closed by ']'.");
                    scan();
                    expr = new IndexExpression(TokenType.HASH, expr, new StringExpression(word));
                }
                else if (t == TokenType.PERIOD) {
                    scan();
                    if (getToken() != TokenType.NAME)
                        syntaxError("'.' requires a property or method name following.");
                    String name = getValue();
                    scan();
                    if (getToken() == TokenType.L_PAREN) {
                        scan();
                        Expression[] args = parseArguments();
                        if (getToken() != TokenType.R_PAREN)
                            syntaxError("method '" + name + "(' is not closed by ')'.");
                        scan();
                        expr = new MethodExpression(expr, name, args);
                    } else {
                        expr = new PropertyExpression(expr, name);
                    }
                }
                else {
                    break;  // escape 'while(true)' loop
                }
            }
            return expr;

          default:
            syntaxError("'" + TokenType.tokenText(t) + "': unexpected token.");
            return null;
        }
    }


    /*
     * BNF:
     *  unary        ::=  factor | '+' factor | '-' factor | '!' factor
     *               ::=  [ '+' | '-' | '!' ] factor
     */
    public Expression parseUnary() {
        int t = getToken();
        int unary_t = 0;
        Expression expr;
        if      (t == TokenType.ADD) unary_t = TokenType.PLUS;
        else if (t == TokenType.SUB) unary_t = TokenType.MINUS;
        else if (t == TokenType.NOT) unary_t = TokenType.NOT;
        if (unary_t > 0) {
            scan();
            Expression factor = parseFactor();
            expr = new UnaryExpression(unary_t, factor);
        } else {
            expr = parseFactor();
        }
        return expr;
    }


    /*
     *  BNF:
     *    term         ::=  unary | term * factor | term '/' factor | term '%' factor
     *                 ::=  unary { ('*' | '/' | '%') factor }
     */
    public Expression parseTerm() {
        Expression expr = parseUnary();
        int t;
        while ((t = getToken()) == TokenType.MUL || t == TokenType.DIV || t == TokenType.MOD) {
            scan();
            Expression expr2 = parseFactor();
            expr = new ArithmeticExpression(t, expr, expr2);
        }
        return expr;
    }


    /*
     * BNF:
     *   arith        ::=  term | arith '+' term | arith '-' term | arith '.+' term
     *                ::=  term { ('+' | '-' | '.+') term }
     */
    public Expression parseArithmetic() {
        Expression expr = parseTerm();
        int t;
        while ((t = getToken()) == TokenType.ADD || t == TokenType.SUB || t == TokenType.CONCAT) {
            scan();
            Expression expr2 = parseTerm();
            if (t == TokenType.CONCAT)
                expr = new ConcatenationExpression(t, expr, expr2);
            else
                expr = new ArithmeticExpression(t, expr, expr2);
        }
        return expr;
    }


    /*
     *  BNF:
     *    relational-op   ::=  '==' |  '!=' |  '>' |  '>=' |  '<' |  '<='
     *    relational      ::=  arith | arith relational-op arith | arith '==' 'empty' | arith '!=' 'empty'
     *                    ::=  arith [ relational-op arith ] | arith ('==' | '!=') 'empty'
     */
    public Expression parseRelational() {
        Expression expr = parseArithmetic();
        int t;
        while ((t = getToken()) == TokenType.EQ || t == TokenType.NE
               || t == TokenType.GT || t == TokenType.GE
               || t == TokenType.LT || t == TokenType.LE) {
            scan();
            if (getToken() == TokenType.EMPTY || (getToken() == TokenType.NAME && getValue().equals("empty"))) {
                if (t == TokenType.EQ) {
                    scan();
                    expr = new EmptyExpression(TokenType.EMPTY, expr);
                } else if (t == TokenType.NE) {
                    scan();
                    expr = new EmptyExpression(TokenType.NOTEMPTY, expr);
                } else {
                    syntaxError("'empty' is allowed only at the right-side of '==' or '!='.");
                }
            }
            else {
                Expression expr2 = parseArithmetic();
                expr = new RelationalExpression(t, expr, expr2);
            }
        }
        return expr;
    }


    /*
     *  BNF:
     *    logical-and  ::=  relational | logical-and '&&' relational
     *                 ::=  relational { '&&' relational }
     */
    public Expression parseLogicalAnd() {
        Expression expr = parseRelational();
        int t;
        while ((t = getToken()) == TokenType.AND) {
            scan();
            Expression expr2 = parseRelational();
            expr = new LogicalAndExpression(expr, expr2);
        }
        return expr;
    }


    /*
     * BNF:
     *  logical-or   ::=  logical-and | logical-or '||' logical-and
     *               ::=  logical-and { '||' logical-and }
     */
    public Expression parseLogicalOr() {
        Expression expr = parseLogicalAnd();
        int t;
        while ((t = getToken()) == TokenType.OR) {
            scan();
            Expression expr2 = parseLogicalAnd();
            expr = new LogicalOrExpression(expr, expr2);
        }
        return expr;
    }


    /*
     *  BNF:
     *    conditional  ::=  logical-or | logical-or '?' expression ':' conditional
     *                 ::=  logical-or [ '?' expression ':' conditional ]
     */
    public Expression parseConditional() {
        Expression expr = parseLogicalOr();
        int t;
        if ((t = getToken()) == TokenType.CONDITIONAL) {
            scan();
            Expression expr2 = parseExpression();
            if (getToken() != TokenType.COLON)
                syntaxError("':' expected ('?' requires ':').");
            scan();
            Expression expr3 = parseConditional();
            expr = new ConditionalExpression(expr, expr2, expr3);
        }
        return expr;
    }


    /*
     *  BNF:
     *    assign-op    ::=  '=' | '+=' | '-=' | '*=' | '/=' | '%=' | '.+='
     *    assignment   ::=  conditional | assign-op assignment
     */
    public Expression parseAssignment() {
        Expression expr = parseConditional();
        int op = getToken();
        if (    op == TokenType.ASSIGN || op == TokenType.ADD_TO ||  op == TokenType.SUB_TO
            ||  op == TokenType.MUL_TO || op == TokenType.DIV_TO ||  op == TokenType.MOD_TO
            ||  op == TokenType.CONCAT_TO) {
            if (! isLhs(expr))
                semanticError("invalid assignment.");
            scan();
            Expression expr2 = parseAssignment();
            expr = new AssignmentExpression(op, expr, expr2);
        }
        return expr;
    }

    protected boolean isLhs(Expression expr) {
        switch (expr.getToken()) {
          case TokenType.VARIABLE:
          case TokenType.ARRAY:
          case TokenType.HASH:
          case TokenType.PROPERTY:
            return true;
          default:
            return false;
        }
    }


    /*
     *  BNF:
     *    expression   ::=  assignment
     */
    public Expression parseExpression() {
        return parseAssignment();
    }


    /*
     *
     */
    public Expression parse(String expr_code) {
        _scanner.reset(expr_code);
        _scanner.scan();
        Expression expr = parseExpression();
        if (_scanner.getToken() != TokenType.EOF) {
            syntaxError("Expression is not ended.");
        }
        return expr;
    }
}
