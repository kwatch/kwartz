/**
 *  @(#) DefaultCompiler.java
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
import java.io.IOException;

public class DefaultCompiler extends Compiler {
    private ExpressionParser  _exprParser;
    private StatementParser   _stmtParser;
    private DeclarationParser _declParser;
    private Converter         _converter;
    private List              _stmtList  = new ArrayList();
    private List              _declList  = new ArrayList();
    private Map               _elemTable = new HashMap();
    private BlockStatement    _pdataBlock;
    private Properties        _props;

    public DefaultCompiler() {
        this(new Properties(Configuration.defaults));
    }
    public DefaultCompiler(Properties props) {
        _props = props;
        _converter  = new DefaultConverter(_props);
        _declParser = new DeclarationParser(_props);
        _stmtParser = _declParser.getStatementParser();
        _exprParser = _stmtParser.getExpressionParser();
    }


    public Template compileString(String pdata, String plogic, String elemdecl, String pdataFilename, String plogicFilename, String elemdeclFilename) {
        // convert elemdecl
        List elemList = null;
        Map elementTable = null;
        if (elemdecl != null) {
            _converter.setFilename(elemdeclFilename);
            _converter.convert(elemdecl);
            elemList = _converter.getElementList();
            elementTable = Element.createElementTable(elemList);
        }

        // convert pdata
        Statement[] stmts = null;
        if (pdata != null) {
            _converter.setFilename(pdataFilename);
            stmts = _converter.convert(pdata);
            elemList = _converter.getElementList();
            if (elementTable == null)
                elementTable = Element.createElementTable(elemList);
            else
                Element.addElementList(elementTable, elemList);
        }

        // parse plogic
        if (plogic != null) {
            _declParser.setFilename(plogicFilename);
            List declList = _declParser.parse(plogic);
            Element.mergeDeclarationList(elementTable, declList);
        }

        // create block statement
        BlockStatement blockStmt = new BlockStatement(stmts);

        // expand
        Expander expander = new DefaultExpander(elementTable, _props);
        expander.expand(blockStmt, null);

        // return template
        return new Template(blockStmt);
    }


    public void addPresentationLogic(String plogic, String filename) {
        _declParser.setFilename(filename);
        List declList = _declParser.parse(plogic);
        _declList.addAll(declList);
    }

    public void addPresentationData(String pdata, String filename) {
        _addPresentationData(pdata, filename, true);
    }

    public void addElementDefinition(String pdata, String filename) {
        _addPresentationData(pdata, filename, false);
    }

    private void _addPresentationData(String pdata, String filename, boolean addStatement) {
        _converter.setFilename(filename);
        Statement[] stmts = _converter.convert(pdata);
        if (addStatement)
            for (int i = 0; i < stmts.length; i++)
                _stmtList.add(stmts[i]);
        List elemList = _converter.getElementList();
        Element.addElementList(_elemTable, elemList);
    }

    public Template getTemplate() {
        // merge element table and declaration list
        Element.mergeDeclarationList(_elemTable, _declList);
        // create block statement
        BlockStatement blockStmt = new BlockStatement(_stmtList);
        // expand @stag, @cont, and @etag
        Expander expander = new DefaultExpander(_elemTable);
        expander.expand(blockStmt, null);
        // return template
        return new Template(blockStmt);
    }

}
