/**
 *  @(#) Template.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz;

import java.util.List;
import java.util.ArrayList;
import java.util.Map;
import java.io.Writer;
import java.io.StringWriter;
import java.io.IOException;

import kwartz.node.BlockStatement;

public class Template {

    private BlockStatement _blockStmt;
    private List _pdataFilenameList = null;
    private List _plogicFilenameList = null;
    private List _elemdefFilenameList = null;

    public Template(BlockStatement blockStmt) {
        _blockStmt = blockStmt;
    }

    public BlockStatement getBlockStatement() { return _blockStmt; }

    public String execute(Map context) throws IOException {
        StringWriter writer = null;
        try {
            writer = new StringWriter();
            _blockStmt.execute(context, writer);
            String s = writer.toString();
            return s;
        } finally {
            if (writer != null) writer.close();
        }
    }

    public void execute(Map context, Writer writer) throws IOException {
        _blockStmt.execute(context, writer);
    }

    public void addPresentationDataFilename(String filename) {
        if (_pdataFilenameList == null)
            _pdataFilenameList = new ArrayList();
        _pdataFilenameList.add(filename);
    }

    public void addPresentationLogicFilename(String filename) {
        if (_plogicFilenameList == null)
            _plogicFilenameList = new ArrayList();
        _plogicFilenameList.add(filename);
    }

    public void addElementDefinitionFilename(String filename) {
        if (_elemdefFilenameList == null)
            _elemdefFilenameList = new ArrayList();
        _elemdefFilenameList.add(filename);
    }
}
