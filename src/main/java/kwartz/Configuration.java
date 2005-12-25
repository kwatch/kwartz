/**
 *  @(#) Configuration.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz;


import java.util.Map;
import java.util.Properties;
import java.util.Enumeration;
import java.io.InputStream;
import java.io.IOException;


public class Configuration {

    public static Properties defaults = new Properties();
    //public static Map functions = new HashMap();

    static {
        Configuration.initProperties();
        Configuration.registerMacros(defaults);
        Configuration.registerFunctions(defaults);
    }

    private static void initProperties() {
        // default properties
        InputStream stream = null;
        try {
            String filename = "kwartz.properties";
            stream = Configuration.class.getResourceAsStream(filename);
            defaults.load(stream);
        }
        catch (IOException ex) {
            ex.printStackTrace();    // logging
        }
        finally {
            if (stream != null) {
                try {
                    stream.close();
                } catch (IOException ex) {
                    ex.printStackTrace();  // logging
                }
            }
        }
    }

    static void registerMacros(Properties props) {
        registerObjects(props, Macro.instances(), "kwartz.macro.", true);
    }
    static void registerFunctions(Properties props) {
        registerObjects(props, Function.instances(), "kwartz.function.", true);
    }

    private static void registerObjects(Properties props, Map map, String prefix, boolean flagOverride) {  // move to Function class?
        for (Enumeration en = props.propertyNames(); en.hasMoreElements(); ) {
            String pname = (String)en.nextElement();
            if (pname.startsWith(prefix)) {  // "kwartz.macro." or "kwartz.function."
                String name  = pname.substring(prefix.length());
                if (!flagOverride && map.get(name) != null)
                    continue;
                String classname = (String)props.getProperty(pname);
                try {
                    Object obj = Class.forName(classname).newInstance();  // Macro or Function
                    map.put(name, obj);
                } catch (ClassNotFoundException ex) {
                    ex.printStackTrace();		// logging
                } catch (IllegalAccessException ex) {
                    ex.printStackTrace();		// logging
                } catch (InstantiationException ex) {
                    ex.printStackTrace();		// logging
                }
            }
        }
    }

}
