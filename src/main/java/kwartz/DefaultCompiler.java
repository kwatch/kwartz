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

import kwartz.node.BlockStatement;
import kwartz.node.Statement;

/**
 * default template compiler
 * @author kwatch
 *
 * ex.
 * <pre>
 *  kwartz.Compiler compiler = new DefaultComiler();
 *  compiler.addPresentationData
 *
 * </pre>
 */
public class DefaultCompiler implements Compiler {
    //private ExpressionParser  _exprParser;
    //private StatementParser   _stmtParser;
    private DeclarationParser _declParser;
    private Converter         _converter;
    private List              _stmtList  = new ArrayList();
    private List              _declList  = new ArrayList();
    private Map               _elemTable = new HashMap();
    //private BlockStatement    _pdataBlock;
    private Properties        _props;

    public DefaultCompiler() {
        this(new Properties(Configuration.defaults));
    }
    public DefaultCompiler(Properties props) {
        _props = props;
        _converter  = new DefaultConverter(_props);
        _declParser = new DeclarationParser(_props);
        //_stmtParser = _declParser.getStatementParser();
        //_exprParser = _stmtParser.getExpressionParser();
    }

    public Template compileString(String pdata, String plogic, String elemdecl) {
        return compileString(pdata, plogic, elemdecl, null, null, null);
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

        // expand @stag, @cont, and @etag
        Expander expander = new DefaultExpander(elementTable, _props);
        expander.expand(blockStmt, null);

        // return template
        return new Template(blockStmt);
    }

    
    public Template compileFile(String pdataFilename, String plogicFilename, String elemdeclFilename, String charset) throws IOException {
        // read files
        String pdata    = Utility.readFile(pdataFilename, charset);
        String plogic   = Utility.readFile(plogicFilename, charset);
        String elemdecl = Utility.readFile(elemdeclFilename, charset);
        return compileString(pdata, plogic, elemdecl, pdataFilename, plogicFilename, elemdeclFilename);
    }
    public Template compileFile(String pdataFilename, String plogicFilename, String elemdeclFilename) throws IOException {
        String charset = System.getProperty("file.encoding");
        return compileFile(pdataFilename, plogicFilename, elemdeclFilename, charset);
    }



    private void _addPresentationData(String pdata, String filename, boolean addStatement) {
        _converter.setFilename(filename);
        Statement[] stmts = _converter.convert(pdata);
        if (addStatement) {
            for (int i = 0; i < stmts.length; i++) {
                _stmtList.add(stmts[i]);
            }
        }
        List elemList = _converter.getElementList();
        Element.addElementList(_elemTable, elemList);
    }


    public void addPresentationLogic(String plogic, String filename) {
        _declParser.setFilename(filename);
        List declList = _declParser.parse(plogic);
        _declList.addAll(declList);
    }
    public void addPresentationLogic(String plogic) {
        addPresentationLogic(plogic, null);
    }
    public void addPresentationLogicFile(String filename, String charset) throws IOException {
        String plogic = Utility.readFile(filename, charset);
        addPresentationLogic(plogic, filename);
    }

    public void addPresentationData(String pdata, String filename) {
        _addPresentationData(pdata, filename, true);
    }
    public void addPresentationData(String pdata) {
        addPresentationData(pdata, null);
    }
    public void addPresentationDataFile(String filename, String charset) throws IOException {
        String pdata = Utility.readFile(filename, charset);
        addPresentationData(pdata, null);
    }

    public void addElementDefinition(String pdata, String filename) {
        _addPresentationData(pdata, filename, false);
    }
    public void addElementDefinition(String elemdef) {
        addElementDefinition(elemdef, null);
    }
    public void addElementDefinitionFile(String filename, String charset) throws IOException {
        String elemdef = Utility.readFile(filename, charset);
        addElementDefinition(elemdef, filename);
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
