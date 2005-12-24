/**
 *  @(#) Kwartz.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz;

import java.util.Map;
import java.util.HashMap;
import java.util.Properties;
import java.util.Enumeration;
import java.io.IOException;

public class Kwartz {

    private Map _cache;
    private Properties _props;
    //private Map _functions;

    public Kwartz() {
        this(null);
    }
    public Kwartz(Properties props) {
        _cache     = new HashMap();  // or new WeakHashMap();
        _props     = new Properties(Configuration.defaults);
        //_functions = new HashMap(Configuration.functions);
        if (props != null) {
            for (Enumeration en = props.propertyNames(); en.hasMoreElements(); ) {
                String pname = (String)en.nextElement();
                String pvalue = props.getProperty(pname);
                _props.setProperty(pname, pvalue);
            }
            Configuration.registerMacros(props);
            Configuration.registerFunctions(props);
        }
    }

    public Properties getProperties() { return _props; }
    public String getProperty(String key) { return _props.getProperty(key); }
    //public String setProperty(String key, String value) { _props.setProperty(key, value); }


    public Template getTemplate(Object key, String pdataFilename, String plogicFilename, String elemdeclFilename, String charset) throws IOException {
        Template template = (Template)_cache.get(key);
        if (template == null) {
            synchronized(_cache) {
                if (template == null) {
                    template = compileFile(pdataFilename, plogicFilename, elemdeclFilename, charset);
                    addTemplate(key, template);
                }
            }
        }
        return template;
    }

    public Template compileFile(String pdataFilename, String plogicFilename, String elemdeclFilename, String charset) throws IOException {
        Compiler compiler = new DefaultCompiler(_props);
        Template template = compiler.compileFile(pdataFilename, plogicFilename, elemdeclFilename, charset);
        Optimizer optimizer = new Optimizer(_props);
        optimizer.optimize(template.getBlockStatement());
        return template;
    }

    public Template compileString(String pdata, String plogic, String elemdecl, String charset) throws IOException {
        Compiler compiler = new DefaultCompiler(_props);
        Template template = compiler.compileString(pdata, plogic, elemdecl, charset);
        Optimizer optimizer = new Optimizer(_props);
        optimizer.optimize(template.getBlockStatement());
        return template;
    }


    public Template getTemplate(Object key) {
        return (Template)_cache.get(key);
    }

    public void addTemplate(Object key, Template template) {
        _cache.put(key, template);
    }
}
