/*
 * $Rev$
 * $Release$
 * $Copyright$
 */
package kwartz;


import java.io.IOException;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.HashMap;
import java.util.regex.Matcher;



class CommandOptionException extends KwartzException {

	private static final long serialVersionUID = 5178198872618462312L;

	public CommandOptionException(String message) {
		super(message);
	}
	
}



public class Main {

	String[] _args;
	String[] _filenames;
	Map _options;
	Map _properties;
	boolean _debug = false;
	
	
	static final String COMMAND = "java Kwartz.Main";
	static Map __translator_classnames;
	
	static {
		__translator_classnames = new HashMap();
		__translator_classnames.put("jstl", "kwartz.JstlTranslator");
	}
	
	static String translatorClassname(String lang) {
		return (String)__translator_classnames.get(lang);
	}
	

	public Main(String[] args) {
		_args = args;
	}
	
	
	public String execute() throws KwartzException, IOException {
		parseOptions(_args);
		if (_options.get("D") != null)
			_debug = true;
		
		_debug("_options="    + Util.inspect(_options));
		_debug("_properties=" + Util.inspect(_properties));
		_debug("_filenames="  + Util.inspect(_filenames));
		
		if (_properties.get("help") != null) {
			_options.put("h", Boolean.TRUE);
		}

		String action = (String)Util.fetch(_options, "a", "compile");
		Map actions = Util.convertArrayToMap("compile convert parse".split(" "));
		if (! actions.containsKey(action)) {
			String msg = "-a "+action+": unknown action.";
			throw new CommandOptionException(msg);
		}

		String lang = (String)Util.fetch(_options, "l", "jstl");
		String classname = translatorClassname(lang);
		if (classname == null) {
			String msg = "-l "+lang+": unsupported lang.";
			throw new CommandOptionException(msg);			
		}
		
		if (_options.get("h") != null) {
			return help(COMMAND);
		}
		
		if (_options.get("v") != null) {
			return "$Release$\n";
		}

		List ruleset_list = new ArrayList();
		if (_options.get("p") != null) {
			String[] pdata_filenames = ((String)_options.get("p")).split(",");
			for (int i = 0, n = pdata_filenames.length; i < n; i++) {
				String filename = pdata_filenames[i];
				String pdata = Util.readFile(filename);
				Parser parser = new UniversalPresentationLogicParser();
				List rulesets = (List)parser.parse(pdata, filename);
				ruleset_list.addAll(rulesets);
			}
		}

		String layout_pdata = null;
		String layout_filename = null;
		if (_options.containsKey("L")) {
			layout_filename = (String)_options.get("L");
			layout_pdata = Util.readFile(layout_filename);
		}
		
		String[] import_filenames = null;
		if (_options.get("i") != null) {
			import_filenames = ((String)_options.get("i")).split(",");
		}

		StringBuffer output = new StringBuffer();
		for (int i = 0, n = _filenames.length; i < n; i++) {
			String filename = _filenames[i];
			String pdata = Util.readFile(filename);
			Handler handler = new BaseHandler(ruleset_list, _properties);
			Converter converter = new TextConverter(handler);
			if (import_filenames != null) {
				for (int j = 0, n2 = import_filenames.length; i < n2; i++) {
					String import_filename = import_filenames[j];
					converter.convert(Util.readFile(import_filename), import_filename);
				}
			}
			List stmts = converter.convert(pdata, filename);
			if (layout_pdata != null) {
				stmts = converter.convert(layout_pdata, layout_filename);
			}
			if (action.equals("compile")) {
				String elem_id = (String)Util.fetch(_options, "X", _options.get("x"));
				if (elem_id != null) {
					boolean content_only = !_options.containsKey("X");
					stmts = handler.extract(elem_id, content_only);
				}
				_debug("classname=" + Util.inspect(classname));
				Translator translator = createTranslatorInstance(classname);
				translator.setProperties(_properties);
				String result = translator.translate(stmts);
				output.append(result);
			}
			else if (action.equals("convert")) {
				for (Iterator it = stmts.iterator(); it.hasNext();) {
					Ast.Statement stmt = (Ast.Statement)it.next();
					output.append(stmt.inspect());
				}
			}
		}
		return output.toString();
	}
	
	
	private void _debug(String s) {
		if (_debug) {
			System.err.println("*** debug: " + s);
		}
	}

	
	static String help(String command) {
		String s = ""
			+ "Usage: " + command + " [..options..] file1 [file2...]\n"
			+ "  -h, --help      :  help\n"
			+ "  -v              :  version\n"
			+ "  -e              :  escape\n"
			+ "  -a action       :  compile/convert\n"
			+ "  -l lang         :  lang\n"
			+ "  -p plogic,...   :  presentation logic filenames\n"
			+ "  -i pdata,...    :  import presentation data filenames\n"
			+ "  -x elem-id      :  extract content of element marked by elem-id\n"
			+ "  -X elem-id      :  extract element marked by elem-id\n"
			+ "  -L layout       :  layout filename\n"
			+ "  --escape=false  :  don't escape\n"
			+ "  --dattr=kw:d    :  directive attribute name\n"
			+ "  --delspan=true  :  delete dummy span tag\n"
			+ "  --odd=\"'odd'\"   :  odd value\n"
			+ "  --even=\"'even'\" :  even value\n"
			+ "  --loopctr       :  detect loop counter\n"
			;
		return s;
	}
	
	
	static Translator createTranslatorInstance(String classname) throws KwartzException {
		Class klass = null;
		try {
			klass = Class.forName(classname);
		} catch (ClassNotFoundException ex) {
			throw new KwartzException(ex.getMessage());
		}
		Translator translator;
		try {
			translator = (Translator)klass.newInstance();
		} catch (InstantiationException ex) {
			throw new KwartzException(ex.getMessage());
		} catch (IllegalAccessException ex) {
			throw new KwartzException(ex.getMessage());
		}
		return translator;
	}

	
	void parseOptions(String[] args) throws CommandOptionException {
		_options = new HashMap();
		_properties = new HashMap();
		
		int i, n;
		for (i = 0, n = args.length; i < n; i++) {
			String arg = args[i];
			if (arg.length() == 0 || arg.charAt(0) != '-') {
				break;
			}
			if (arg.equals("-")) {
				i++;
				break;
			}
			Matcher m = Util.matcher("^--([-\\w]+)(?:=(.*))?$", arg);
			if (m.find()) {
				String pname = m.group(1);
				String pvalue = m.group(2);
				_properties.put(pname, pvalue == null ? Boolean.TRUE : Util.stringToValue(pvalue));
				continue;
			}
			String optstr = arg.substring(1);
			for (int j = 0, len = optstr.length(); j < len; j++) {
				char ch = optstr.charAt(j);
				if ("hveDN".indexOf(ch) >= 0) {
					_options.put(Character.toString(ch), Boolean.TRUE);
				}
				else if ("lapixXL".indexOf(ch) >= 0) {
					String optarg;
					if (++j < len) {
						optarg = optstr.substring(j);
						j = len;
					}
					else {
						if (++i == n)
							throw new CommandOptionException("-"+ch+": argument required.");
						optarg = args[i];
					}
					_options.put(Character.toString(ch), optarg);
				}
			}			
		}
		_filenames = Util.slice(args, i);
	}

	
	public static void main(String[] args) throws Exception {
		Main main = new Main(args);
		try {
			String output = main.execute();
			if (output != null)
				System.out.print(output);
		}
		catch (KwartzException ex) {
			System.err.println(ex.getMessage());
		}
	}
	
	
}
