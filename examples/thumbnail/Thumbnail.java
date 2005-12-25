/*
 * @(#) Thumbnail.java
 * @id  $Id$
 */
import java.util.*;
import java.io.*;
import java.text.MessageFormat;
import kwartz.Kwartz;
import kwartz.Context;
import kwartz.Template;


public class Thumbnail {

    // final variables
    static final int PAGE_COUNT = 22;
    static final String BASE_URL = "http://www.kuwata-lab.com/kwartz/overview/img";
    static final String IMAGE_URL = BASE_URL + "/overview_{0,number,00}.png";
    static final MessageFormat IMAGE_URL_FORMAT = new MessageFormat(IMAGE_URL);

    static String getImageUrl(int page) {
        Object[] arg = { new Integer(page) };
        String s = IMAGE_URL_FORMAT.format(arg);
        return s;
    }

    // static variable
    private static Kwartz kwartz = new Kwartz();
    
    // instance variables
    private String pdataFilename;
    private String plogicFilename;
    private MessageFormat linkFormat;

    // constructors
    public Thumbnail(String linkFormatString) {
        this(linkFormatString, "thumbnail.html", "thumbnail.plogic");
    }

    public Thumbnail(String linkFormatString, String pdataFilename, String plogicFilename) {
        this.linkFormat     = new MessageFormat(linkFormatString);
        this.pdataFilename  = pdataFilename;
        this.plogicFilename = plogicFilename;
    }

    // instance methods
    public String getLinkUrl(int page) {
        //return "?page=" + page;
        Object[] arg = { new Integer(page) };
        String s = linkFormat.format(arg);
        return s;
    }

    public void execute(int page, Writer writer) throws Exception {
        int first = 1;
        int last  = PAGE_COUNT;
        if (page < first || last < page) page = 0;

        // set URLs of previous, next, first, last, and index page
        String prev_url  = page > first ? getLinkUrl(page-1) : null;
        String next_url  = page < last  ? getLinkUrl(page+1) : null;
        String first_url = page > first ? getLinkUrl(first)  : null;
        String last_url  = page < last  ? getLinkUrl(last)   : null;
        String index_url = page != 0    ? getLinkUrl(0)      : null;

        // set image_url and thumb_list
        String image_url = null;
        List thumb_list = null;
        if (page > 0) {
            image_url = getImageUrl(page);
        } else if (page == 0) {
            thumb_list = new ArrayList();
            for (int i = first; i <= last; i++) {
                Map hash = new HashMap();
                hash.put("image_url", getImageUrl(i));
                hash.put("link_url",  getLinkUrl(i));
                thumb_list.add(hash);
            }
        } else {
            assert false;
        }

        // compile template
        String charset = System.getProperty("file.encoding");
        String cacheKey = "thumbnail";
        Template template = kwartz.getTemplate(cacheKey, pdataFilename, plogicFilename, null, charset);

        // execute
        Context context = new Context();
        context.put("page",       new Integer(page));
        context.put("image_url",  image_url);
        context.put("thumb_list", thumb_list);
        context.put("prev_url",   prev_url);
        context.put("next_url",   next_url);
        context.put("first_url",  first_url);
        context.put("last_url",   last_url);
        context.put("index_url",  index_url);
        template.execute(context, writer);
    }


    public static void main(String[] args) {
        try {
            Thumbnail example = new Thumbnail("result{0,number,#}.html");
            if (args.length == 0) {
                OutputStream stream = null;
                Writer writer = null;
                try {
                    for (int page = 0; page <= PAGE_COUNT; page++) {
                        String filename = "result" + page + ".html";
                        stream = new FileOutputStream(filename);
                        writer = new OutputStreamWriter(stream);
                        example.execute(page, writer);
                        writer.flush();
                    }
                } finally {
                    if (writer != null) writer.close();
                    if (stream != null) stream.close();
                }
            } else {
                int page = Integer.parseInt(args[0]);
                Writer writer = new OutputStreamWriter(System.out);
                example.execute(page, writer);
                writer.flush();
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }

} // class end
