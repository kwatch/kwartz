/*
 * @(#) Calendar.java
 * @id  $Id$
 */
import java.util.*;
import java.io.*;
import com.kuwata_lab.kwartz.KwartzCompiler;
import com.kuwata_lab.kwartz.DefaultCompiler;
import com.kuwata_lab.kwartz.Context;
import com.kuwata_lab.kwartz.Template;


public class CalendarExample {

    public List getCalendarList(int year) throws Exception {
        // create template
        KwartzCompiler compiler = new DefaultCompiler();
        Template template = compiler.compileFile("calendar-month.html", "calendar-month.plogic");
        
        // set calendar info
        Calendar calendar = Calendar.getInstance();
        //if (year <= 0) year = calendar.get(Calendar.YEAR);
        java.text.DateFormat format = new java.text.SimpleDateFormat("MMMM");
        Context context = new Context();
        List list = new ArrayList();
        for (int i = 0; i < 12; i++) {
            calendar.set(year, i+1, 1);             // next month
            calendar.add(Calendar.DAY_OF_YEAR, -1); // last day of this month
            int num_days = calendar.get(Calendar.DAY_OF_MONTH);
            calendar.set(year, i, 1);               // current month
            int first_weekday = calendar.get(Calendar.DAY_OF_WEEK);
            Date date = calendar.getTime();
            String month = format.format(date);

            // set context
            context.put("year", new Integer(year));
            context.put("month", month);
            context.put("num_days", new Integer(num_days));
            context.put("first_weekday", new Integer(first_weekday));
            
            // execute template
            String s = template.execute(context);
            list.add(s);
        }
        return list;
    }
            
    public void execute(Writer writer) throws Exception {
        // get current year
        int year = Calendar.getInstance().get(Calendar.YEAR);
        
        // get calendar list
        List calendar_list = getCalendarList(year);

        // create tempate
        KwartzCompiler compiler = new DefaultCompiler();
        Template template = compiler.compileFile("calendar-page.html", "calendar-page.plogic");
        //System.out.println(template.getBlockStatement()._inspect().toString());

        // execute
        Context context = new Context();
        context.put("calendar_list", calendar_list);
        context.put("year", new Integer(year));
        context.put("column", new Integer(3));
        context.put("prev_link", "?year=" + (year-1));
        context.put("next_link", "?year=" + (year+1));
        template.execute(context, writer);
    }

    public static void main(String[] args) throws Exception {
        try {
            Writer writer = new OutputStreamWriter(System.out);
            CalendarExample example = new CalendarExample();
            example.execute(writer);
            writer.flush();
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }

} // class end
