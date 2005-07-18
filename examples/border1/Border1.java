/*
 * @(#) Border1.java
 * @id  $Id$
 */
import java.util.*;
import java.io.*;
import com.kuwata_lab.kwartz.KwartzCompiler;
import com.kuwata_lab.kwartz.DefaultCompiler;
import com.kuwata_lab.kwartz.Context;
import com.kuwata_lab.kwartz.Template;


public class Border1 {

    private String pdataFilename;
    private String plogicFilename;

    public Border1() {
        this("border1.html", "border1.plogic");
    }

    public Border1(String pdataFilename, String plogicFilename) {
        this.pdataFilename  = pdataFilename;
        this.plogicFilename = plogicFilename;
    }

    public void execute(Writer writer) throws Exception {
        // set user list
        String[][] list = {
            new String[] { "sumire", "violet@mail.com", },
            new String[] { "nana",   "seven@mail.com", },
            new String[] { "momoko", "peach@mail.com", },
            new String[] { "kasumi", "mist@mail.com", },
        };
        List user_list = new ArrayList();
        for (int i = 0; i < list.length; i++) {
            String[] tuple = list[i];
            Map user = new HashMap();
            user.put("name",  tuple[0]);
            user.put("email", tuple[1]);
            user_list.add(user);
        }

        // compile template
        KwartzCompiler compiler = new DefaultCompiler();
        String charset = System.getProperty("file.encoding");
        Template template = compiler.compileFile(pdataFilename, plogicFilename, charset);

        // execute
        Context context = new Context();
        context.put("user_list", user_list);
        template.execute(context, writer);
    }

    public static void main(String[] args) {
        try {
            Writer writer = new OutputStreamWriter(System.out);
            Border1 border1 = new Border1();
            border1.execute(writer);
            writer.flush();
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }

} // class end
