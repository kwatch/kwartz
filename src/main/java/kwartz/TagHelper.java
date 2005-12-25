/**
 *  @(#) TagHelper.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz;

import java.util.List;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.regex.Pattern;
import java.util.regex.Matcher;
import java.util.Properties;

import kwartz.node.Expression;
import kwartz.node.PrintStatement;
import kwartz.node.Statement;
import kwartz.node.StringExpression;

public class TagHelper {
    private StatementParser  _stmtParser;
    private ExpressionParser _exprParser;
    private Properties _props;  // for future use


    public TagHelper() {
        this(new Properties(Configuration.defaults));
    }

    public TagHelper(Properties props) {
        _props = props;
        _stmtParser = new StatementParser();
        _exprParser = _stmtParser.getExpressionParser();
    }


    public String getFilename() {
        return _stmtParser.getFilename();
        //return _exprParser.getFilename();
    }


    public void setFilename(String filename) {
        _stmtParser.setFilename(filename);
        //_exprParser.setFilename(filename);
    }


    public Expression parseExpression(String str, int linenum) {
        _exprParser.reset(str, linenum);
        Expression expr = _exprParser.parseExpression();
        if (_exprParser.getToken() != TokenType.EOF) {
            String msg = "'" + str + "': invalid expression.";
            throw new ConvertionException(msg, _exprParser.getFilename(), linenum);
        }
        return expr;
    }


    public Statement parseExpressionStatement(String str, int linenum) {
        _stmtParser.reset(str, linenum);
        Statement stmt = _stmtParser.parseExpressionStatement();
        //assert _stmtParser.getToken() == TokenType.EOF;
        if (_stmtParser.getToken() != TokenType.EOF) {
            String msg = "'" + str + "': invalid expression statement.";
            throw new ConvertionException(msg, _stmtParser.getFilename(), linenum);
        }
        return stmt;
    }


    public PrintStatement createTagPrintStatement(Tag tag, boolean tagDelete) {
        PrintStatement stmt;
        if (tagDelete) {
            String s = tag.is_begline && tag.is_endline ? "" : tag.before_space + tag.after_space;
            Expression[] args = { new StringExpression(s) };
            stmt = new PrintStatement(args);
        } else {
            stmt = buildPrintStatement(tag);
        }
        return stmt;
    }



    public PrintStatement createPrintStatement(String str, int linenum) {
        Expression[] args = expandEmbeddedExpression(str, linenum);
        return new PrintStatement(args);
    }


    public static final String EMBED_PATTERN = "@\\{(.*?)\\}@";

    public Expression[] expandEmbeddedExpression(String str, int linenum) {
        final Pattern embedPattern = Pattern.compile(EMBED_PATTERN);
        List list = null;
        int index = 0;
        Matcher m = embedPattern.matcher(str);
        while (m.find()) {
            if (list == null) list = new ArrayList();
            String front = str.substring(index, m.start());
            if (front != null && front.length() > 0) {
                list.add(new StringExpression(front));
                for (int i = 0; i < front.length(); i++) {
                    if (str.charAt(i) == '\n') linenum++;
                }
            }
            if (m.group(1).length() > 1) {
                list.add(parseExpression(m.group(1), linenum));
            }
            index = m.end();
        }
        Expression[] exprs;
        if (list != null) {
            String s = str.substring(index);
            if (s != null && s.length() > 0) list.add(new StringExpression(s));
            exprs = new Expression[list.size()];
            list.toArray(exprs);
        } else {
            exprs = new Expression[1];
            exprs[0] = new StringExpression(str);
        }
        return exprs;
    }


    public PrintStatement buildPrintStatement(Tag tag) {
        StringBuffer sb = new StringBuffer();
        sb.append(tag.before_space);
        sb.append(tag.is_etag ? "</" : "<");
        sb.append(tag.tagname);
        List list = new ArrayList();
        if (tag.attrs != null) {
            for (Iterator it = tag.attrs.iterator(); it.hasNext(); ) {
                Attr a = (Attr)it.next();
                String aspace = a.space;
                String aname  = a.name;
                Object avalue = a.value;
                sb.append(aspace);
                sb.append(aname);
                sb.append("=\"");
                if (avalue instanceof Expression) {
                    list.add(new StringExpression(sb.toString()));
                    sb.delete(0, sb.length());  // clear
                    list.add(avalue);
                } else {
                    assert avalue instanceof String;
                    String str = (String)avalue;
                    if (str.indexOf('@') < 0) {         // ATTR_PATTERN
                        sb.append(str);
                    } else {
                        Expression[] exprs = expandEmbeddedExpression(str, tag.linenum);
                        for (int i = 0; i < exprs.length; i++) {
                            if (exprs[i].getToken() == TokenType.STRING) {
                                sb.append(((StringExpression)exprs[i]).getValue());
                            } else {
                                list.add(new StringExpression(sb.toString()));
                                sb.delete(0, sb.length());  // clear
                                list.add(exprs[i]);
                            }
                        }
                    }
                }
                sb.append("\"");
            }
        }
        //
        if (tag.append_exprs != null) {
            list.add(new StringExpression(sb.toString()));
            list.addAll(tag.append_exprs);
            sb.delete(0, sb.length());  // clear
        }
        sb.append(tag.extra_space);
        sb.append(tag.is_empty ? "/>" : ">");
        sb.append(tag.after_space);
        list.add(new StringExpression(sb.toString()));
        //
        Expression[] args = new Expression[list.size()];
        list.toArray(args);
        return new PrintStatement(args);
    }

}
