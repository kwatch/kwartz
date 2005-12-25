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


/**
 * compile and cache template
 * 
 * ex1.
 * <pre>
 * // compile template
 * Object cacheKey = "file.html";  // use filename of presentation data as cache key
 * String charset = System.getProperty("file.encoding");
 * Template template = kwartz.getTempalte(cacheKey, "file.html", "file.plogic", charset);
 * 
 * // create context and add data to it
 * Context context = new Context();
 * context.put("value1", "foobar");
 * context.put("value2", new Integer(123));
 * 
 * // execute template
 * java.io.Writer writer = new java.io.OutputStreamWriter(System.out);
 * template.execute(context, writer);
 * </pre>
 * 
 * ex2.
 * </pre>
 * // compile template
 * Object cacheKey = "file1.html";
 * Template template = kwartz.getTemplate(cacheKey);
 * if (template == null) {
 *     synchronized(kwartz) {
 *         if (template == null) {
 *             // create compiler
 *             Compiler compiler = new DefaultCompiler();
 *             String charset = System.getProperty("file.encoding");
 *             // add presentation logic
 *             compiler.addPresentationLogicFile("file1.plogic", charset);
 *             compiler.addPresentationLogicFile("file2.plogic", charset);
 *             // add element declaration
 *             compiler.addElementDefinitionFile("elems1.html",  charset);
 *             compiler.addElementDefinitionFile("elems2.html",  charset);
 *             // add presentation data
 *             compiler.addPresentationDataFile("file1.html",    charset);
 *             compiler.addPresentationDataFile("file2.html",    charset);
 *             // register template
 *             template = compiler.getTemplate();
 *             kwartz.addTemplate(cacheKey, template);
 *         }
 *     }
 * }
 * 
 * // create context and add data to it
 * Context context = new Context();
 * context.put("value1", "foobar");
 * context.put("value2", new Integer(123));
 * 
 * // execute template
 * java.io.Writer writer = new java.io.OutputStreamWriter(System.out);
 * template.execute(context, writer);
 * </pre>
 */


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


    public Template compileFile(String pdataFilename, String plogicFilename, String elemdeclFilename, String charset) throws IOException {
        Compiler compiler = new DefaultCompiler(_props);
        Template template = compiler.compileFile(pdataFilename, plogicFilename, elemdeclFilename, charset);
        Optimizer optimizer = new Optimizer(_props);
        optimizer.optimize(template.getBlockStatement());
        return template;
    }


    public Template compileString(String pdata, String plogic, String elemdecl) throws IOException {
        Compiler compiler = new DefaultCompiler(_props);
        Template template = compiler.compileString(pdata, plogic, elemdecl);
        Optimizer optimizer = new Optimizer(_props);
        optimizer.optimize(template.getBlockStatement());
        return template;
    }

    public Template getTemplate(Object key, String pdataFilename, String plogicFilename, String elemdeclFilename, String charset) throws IOException {
        Template template = (Template)_cache.get(key);
        if (template == null) {
            // double-checked pattern for read-only data
            synchronized(_cache) {
                if (template == null) {
                    template = compileFile(pdataFilename, plogicFilename, elemdeclFilename, charset);
                    addTemplate(key, template);
                }
            }
        }
        return template;
    }

    public Template getTemplate(Object key, String pdataFilename, String plogicFilename, String charset) throws IOException {
        return getTemplate(key, pdataFilename, plogicFilename, null, charset);
    }

    public Template getTemplate(Object key) {
        return (Template)_cache.get(key);
    }

    public void addTemplate(Object key, Template template) {
        _cache.put(key, template);
    }

}
