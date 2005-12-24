/**
 *  @(#) Compiler.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz;

//public interface Compiler {
//    public Template compileString(String pdata, String plogic);
//    public Template compileString(String pdata, String plogic, String pdataFilename, String plogicFilename);
//    public Template compileFile(String pdataFilename, String plogicFilename) throws IOException;
//    public Template compileFile(String pdataFilename, String plogicFilename, String charset) throws IOException;
//    public void addPresentationLogic(String plogic);
//    public void addPresentationLogic(String plogic, String filename);
//    public void addPresentationData(String pdata);
//    public void addPresentationData(String pdata, String filename);
//    public Template getTemplate();
//
//}

import java.io.IOException;

abstract public class Compiler {

    abstract public Template compileString(String pdata, String plogic, String elemdecl,
                                           String pdataFilename, String plogicFilename, String elemdeclFilename);
    public Template compileString(String pdata, String plogic, String pdataFilename, String plogicFilename) {
        return compileString(pdata, plogic, null, pdataFilename, plogicFilename, null);
    }
    public Template compileString(String pdata, String plogic, String elemdecl) {
        return compileString(pdata, plogic, elemdecl, null, null, null);
    }
    public Template compileString(String pdata, String plogic) {
        return compileString(pdata, plogic, null, null, null, null);
    }

    public Template compileFile(String pdataFilename, String plogicFilename, String elemdeclFilename, String charset) throws IOException {
        // read files
        String pdata    = Utility.readFile(pdataFilename, charset);
        String plogic   = Utility.readFile(plogicFilename, charset);
        String elemdecl = Utility.readFile(elemdeclFilename, charset);
        return compileString(pdata, plogic, elemdecl, pdataFilename, plogicFilename, elemdeclFilename);
    }
    public Template compileFile(String pdataFilename, String plogicFilename, String charset) throws IOException {
        return compileFile(pdataFilename, plogicFilename, null, charset);
    }
    public Template compileFile(String pdataFilename, String plogicFilename) throws IOException {
        String charset = System.getProperty("file.encoding");
        return compileFile(pdataFilename, plogicFilename, null, charset);
    }

    abstract public void addPresentationLogic(String plogic, String filename);
    public void addPresentationLogic(String plogic) {
        addPresentationLogic(plogic, null);
    }
    public void addPresentationLogicFile(String filename, String charset) throws IOException {
        String plogic = Utility.readFile(filename, charset);
        addPresentationLogic(plogic, filename);
    }

    abstract public void addPresentationData(String pdata, String filename);
    public void addPresentationData(String pdata) {
        addPresentationData(pdata, null);
    }
    public void addPresentationDataFile(String filename, String charset) throws IOException {
        String pdata = Utility.readFile(filename, charset);
        addPresentationData(pdata, null);
    }

    abstract public void addElementDefinition(String elemdef, String filename);
    public void addElementDefinition(String elemdef) {
        addElementDefinition(elemdef, null);
    }
    public void addElementDefinitionFile(String filename, String charset) throws IOException {
        String elemdef = Utility.readFile(filename, charset);
        addElementDefinition(elemdef, filename);
    }

    abstract public Template getTemplate();

}
