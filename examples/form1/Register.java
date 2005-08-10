/*
 * @(#) Register.java
 * @id  $Id$
 */
import java.util.*;
import java.io.*;
import com.kuwata_lab.kwartz.Kwartz;
import com.kuwata_lab.kwartz.Context;
import com.kuwata_lab.kwartz.Template;


public class Register {

    private static Kwartz kwartz;
    static {
        Properties props = new Properties();
        props.setProperty("kwartz.escape", "true");
        kwartz = new Kwartz(props);
    }
    private String username;
    private String gender;
    private String script_name;

    public Register() {
        this(null);
    }
    public Register(String script_name) {
        this.script_name = script_name;
    }

    public void setUsername(String username) { this.username = username; }
    public String getUsername() { return username; }

    public void setGender(String gender) { this.gender = gender; }
    public String getGender() { return gender; }

    public void execute(Writer writer) throws Exception {
        // set username, gender, and error_list
        String view_name = "register";
        List error_list = null;
        if (username != null && gender != null) {
            // check input data
            error_list = new ArrayList();
            if (username.length() == 0)
                error_list.add("Name is empty.");
            if (!gender.equals("M") && !gender.equals("W"))
                error_list.add("Gender is not selected.");
            // if input parameter is valid then print the finished page.
            // else print the registration page.
            if (error_list.size() == 0) {
                error_list = null;
                view_name = "finish";
            }
        }

        // compile template
        String charset = System.getProperty("file.encoding");
        String pdataFilename = view_name + ".html";
        String plogicFilename = view_name + ".plogic";
        String cacheKey = view_name;
        Template template = kwartz.getTemplate(cacheKey, pdataFilename, plogicFilename, null, charset);

        // execute
        Context context = new Context();
        context.put("username",    username);
        context.put("gender",      gender);
        context.put("error_list",  error_list);
        context.put("script_name", script_name);
        template.execute(context, writer);
    }


    public static void main(String[] args) {
        try {
            String username = null;
            String gender   = null;
            for (int i = 0; i < args.length; i++) {
                if (args[i].charAt(0) != '-') break;
                String optstr = args[i];
                if (optstr.equals("-username")) {
                    if (++i < args.length) username = args[i];
                } else if (optstr.equals("-gender")) {
                    if (++i < args.length) gender = args[i];
                }
            }
            String script_name = "register";
            Register register = new Register(script_name);
            register.setUsername(username);
            register.setGender(gender);
            Writer writer = new OutputStreamWriter(System.out);
            register.execute(writer);
            writer.flush();
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }

}
