import java.util.*;
import java.io.*;

//import com.kuwata_lab.kwartz.KwartzCompiler;
//import com.kuwata_lab.kwartz.DefaultCompiler;
//import com.kuwata_lab.kwartz.Context;
//import com.kuwata_lab.kwartz.Template;

//import org.apache.velocity.VelocityContext;
//import org.apache.velocity.Template;
//import org.apache.velocity.app.Velocity;
//import org.apache.velocity.exception.ResourceNotFoundException;
//import org.apache.velocity.exception.ParseErrorException;
//import org.apache.velocity.exception.MethodInvocationException;


public class BenchmarkTest {

    public interface Benchmark {
        public void setTestname(String testname);
        public void execute(Writer writer, boolean flagCache, String key, Object value) throws Exception;
    }


    public static class KwartzBenchmark implements Benchmark {
        private String _pdataFilename;
        private String _plogicFilename;

        public void setTestname(String testname) {
            _pdataFilename  = testname + ".html";
            _plogicFilename = testname + ".plogic";
        }

        public void execute(Writer writer, boolean flagCache, String key, Object value) throws Exception {
            // create context
            com.kuwata_lab.kwartz.Context context = new com.kuwata_lab.kwartz.Context();
            context.put(key, value);

            // compile template
            com.kuwata_lab.kwartz.Template template;
            if (flagCache) {
                String cachekey = _pdataFilename;
                template = com.kuwata_lab.kwartz.Kwartz.getTemplate(cachekey, _pdataFilename, _plogicFilename);
            } else {
                com.kuwata_lab.kwartz.KwartzCompiler compiler = new com.kuwata_lab.kwartz.DefaultCompiler();
                template = compiler.compileFile(_pdataFilename, _plogicFilename);
            }

            // execute
            writer = new FileWriter("KwartzBenchmark.log");
            template.execute(context, writer);
            writer.flush();
        }

    }



    public static class VelocityBenchmark implements Benchmark {

        private String _filename;

        public void setTestname(String testname) {
            _filename = testname + ".vm";
        }

        public void execute(Writer writer, boolean flagCache, String key, Object value) throws Exception {
            // initialize
            if (flagCache) {
                java.util.Properties prop = new java.util.Properties();
                prop.setProperty("file.resource.loader.cache", "true");
                org.apache.velocity.app.Velocity.init(prop);
            } else {
                org.apache.velocity.app.Velocity.init();
            }

            // create context
            org.apache.velocity.VelocityContext context = new org.apache.velocity.VelocityContext();
            context.put(key, value);

            // get template
            org.apache.velocity.Template template = org.apache.velocity.app.Velocity.getTemplate(_filename);

            // execute
            template.merge(context, writer);
            writer.flush();
        }

    }
    
    
    public static class FreeMarkerBenchmark implements Benchmark {
        private String _filename;
        
        private static freemarker.template.Configuration config = new freemarker.template.Configuration();
        static {
            config.setObjectWrapper(new freemarker.template.DefaultObjectWrapper());
        }
        
        public void setTestname(String testname) {
            _filename = testname + ".ftl";
        }
        
        public void execute(Writer writer, boolean flagCache, String key, Object value) throws Exception {
            // create context
            Map context = new HashMap();
            context.put(key, value);
            
            // get template
            freemarker.template.Template template = config.getTemplate(_filename);
            
            // execute
            template.process(context, writer);
        }
    }



    public static void main(String[] args) throws Exception {
        // help
        if (args.length == 0) {
            System.err.println("Usage: java BenchmarkTest [-count N] [-loop N] [-cache true|false] [-testname name] [-write file|string] classname");
        }

        // parse options
        int count = 10;
        int loop = 1000;
        boolean flagCache = false;
        String testname = "test1";
        String writeMode = "file";
        int idx;
        for (idx = 0; idx < args.length && args[idx].charAt(0) == '-'; idx++) {
            String optstr = args[idx];
            if (false) {
            }
            else if (optstr.equals("-count")) {
                if (++idx >= args.length) {
                    System.err.println("-count: argument required.");
                    return;
                }
                count = Integer.parseInt(args[idx]);
            }
            else if (optstr.equals("-loop")) {
                if (++idx >= args.length) {
                    System.err.println("-loop: argument required.");
                    return;
                }
                loop = Integer.parseInt(args[idx]);
            }
            else if (optstr.equals("-cache")) {
                if (++idx >= args.length) {
                    System.err.println("-cache: argument required.");
                    return;
                }
                flagCache = args[idx].equals("true") || args[idx].equals("yes");
            }
            else if (optstr.equals("-testname")) {
                if (++idx >= args.length) {
                    System.err.println("-test: argument required.");
                    return;
                }
                testname = args[idx];
            }
            else if (optstr.equals("-write")) {
                if (++idx >= args.length) {
                    System.err.println("-write: argument required.");
                    return;
                }
                writeMode = args[idx];
            }
        }

        // class name
        if (idx >= args.length) {
            System.err.println("Benchmark class name required.");
            return;
        }
        String className = args[idx];


        // set data
        List list = new ArrayList();
        for (int i = 1; i <= loop; i++) {
            list.add("i = " + i);
        }


        // do benchmark
        System.out.println("*** count=" + count + ", loop=" + loop + ", cache=" + flagCache + ", testname=" + testname + ", write-mode=" + writeMode);
        Class klass = Class.forName("BenchmarkTest$" + className);
        Benchmark benchmark = (Benchmark)klass.newInstance();
        benchmark.setTestname(testname);

        //Writer writer;
        //if (writeMode.equals("file"))
        //  writer = new FileWriter("Benchmark.log");
        //else
        //  writer = new StringWriter();
        long start = System.currentTimeMillis();
        for (int j = 0; j < count; j++) {
            Writer writer = writeMode.equals("file") ? (Writer)new FileWriter("Benchmark.log") : (Writer)new StringWriter();
            benchmark.execute(writer, flagCache, "list", list);
            writer.close();
        }
        //writer.close();
        long stop = System.currentTimeMillis();
        double sec = (stop - start)/1000.0;
        System.out.println(className + ": " + sec + " sec");
    }
}


//    Stock.new(15.01, "AAPL", "Apple Computer, Inc."),
//    Stock.new( 9.72, "BEAS", "BEA Systems, Inc. "),
//    Stock.new(13.98, "CSCO", "Cisco Systems, Inc."),
//    Stock.new(26.96, "DELL", "Dell Computer Corporation"),
//    Stock.new(15.85, "HPQ",  "Hewlett Packard Co"),
//    Stock.new(77.95, "IBM",  "Intl Business Mach"),
//    Stock.new(15.84, "MACR", "Macromedia, Inc."),
//    Stock.new(23.70, "MSFT", "Microsoft Corporation"),
//    Stock.new(11.96, "ORCL", "Oracle Corporation"),
//    Stock.new( 3.44, "SUNW", "Sun Microsystems, Inc."),
//