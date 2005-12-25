/*
 * @(#) Breadcrumbs.java
 * @id  $Id$
 */
import java.util.*;
import java.io.*;
import kwartz.Kwartz;
import kwartz.Context;
import kwartz.Template;


public class Breadcrumbs {

    private static Kwartz kwartz = new Kwartz();
    private String pdataFilename;
    private String plogicFilename;

    public Breadcrumbs() {
        this("breadcrumbs.html", "breadcrumbs.plogic");
    }

    public Breadcrumbs(String pdataFilename, String plogicFilename) {
        this.pdataFilename  = pdataFilename;
        this.plogicFilename = plogicFilename;
    }

    public void execute(Writer writer) throws Exception {
        // set breadcrumb list
        String[][] list = {
            new String[] { "HOME",        "/", },
            new String[] { "Kwartz",      "/kwartz/", },
            new String[] { "Examples",    "/kwartz/examples/", },
            new String[] { "Breadcrumbs", "/kwartz/examples/breadcrumbs/", },
        };
        List breadcrumbs = new ArrayList();
        for (int i = 0; i < list.length; i++) {
            String[] tuple = list[i];
            Map crumb = new HashMap();
            crumb.put("name", tuple[0]);
            crumb.put("path", tuple[1]);
            breadcrumbs.add(crumb);
        }

        // set title
        String title = "Result";

        // compile template
        String charset = System.getProperty("file.encoding");
        String cacheKey = "breadcrumbs";
        Template template = kwartz.getTemplate(cacheKey, pdataFilename, plogicFilename, null, charset);

        // execute
        Context context = new Context();
        context.put("breadcrumbs", breadcrumbs);
        context.put("title", title);
        template.execute(context, writer);
    }

    public static void main(String[] args) {
        try {
            Writer writer = new OutputStreamWriter(System.out);
            Breadcrumbs breadcrumbs = new Breadcrumbs();
            breadcrumbs.execute(writer);
            writer.flush();
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }

}
