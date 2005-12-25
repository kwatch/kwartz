/**
 *  @(#) Main.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz;

import java.util.List;
import java.util.ArrayList;

public class Main implements Runnable {
    private String[]  _args;
    private List      _plogicFilenameList = new ArrayList();
    //private String    _action = "compile";

    public Main(String[] args) {
        _args = args;
    }

    public void run() {
        int i = 0;
        for (i = 0; i < _args.length && _args[i].charAt(0) == '-'; i++) {
            String optstr = _args[i];
            if (optstr.equals("-p")) {  // presentation logic filenames
                i++;
                if (i >= _args.length)
                    throw new CommandOptionException("-p: presentation logic filename required.");
                String[] filenames = _args[i].split(",");
                for (int j = 0; j < filenames.length; j++) {
                    _plogicFilenameList.add(filenames[i]);
                }
            }
            else if (optstr.equals("-a")) {
                i++;
                if (i >= _args.length)
                    throw new CommandOptionException("-a: action name required.");
                //_action = _args[i];
            }
            else {
                throw new CommandOptionException(optstr + ": invalid command-line option.");
            }
        }
    }
}
