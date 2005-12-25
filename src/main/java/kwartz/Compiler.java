/**
 *  @(#) Compiler.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz;

import java.io.IOException;

public interface Compiler {
    public Template compileString(String pdata, String plogic, String elemdecl);
    public Template compileString(String pdata, String plogic, String elemdecl, String pdataFilename, String plogicFilename, String elemdeclFilename);
    public Template compileFile(String pdataFilename, String plogicFilename, String elemdeclFilename) throws IOException;
    public Template compileFile(String pdataFilename, String plogicFilename, String elemdeclFilename, String charset) throws IOException;
    public void addPresentationLogic(String plogic);
    public void addPresentationLogic(String plogic, String filename);
    public void addPresentationLogicFile(String filename, String charset) throws IOException;
    public void addPresentationData(String pdata);
    public void addPresentationData(String pdata, String filename);
    public void addPresentationDataFile(String filename, String charset) throws IOException;
    public void addElementDefinition(String elemdef, String filename);
    public void addElementDefinition(String elemdef);
    public void addElementDefinitionFile(String filename, String charset) throws IOException;
    public Template getTemplate();
}
