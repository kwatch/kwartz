/**
 *  @(#) DirectiveHandler.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz;

import java.util.List;
import java.util.Iterator;
import java.util.regex.Pattern;
import java.util.regex.Matcher;
import java.util.Properties;
import java.io.FileReader;
import java.io.FileNotFoundException;
import java.io.UnsupportedEncodingException;
import java.io.IOException;

public class DirectiveHandler {
    private DefaultConverter _converter;
    private TagHelper _helper;
    private Properties _props;
    private String _even;
    private String _odd;

    public DirectiveHandler(DefaultConverter converter, Properties props) {
        _converter  = converter;
        _helper     = new TagHelper();
        _props      = props;
        _even       = _props.getProperty("kwartz.even");
        _odd        = _props.getProperty("kwartz.odd");
    }

    public void handleMarkDirective(List stmtList, Tag stag, Tag etag, List bodyStmtList) {
        assert stag.directive_name.equals("mark");
        String marking = stag.directive_arg;
        if (stag.attrs != null) {
            for (Iterator it = stag.attrs.iterator(); it.hasNext(); ) {
                Attr attr = (Attr)it.next();
                String avalue = (String)attr.value;
                Expression[] exprs = _helper.expandEmbeddedExpression(avalue, stag.linenum);
                //Expression[] exprs = _converter.expandEmbeddedExpression(avalue, stag.linenum);
                Expression expr;
                if (exprs.length == 0) {
                    expr = new StringExpression("");
                } else {
                    expr = exprs[0];
                    for (int i = 1; i < exprs.length; i++) {
                        expr = new ConcatenationExpression(expr, exprs[i]);
                    }
                }
                attr.value = expr;
            }
        }
        _converter.addElement(new Element(marking, stag, etag, bodyStmtList));
        stmtList.add(new ExpandStatement(ExpandStatement.ELEMENT, marking));
    }


    public void handleValueDirective(List stmtList, Tag stag, Tag etag, List bodyStmtList) {
        if (etag == null) {
            String msg = "directive '" + stag.directive_name + "' cannot use with empty tag.";
            throw new ConvertionException(msg, _converter.getFilename(), stag.linenum);
        }
        Expression expr = _helper.parseExpression(stag.directive_arg, stag.linenum);
        if (stag.directive_name.equals("Value")) {
            expr = new FunctionExpression("E", new Expression[] { expr });
        } else if (stag.directive_name.equals("VALUE")) {
            expr = new FunctionExpression("X", new Expression[] { expr });
        }
        PrintStatement stmt = new PrintStatement(new Expression[] { expr });
        stmtList.add(bodyStmtList.get(0));                        // first statement
        stmtList.add(stmt);
        stmtList.add(bodyStmtList.get(bodyStmtList.size() - 1));  // last statement
    }


    public void handleForeachDirective(List stmtList, Tag stag, Tag etag, List bodyStmtList) {
        Pattern pat = Pattern.compile("\\A(\\w+)\\s*[:=]\\s*(.*)");
        Matcher m = pat.matcher(stag.directive_arg);
        if (! m.find()) {
            String msg = "'" + stag.directive_name + ":" + stag.directive_arg + "': invalid directive argument.";
            throw new ConvertionException(msg, _converter.getFilename(), stag.linenum);
        }
        String varname = m.group(1);
        String liststr = m.group(2);
        VariableExpression varexpr = new VariableExpression(varname);
        Expression listexpr = _helper.parseExpression(liststr, stag.linenum);
        String counter = !stag.directive_name.equals("foreach") ? varname + "_ctr" : null;
        String toggle  =  stag.directive_name.equals("FOREACH") ? varname + "_tgl" : null;
        //
        if (counter != null) {
            stmtList.add(_helper.parseExpressionStatement(counter + " = 0;", -1));
            bodyStmtList.add(0, _helper.parseExpressionStatement(counter + " += 1;", -1));
        }
        if (toggle != null) {
            String s = toggle + " = " + counter + " % 2 == 0 ? " + _even + " : " + _odd + ";";
            bodyStmtList.add(1, _helper.parseExpressionStatement(s, -1));
        }
        stmtList.add(new ForeachStatement(varexpr, listexpr, new BlockStatement(bodyStmtList)));
    }


    public void handleListDirective(List stmtList, Tag stag, Tag etag, List bodyStmtList) {
        if (etag == null) {
            String msg = "directive '" + stag.directive_name + "' cannot use with empty tag.";
            throw new ConvertionException(msg, _converter.getFilename(), stag.linenum);
        }
        Pattern pat = Pattern.compile("\\A(\\w+)\\s*[:=]\\s*(.*)");
        Matcher m = pat.matcher(stag.directive_arg);
        if (! m.find()) {
            String msg = "'" + stag.directive_name + ":" + stag.directive_arg + "': invalid directive argument.";
            throw new ConvertionException(msg, _converter.getFilename(), stag.linenum);
        }
        String varname = m.group(1);
        String liststr = m.group(2);
        VariableExpression varexpr = new VariableExpression(varname);
        Expression listexpr = _helper.parseExpression(liststr, stag.linenum);
        String counter = !stag.directive_name.equals("list") ? varname + "_ctr" : null;
        String toggle  =  stag.directive_name.equals("LIST") ? varname + "_tgl" : null;
        //
        Object firstStmt = bodyStmtList.remove(0);
        Object lastStmt  = bodyStmtList.remove(bodyStmtList.size() - 1);
        stmtList.add(firstStmt);
        if (counter != null) {
            stmtList.add(_helper.parseExpressionStatement(counter + " = 0;", -1));
            bodyStmtList.add(0, _helper.parseExpressionStatement(counter + " += 1;", -1));
        }
        if (toggle != null) {
            String s = toggle + " = " + counter + " % 2 == 0 ? " + _even + " : " + _odd + ";";
            bodyStmtList.add(1, _helper.parseExpressionStatement(s, -1));
        }
        stmtList.add(new ForeachStatement(varexpr, listexpr, new BlockStatement(bodyStmtList)));
        stmtList.add(lastStmt);
    }


    public void handleWhileDirective(List stmtList, Tag stag, Tag etag, List bodyStmtList) {
        Expression condition = _helper.parseExpression(stag.directive_arg, stag.linenum);
        stmtList.add(new WhileStatement(condition, new BlockStatement(bodyStmtList)));
    }


    public void handleLoopDirective(List stmtList, Tag stag, Tag etag, List bodyStmtList) {
        Expression condition = _helper.parseExpression(stag.directive_arg, stag.linenum);
        if (etag == null) {
            String msg = "directive '" + stag.directive_name + "' cannot use with empty tag.";
            throw new ConvertionException(msg, _converter.getFilename(), stag.linenum);
        }
        Object firstStmt = bodyStmtList.remove(0);
        Object lastStmt  = bodyStmtList.remove(bodyStmtList.size() - 1);
        stmtList.add(firstStmt);
        stmtList.add(new WhileStatement(condition, new BlockStatement(bodyStmtList)));
        stmtList.add(lastStmt);
    }


    public void handleIfDirective(List stmtList, Tag stag, Tag etag, List bodyStmtList) {
        Expression condition = _helper.parseExpression(stag.directive_arg, stag.linenum);
        stmtList.add(new IfStatement(condition, new BlockStatement(bodyStmtList), null));
    }


    public void handleElseifDirective(List stmtList, Tag stag, Tag etag, List bodyStmtList) {
        Expression condition = _helper.parseExpression(stag.directive_arg, stag.linenum);
        Statement stmt = (Statement)stmtList.get(stmtList.size() - 1);
        while (stmt.getToken() == TokenType.IF && ((IfStatement)stmt).getElseStatement() != null) {
            stmt = ((IfStatement)stmt).getElseStatement();
        }
        if (stmt.getToken() != TokenType.IF) {
            String msg = "elseif-directive must be at just after the if-statement or elseif-statement.";
            throw new ConvertionException(msg, _converter.getFilename(), stag.linenum);
        }
        ((IfStatement)stmt).setElseStatement(new IfStatement(condition, new BlockStatement(bodyStmtList), null));
    }


    public void handleElseDirective(List stmtList, Tag stag, Tag etag, List bodyStmtList) {
        Statement stmt = (Statement)stmtList.get(stmtList.size() - 1);
        while (stmt.getToken() == TokenType.IF && ((IfStatement)stmt).getElseStatement() != null) {
            stmt = ((IfStatement)stmt).getElseStatement();
        }
        if (stmt.getToken() != TokenType.IF) {
            String msg = "else-directive must be at just after the if-statement or elseif-statement.";
            throw new ConvertionException(msg, _converter.getFilename(), stag.linenum);
        }
        ((IfStatement)stmt).setElseStatement(new BlockStatement(bodyStmtList));
    }


    public void handleSetDirective(List stmtList, Tag stag, Tag etag, List bodyStmtList) {
        Expression expr = _helper.parseExpression(stag.directive_arg, stag.linenum);
        stmtList.add(new ExpressionStatement(expr));
        stmtList.addAll(bodyStmtList);
    }


    public void handleDummyDirective(List stmtList, Tag stag, Tag etag, List bodyStmtList) {
        // nothing
    }


    public void handleReplaceDirective(List stmtList, Tag stag, Tag etag, List bodyStmtList) {
        _handleReplaceDirective(false, stmtList, stag, etag, bodyStmtList);
    }


    public void handlePlaceholderDirective(List stmtList, Tag stag, Tag etag, List bodyStmtList) {
        _handleReplaceDirective(true,  stmtList, stag, etag, bodyStmtList);
    }


    private void _handleReplaceDirective(boolean inner, List stmtList, Tag stag, Tag etag, List bodyStmtList) {
        Pattern pat = Pattern.compile("\\A(\\w+)(?::(content|element))?\\z");
        Matcher m = pat.matcher(stag.directive_arg);
        if (! m.find()) {
            String msg = "'" + stag.directive_name + ":" + stag.directive_arg + "': invalid directive.";
            throw new ConvertionException(msg, _converter.getFilename(), stag.linenum);
        }
        String name = m.group(1);
        int type = m.group(2) != null && m.group(2).equals("content") ? ExpandStatement.CONTENT : ExpandStatement.ELEMENT;
        if (inner) {
            if (etag == null) {
                String msg = "directive '" + stag.directive_name + "' cannot use with empty tag.";
                throw new ConvertionException(msg, _converter.getFilename(), stag.linenum);
            }
            Object firstStmt = bodyStmtList.remove(0);
            Object lastStmt  = bodyStmtList.remove(bodyStmtList.size() - 1);
            stmtList.add(firstStmt);
            stmtList.add(new ExpandStatement(type, name));
            stmtList.add(lastStmt);
        } else {
            stmtList.add(new ExpandStatement(type, name));
        }
    }


    public void handleIncludeDirective(List stmtList, Tag stag, Tag etag, List bodyStmtList) {
        String basename = stag.directive_arg;
        char firstChar = basename.charAt(0);
        char lastChar  = basename.charAt(basename.length() - 1);
        if (firstChar == '"' && lastChar == '"' || firstChar == '\'' && lastChar == '\'') {
            basename = basename.substring(1, basename.length() - 1);
        }

        // TBI: pathlist
        //    pathlist = @properties[:incdirs] || Kwartz::Config::INCDIRS || ['.']
        //    filename = nil
        //    pathlist.each do |path|
        //       filename = path + '/' + basename
        //       break if test(?f, filename)
        //       filename = nil
        //    end
        String filename = null;
        filename = basename;
        if (filename == null) {
            String msg = "'" + stag.directive_name + ":" + stag.directive_arg + "': include file not found.";
            throw new ConvertionException(msg, _converter.getFilename(), stag.linenum);
        }

        StringBuffer sb = new StringBuffer();
        char[] buf = new char[512];
        FileReader reader = null;
        try {
            reader = new FileReader(filename);
            while (reader.read(buf) >= 0) {
                sb.append(buf);
            }
        } catch (FileNotFoundException ex) {
            throw new ConvertionException(ex.toString(), _converter.getFilename(), stag.linenum);
        } catch (UnsupportedEncodingException ex) {
            throw new ConvertionException(ex.toString(), _converter.getFilename(), stag.linenum);
        } catch (IOException ex) {
            throw new ConvertionException(ex.toString(), _converter.getFilename(), stag.linenum);
        } finally {
            if (reader != null)
              try {
                  reader.close();
              } catch (IOException ignore) { }
        }

        Converter converter = null;
        try {
            converter = (Converter)_converter.getClass().newInstance();
        } catch (IllegalAccessException ex) {
            throw new ConvertionException(ex.toString(), _converter.getFilename(), stag.linenum);
        } catch (InstantiationException ex) {
            throw new ConvertionException(ex.toString(), _converter.getFilename(), stag.linenum);
        }
        converter.setFilename(filename);
        // TBI
        //converter.setPropertyies(_converter.getProperties());
        Statement[] stmts = converter.convert(sb.toString());

        if (stag.directive_name.equals("INCLUDE"))
            stmtList.addAll(bodyStmtList);
        for (int i = 0; i < stmts.length; i++)
            stmtList.add(stmts[i]);
        if (stag.directive_name.equals("Include"))
            stmtList.addAll(bodyStmtList);
        List elements = converter.getElementList();
        for (Iterator it = elements.iterator(); it.hasNext(); ) {
            Element element = (Element)it.next();
            _converter.addElement(element);
        }
    }

}
