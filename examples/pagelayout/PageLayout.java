/*
 * @(#) PageLayout.java
 * @id  $Id$
 */
import java.util.*;
import java.io.*;
import kwartz.Kwartz;
import kwartz.Compiler;
import kwartz.DefaultCompiler;
import kwartz.Context;
import kwartz.Template;


public class PageLayout {

    private static Kwartz kwartz = new Kwartz();

    public static class Stock {
        private String symbol;
        private double price;
        private double rate;
        private String company;

        public Stock(String symbol, double price, double rate, String company) {
            this.symbol  = symbol;
            this.price   = (double)price;
            this.rate    = (double)rate;
            this.company = company;
        }

        public String getSymbol() { return symbol; }
        public double getPrice() { return price; }
        public double getRate() { return rate; }
        public String getCompany() { return company; }
    }

    private String pdataFilename;
    private String plogicFilename;

    public PageLayout() {
        this("border3.html", "border3.plogic");
    }

    public PageLayout(String pdataFilename, String plogicFilename) {
        this.pdataFilename  = pdataFilename;
        this.plogicFilename = plogicFilename;
    }

    public void execute(String symbol, Writer writer) throws Exception {
        // set menu list
        String[][] list = {
            new String[] { "Main",      "/cgi-bin/mail.cgi"     },
            new String[] { "Calendar",  "/cgi-bin/calendar.cgi" },
            new String[] { "Todo",      "/cgi-bin/todo.cgi"     },
            new String[] { "Stock",     "/cgi-bin/stock.cgi"    },
        };
        List menu_list = new ArrayList();
        for (int i = 0; i < list.length; i++) {
            String[] tuple = list[i];
            Map menu = new HashMap();
            menu.put("label",  tuple[0]);
            menu.put("url",    tuple[1]);
            menu_list.add(menu);
        }
        
        // set stock list
        List stock_list = new ArrayList();
        stock_list.add(new PageLayout.Stock("AAPL", 36.49, -0.32, "Apple Computer, Inc."));
        stock_list.add(new PageLayout.Stock("MSFT", 26.53,  1.44, "Microsoft Corp."));
        stock_list.add(new PageLayout.Stock("ORCL", 12.59, -2.02, "Oracle Corporation"));
        stock_list.add(new PageLayout.Stock("SUNW",  3.62,  0.28, "Sun Microsystems, Inc"));
        stock_list.add(new PageLayout.Stock("INTC", 19.51,  2.90, "Intel Corporation"));

        // find stock
        Stock stock = null;
        if (symbol != null) {
            for (Iterator it = stock_list.iterator(); it.hasNext(); ) {
                stock = (Stock)it.next();
                if (stock.getSymbol().equals(symbol)) break;
                stock = null;
            }
        }

        // set page name
        String page = stock == null ? "page1.html" : "page2.html";

        // compile template
        String cacheKey = page;
        Template template = kwartz.getTemplate(cacheKey);
        if (template == null) {
            synchronized(kwartz) {
                if (template == null) {
                    Compiler compiler = new DefaultCompiler();
                    String charset = System.getProperty("file.encoding");
                    compiler.addPresentationLogicFile("menu.plogic", charset);
                    compiler.addPresentationLogicFile("page.plogic", charset);
                    compiler.addElementDefinitionFile("menu.html", charset);
                    compiler.addElementDefinitionFile(page, charset);
                    compiler.addPresentationDataFile("layout.html", charset);
                    template = compiler.getTemplate();
                    kwartz.addTemplate(cacheKey, template);
                }
            }
        }

        // execute
        Context context = new Context();
        context.put("menulist", menu_list);
        if (stock == null)
            context.put("stocks", stock_list);
        else
            context.put("stock",  stock);
        template.execute(context, writer);
    }

    public static void main(String[] args) {
        try {
            Writer writer = new OutputStreamWriter(System.out);
            PageLayout app = new PageLayout();
            String symbol = args.length > 0 ? args[0] : null;
            app.execute(symbol, writer);
            writer.flush();
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }

} // class end
