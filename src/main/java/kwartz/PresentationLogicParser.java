/* -*-java-*-  Prototype file of KM-yacc parser for Java.
 *
 * Written by MORI Koichiro, modified by kuwata-lab.com
 *
 * This file is PUBLIC DOMAIN.
 */


/* Here goes %{ ... %} */

package kwartz;

import java.util.List;
import java.util.ArrayList;
import java.util.Map;
import java.util.HashMap;


public class PresentationLogicParser extends Parser {


/* S|tokenval */
/*  public static final int %s = %n; */
/* S|endtokenval */

  
  /*
    #define yyclearin (yychar = -1)
    #define yyerrok (yyerrflag = 0)
    #define YYRECOVERING (yyerrflag != 0)
    #define YYERROR  goto yyerrlab
  */


  /** Debug mode flag **/
  static boolean yydebug = false;

  /** lexical element object **/
  private Object yylval;

  /** Semantic value */
  private Object yyval;

  /** Semantic stack **/
  private Object yyastk[];

  /** Syntax stack **/
  private short yysstk[];

  /** Stack pointer **/
  private int yysp;

  /** Error handling state **/
  private int yyerrflag;

  /** lookahead token **/
  private int yychar;

  /* code after %% in *.y */
  
  	protected Object yyval() { return yyval; }
  	protected Object yylval() { return yylval; }
  	protected Object[] yyastk() { return yyastk; }
  
  	protected Object getYyval() { return yyval; }
  	protected Object getYylval() { return yylval; }
  	protected Object[] getYyastk() { return yyastk; }
  
  	protected void setYylval(Object val) { yylval = val; }
  
  	protected Scanner createScanner(String input) {
  		Scanner scanner = super.createScanner(input);
  		scanner.setRulesetMode(true);    // set ruleset mode on 
  		return scanner;
  	}



  private static final byte yytranslate[] = {
      0,   75,   75,   75,   75,   75,   75,   75,   75,   75,
     75,   75,   75,   75,   75,   75,   75,   75,   75,   75,
     75,   75,   75,   75,   75,   75,   75,   75,   75,   75,
     75,   75,   75,   65,   75,   75,   75,   64,   75,   75,
     69,   70,   62,   60,   71,   61,   66,   63,   75,   75,
     75,   75,   75,   75,   75,   75,   75,   75,   57,   72,
     59,   55,   58,   56,   75,   75,   75,   75,   75,   75,
     75,   75,   75,   75,   75,   75,   75,   75,   75,   75,
     75,   75,   75,   75,   75,   75,   75,   75,   75,   75,
     75,   67,   75,   68,   75,   75,   75,   75,   75,   75,
     75,   75,   75,   75,   75,   75,   75,   75,   75,   75,
     75,   75,   75,   75,   75,   75,   75,   75,   75,   75,
     75,   75,   75,   73,   75,   74,   75,   75,   75,   75,
     75,   75,   75,   75,   75,   75,   75,   75,   75,   75,
     75,   75,   75,   75,   75,   75,   75,   75,   75,   75,
     75,   75,   75,   75,   75,   75,   75,   75,   75,   75,
     75,   75,   75,   75,   75,   75,   75,   75,   75,   75,
     75,   75,   75,   75,   75,   75,   75,   75,   75,   75,
     75,   75,   75,   75,   75,   75,   75,   75,   75,   75,
     75,   75,   75,   75,   75,   75,   75,   75,   75,   75,
     75,   75,   75,   75,   75,   75,   75,   75,   75,   75,
     75,   75,   75,   75,   75,   75,   75,   75,   75,   75,
     75,   75,   75,   75,   75,   75,   75,   75,   75,   75,
     75,   75,   75,   75,   75,   75,   75,   75,   75,   75,
     75,   75,   75,   75,   75,   75,   75,   75,   75,   75,
     75,   75,   75,   75,   75,   75,    1,    2,   75,    3,
      4,    5,    6,    7,    8,    9,   10,   11,   12,   13,
     14,   15,   16,   17,   75,   18,   75,   19,   20,   21,
     22,   23,   75,   75,   75,   75,   24,   75,   75,   75,
     25,   75,   26,   27,   28,   29,   30,   31,   32,   75,
     75,   75,   33,   34,   35,   36,   37,   38,   39,   40,
     75,   75,   41,   42,   43,   44,   45,   46,   47,   48,
     49,   50,   51,   52,   53,   54,   75,   75
  };
  private static final int YYBADCH = 75;
  private static final int YYMAXLEX = 328;
  private static final int YYTERMS = 75;
  private static final int YYNONTERMS = 27;

  private static final short yyaction[] = {
     58,   59,   60,   61,   62,   63,   64,   65,   66,   67,
     68,   69,   70,   71,   72,  130,  131,  132,  133,  134,
    135,  136,  137,  138,  139,  140,  141,  142,  143,  162,
    163,  120,    0,  164,  165,  166,  167,  168,  169,  170,
    171,  172,  173,   79,   80,   81,   73,   74,  218,   75,
     76,   77,   78,   79,   80,   81,-32766,-32766,-32766,-32766,
  -32766,  269,-32766,  103,  182,  188,  161,-32766,-32766,-32766,
  -32766,  222,  181,  151,   82,  162,  163,  312,  263,  164,
    165,  166,  167,  168,  169,  170,  171,  172,  173,  149,
    307,  308,  306,  309,  310,  311,   63,  215,-32767,-32767,
  -32767,-32767,-32766,-32766,-32766,-32766,-32766,-32766,-32766,  221,
  -32766,  186,  105,  247,  268,  187,-32766,-32766,-32766,-32766,
  -32766,-32766,-32766,-32766,  115,-32766,-32766,-32766,  196,  195,
    194,-32766,-32766,-32766,  193,  192,  144,  197,  145,  122,
  -32767,-32767,   77,   78,  298,   86,  262,   92,   93,    0,
  -32766,-32766,   55,  191,  190,  189,   56,  148,  147,  146,
    180,  299,  226,   47,    0,-32766,    0,    0,   48,    0,
      0,    0,   49,   87,   88,   90,   91,    0,   94,    0,
    179,    0,  302,  185,  184,  183,  126,  127,  304,  300,
    123,  124,  125,    0,  121,   83,   85,    0,  227,  225,
    214,  260,  261,  250,  259,  258,  257,  256,  255,  254,
    233,  232,  231,  230,  229,  228,    0,  209,  202,  201,
    200,  199,  198,    0,  238,  237,  236,  235,  234
  };
  private static final int YYLAST = 229;

  private static final byte yycheck[] = {
      9,   10,   11,   12,   13,   14,   15,   16,   17,   18,
     19,   20,   21,   22,   23,   41,   42,   43,   44,   45,
     46,   47,   48,   49,   50,   51,   52,   53,   54,   25,
     26,   24,    0,   29,   30,   31,   32,   33,   34,   35,
     36,   37,   38,   62,   63,   64,   55,   56,   74,   58,
     59,   60,   61,   62,   63,   64,    9,   10,   11,   12,
     13,    2,   15,   71,    2,   73,    2,   20,   21,   22,
     23,    2,    2,   66,   67,   25,   26,    2,   74,   29,
     30,   31,   32,   33,   34,   35,   36,   37,   38,    2,
      3,    4,    5,    6,    7,    8,   14,    5,   16,   17,
     18,   19,   55,   56,    9,   10,   11,   12,   13,   40,
     15,   27,   28,    5,   55,   26,   21,   22,   23,    9,
     10,   11,   12,   13,   39,   15,   60,   61,   57,   57,
     57,   65,   22,   23,   57,   57,   57,   57,   57,   71,
     58,   59,   60,   61,   68,   57,   72,   60,   61,   -1,
     55,   56,   65,   57,   57,   57,   69,   57,   57,   57,
     69,   68,   72,   69,   -1,   55,   -1,   -1,   69,   -1,
     -1,   -1,   69,   69,   69,   69,   69,   -1,   69,   -1,
     69,   -1,   70,   70,   70,   70,   70,   70,   70,   70,
     70,   70,   70,   -1,   71,   71,   71,   -1,   72,   72,
     72,   72,   72,   72,   72,   72,   72,   72,   72,   72,
     72,   72,   72,   72,   72,   72,   -1,   73,   73,   73,
     73,   73,   73,   -1,   74,   74,   74,   74,   74
  };

  private static final short yybase[] = {
      0,  118,   88,   76,   74,  120,  121,  122,  116,  117,
      4,   -9,   -9,   -9,   -9,   -9,   -9,   -9,   -9,   -9,
     -9,   -9,   -9,   -9,   -9,   -9,   -9,   -9,   -9,   -9,
     -9,   50,   50,   50,   50,   50,  -26,  110,   95,   82,
     82,   82,   82,   47,   82,   82,   87,   87,   87,   87,
     87,   87,   87,   87,   87,   87,   87,   87,   87,   87,
     87,   87,   87,   87,   87,   87,   87,   87,   87,   87,
     87,   87,   87,   87,   87,   87,   87,   87,   87,   87,
     87,   87,   87,   87,   87,   87,   87,   87,   87,   87,
     87,   87,   66,   66,   66,   59,    7,    7,    7,  -19,
    -19,  -19,   69,   69,   84,   89,   84,   84,   -8,  112,
    119,  115,   85,  108,  108,   92,  108,  123,  124,   68,
     75,  108,  108,  144,  144,  144,  144,  144,   32,  128,
     98,   97,   96,   78,   77,   73,   72,   71,   80,   79,
     81,  102,  101,  100,  149,  148,  147,  146,  145,   94,
    127,   64,  126,   90,  143,  142,  141,  140,  139,  138,
     93,   99,  103,  104,  105,  109,  137,  136,  135,  134,
    133,  132,  111,   91,  154,  153,  152,  151,  150,   70,
     62,  114,  113,  131,  129,  130,  106,  107,    0,    0,
      0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
      0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
      0,   -9,   -9,   -9,   -9,   -9,   -9,   -9,   -9,   -9,
     87,    0,    0,    0,    0,    0,    0,    0,    0,    0,
      0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
      0,   87,   87,   87,   87,   87,    0,   -9,   -9,  -19,
    -19,  -19,  -19,   -9,  -19,  -19,    0,    0,    0,    0,
      0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
      0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
      0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
      0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
      0,    0,   87,   87,   87,    7,    0,    0,    0,    0,
      0,    0,    0,    0,    0,  144,    0,    0,    0,  125,
    125,  125
  };
  private static final int YY2TBLSTATE = 112;

  private static final short yydefault[] = {
      3,32767,32767,32767,32767,32767,32767,32767,32767,32767,
  32767,   30,   30,   30,   30,   30,   34,   32,  104,   79,
     80,   81,   82,   83,   84,   85,   86,   78,   33,   31,
    103,   30,   30,   30,   30,   30,32767,   77,   73,   66,
     67,   69,   71,   72,   68,   70,32767,  105,  105,  105,
  32767,32767,32767,32767,32767,32767,32767,32767,32767,32767,
  32767,32767,32767,32767,32767,32767,32767,32767,32767,32767,
  32767,32767,32767,32767,32767,32767,32767,32767,32767,32767,
  32767,32767,32767,32767,32767,32767,32767,32767,32767,32767,
  32767,32767,32767,32767,32767,32767,   87,   76,   75,   65,
     60,   61,    1,32767,   57,32767,   57,   57,32767,32767,
  32767,32767,    7,32767,32767,32767,32767,   30,   30,   30,
  32767,32767,32767,32767,32767,32767,32767,32767,32767,32767,
  32767,32767,32767,32767,32767,32767,32767,32767,32767,32767,
  32767,32767,32767,32767,32767,32767,32767,32767,32767,   95,
  32767,32767,32767,32767,32767,32767,32767,32767,32767,32767,
  32767,   91,32767,32767,32767,32767,32767,32767,32767,32767,
  32767,32767,32767,32767,32767,32767,32767,32767,32767,32767,
  32767,32767,32767,32767,32767,32767,32767,32767,   14,   29,
     29,   29,   29,   29,   29,   29,   29,   29,   29,   29,
     29,   29,   29,   30,   39,   39,   39,   39,   39,   39
  };

  private static final short yygoto[] = {
     16,   18,   18,   18,   11,   12,   13,   14,   15,  284,
      1,   17,   19,   20,   21,   22,   23,   99,   24,   39,
     40,   41,   42,   43,   38,   25,   26,   27,    2,   44,
     45,  100,  101,  272,  273,  274,    3,   28,   29,   30,
     37,    5,    6,    7,    8,    9,  152,  153,  154,  155,
     51,   52,   53,   54,  113,   46,  114,  116,  204,  205,
    206,  207,  208,  110,  111,  174,  175,  176,  177,  178,
    104,  252,  251,  106,  107,   32,   33,   34,   35,   10,
    246,  219,  203,   97,   98,   95,    0,   84,  245,  264,
    265,    0,    0,    0,    0,    0,    0,    0,    0,    0,
      0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
      0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
      0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
      0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
      0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
      0,  156,  157,  158,    0,    0,    0,    0,    0,    0,
      0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
      0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
      0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
      0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
      0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
      0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
      0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
      0,    0,    0,    0,    0,    0,    0,  159
  };
  private static final int YYGLAST = 238;

  private static final byte yygcheck[] = {
      1,    1,    1,    1,    1,    1,    1,    1,    1,    1,
      1,    1,    1,    1,    1,    1,    1,    1,    1,    1,
      1,    1,    1,    1,    1,    1,    1,    1,    1,    1,
      1,    1,    1,    1,    1,    1,    1,    1,    1,    1,
      1,    1,    1,    1,    1,    1,   22,   22,   22,   22,
     21,   21,   21,   21,   21,   21,   21,   21,   21,   21,
     21,   21,   21,    5,    5,   22,   22,   22,   22,   22,
      8,    8,    8,    8,    8,    6,    6,    6,    6,    6,
     24,   19,   24,    2,    2,    2,   -1,   24,   24,    9,
      9,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
     -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
     -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
     -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
     -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
     -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
     -1,   22,   22,   22,   -1,   -1,   -1,   -1,   -1,   -1,
     -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
     -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
     -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
     -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
     -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
     -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
     -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
     -1,   -1,   -1,   -1,   -1,   -1,   -1,   22
  };

  private static final short yygbase[] = {
      0,  -46,   -9,    0,    0,   15, -130,    0,  -53,  -17,
      0,    0,    0,    0,    0,    0,    0,    0,    0,  -22,
      0, -140,   34,    0,  -34,    0,    0
  };

  private static final short yygdefault[] = {
  -32768,    4,   96,  160,  303,  109,   31,  248,  266,  253,
     89,  128,  102,  112,  212,  108,   36,  129,  216,  220,
    223,   50,  150,  117,   57,  118,  119
  };

  private static final byte yylhs[] = {
      0,   11,   13,   13,   14,   17,   12,   12,   18,   15,
     15,   19,   19,   16,   16,   20,   20,   20,   20,   20,
     20,   20,   20,   20,   20,   20,   20,   20,   20,   21,
     22,   23,   23,   25,   25,   26,   26,   24,    6,    6,
      7,    7,    7,    7,    7,    7,    7,    7,    7,    7,
      7,    7,    7,    8,    9,    9,    9,    9,   10,   10,
      1,    1,    1,    1,    1,    1,    1,    1,    1,    1,
      1,    1,    1,    1,    1,    1,    1,    1,    1,    1,
      1,    1,    1,    1,    1,    1,    1,    1,    2,    2,
      2,    2,    2,    2,    2,    4,    4,    4,    4,    4,
      4,    4,    3,    5,    5,    5
  };

  private static final byte yylen[] = {
      1,    2,    2,    0,    3,    1,    2,    0,    4,    3,
      1,    1,    1,    2,    0,    6,    6,    6,    6,    6,
      6,    6,    6,    6,    7,    7,    7,    7,    7,    0,
      0,    4,    2,    3,    1,    3,    1,    1,    2,    0,
      5,    7,    5,    6,    2,    2,    2,    2,    2,    2,
      5,    5,    2,    3,    6,    7,    2,    0,    1,    1,
      3,    3,    3,    3,    3,    3,    3,    3,    3,    3,
      3,    3,    3,    3,    2,    2,    2,    5,    3,    3,
      3,    3,    3,    3,    3,    3,    3,    1,    4,    4,
      6,    3,    4,    1,    3,    1,    1,    1,    1,    1,
      1,    1,    1,    3,    1,    0
  };
  private static final int YYSTATES = 274;
  private static final int YYNLSTATES = 210;
  private static final int YYINTERRTOK = 1;
  private static final int YYUNEXPECTED = 32767;
  private static final int YYDEFAULT = -32766;

  private static final int YYDEFAULTSTACK = 512;

  /* Grow syntax and sematic stacks */
  private void growStack() {
    short[] tmpsstk = new short[yysp * 2];
    Object[] tmpastk = new Object[yysp * 2];
    for (int i = 0; i < yysp; i++) {
      tmpsstk[i] = yysstk[i];
      tmpastk[i] = yyastk[i];
    }
    yysstk = tmpsstk;
    yyastk = tmpastk;
  }

  /*
   * Parser entry point
   */
  //public int yyparse() {
  public int yyparse() throws ParseException {
    int yyn;
    int yyp;
    int yyl;

    yyastk = new Object[YYDEFAULTSTACK];
    yysstk = new short[YYDEFAULTSTACK];

    int yystate = 0;
    int yychar1 = yychar = -1;

    yysp = 0;
    yysstk[yysp] = 0;
    yyerrflag = 0;
    for (;;) {
      if (yybase[yystate] == 0)
        yyn = yydefault[yystate];
      else {
        if (yychar < 0) {
          if ((yychar = yylex()) <= 0) yychar = 0;
          yychar1 = yychar < YYMAXLEX ? yytranslate[yychar] : YYBADCH;
        }

        if (((yyn = yybase[yystate] + yychar1) >= 0
             && yyn < YYLAST && yycheck[yyn] == yychar1
             || (yystate < YY2TBLSTATE
                 && (yyn = yybase[yystate + YYNLSTATES] + yychar1) >= 0
                 && yyn < YYLAST && yycheck[yyn] == yychar1))
            && (yyn = yyaction[yyn]) != YYDEFAULT) {
          /*
           * >= YYNLSTATE: shift and reduce
           * > 0: shift
           * = 0: accept
           * < 0: reduce
           * = -YYUNEXPECTED: error
           */
          if (yyn > 0) {
            /* shift */
            if (++yysp >= yysstk.length)
              growStack();

            yysstk[yysp] = (short)(yystate = yyn);
            yyastk[yysp] = yylval;
            yychar1 = yychar = -1;

            if (yyerrflag > 0)
              yyerrflag--;
            if (yyn < YYNLSTATES)
              continue;
            
            /* yyn >= YYNLSTATES means shift-and-reduce */
            yyn -= YYNLSTATES;
          } else
            yyn = -yyn;
        } else
          yyn = yydefault[yystate];
      }
      
      for (;;) {
        /* reduce/error */
        if (yyn == 0) {
          /* accept */
          return 0;
        }

	boolean yyparseerror = true;
	if (yyn != YYUNEXPECTED) {
          /* reduce */
	  yyparseerror = false;
          yyl = yylen[yyn];
          yyval = yyastk[yysp-yyl+1];
	  int yylrec = 0;
          /* Following line will be replaced by reduce actions */
          switch(yyn) {
          case 1:
{ ((List)yyastk[yysp-(2-1)]).addAll(((List)yyastk[yysp-(2-2)])); yyval = ((List)yyastk[yysp-(2-1)]); } break;
          case 2:
{ ((List)yyastk[yysp-(2-1)]).addAll(((List)yyastk[yysp-(2-2)])); yyval = ((List)yyastk[yysp-(2-1)]); } break;
          case 3:
{ yyval = new ArrayList(); } break;
          case 4:
{ yyval = handleCommand(((ParseInfo)yyastk[yysp-(3-1)]).getValue(), ((String)yyastk[yysp-(3-2)]), ((ParseInfo)yyastk[yysp-(3-1)])); } break;
          case 5:
{ yyval = ((ParseInfo)yyastk[yysp-(1-1)]).getValue(); } break;
          case 6:
{ ((List)yyastk[yysp-(2-1)]).add(((Ast.Ruleset)yyastk[yysp-(2-2)])); yyval = ((List)yyastk[yysp-(2-1)]); } break;
          case 7:
{ yyval = new ArrayList(); } break;
          case 8:
{ yyval = _f.createRuleset(((ParseInfo)yyastk[yysp-(4-2)]), ((List)yyastk[yysp-(4-1)]), ((List)yyastk[yysp-(4-3)]), ((ParseInfo)yyastk[yysp-(4-4)])); } break;
          case 9:
{ ((List)yyastk[yysp-(3-1)]).add(((Ast.Selector)yyastk[yysp-(3-3)])); yyval = ((List)yyastk[yysp-(3-1)]); } break;
          case 10:
{ List l = new ArrayList(); l.add(((Ast.Selector)yyastk[yysp-(1-1)])); yyval = l; } break;
          case 11:
{ yyval = _f.createSelector(((ParseInfo)yyastk[yysp-(1-1)])); } break;
          case 12:
{ yyval = _f.createSelector(((ParseInfo)yyastk[yysp-(1-1)])); } break;
          case 13:
{ ((List)yyastk[yysp-(2-1)]).add(((Ast.Declaration)yyastk[yysp-(2-2)])); yyval = ((List)yyastk[yysp-(2-1)]); } break;
          case 14:
{ yyval = new ArrayList(); } break;
          case 15:
{ yyval = _f.createDeclaration(((ParseInfo)yyastk[yysp-(6-1)]), ((Ast.Expression)yyastk[yysp-(6-4)])); } break;
          case 16:
{ yyval = _f.createDeclaration(((ParseInfo)yyastk[yysp-(6-1)]), ((Ast.Expression)yyastk[yysp-(6-4)])); } break;
          case 17:
{ yyval = _f.createDeclaration(((ParseInfo)yyastk[yysp-(6-1)]), ((Ast.Expression)yyastk[yysp-(6-4)])); } break;
          case 18:
{ yyval = _f.createDeclaration(((ParseInfo)yyastk[yysp-(6-1)]), ((Ast.Expression)yyastk[yysp-(6-4)])); } break;
          case 19:
{ yyval = _f.createDeclaration(((ParseInfo)yyastk[yysp-(6-1)]), ((Ast.Expression)yyastk[yysp-(6-4)])); } break;
          case 20:
{ yyval = _f.createDeclaration(((ParseInfo)yyastk[yysp-(6-1)]), ((Map)yyastk[yysp-(6-4)])); } break;
          case 21:
{ yyval = _f.createDeclaration(((ParseInfo)yyastk[yysp-(6-1)]), ((List)yyastk[yysp-(6-4)])); } break;
          case 22:
{ yyval = _f.createDeclaration(((ParseInfo)yyastk[yysp-(6-1)]), ((List)yyastk[yysp-(6-4)])); } break;
          case 23:
{ yyval = _f.createDeclaration(((ParseInfo)yyastk[yysp-(6-1)]), ((String)yyastk[yysp-(6-4)])); } break;
          case 24:
{ yyval = _f.createLogicDeclaration(((ParseInfo)yyastk[yysp-(7-1)]), ((List)yyastk[yysp-(7-5)]), ((ParseInfo)yyastk[yysp-(7-7)])); } break;
          case 25:
{ yyval = _f.createLogicDeclaration(((ParseInfo)yyastk[yysp-(7-1)]), ((List)yyastk[yysp-(7-5)]), ((ParseInfo)yyastk[yysp-(7-7)])); } break;
          case 26:
{ yyval = _f.createLogicDeclaration(((ParseInfo)yyastk[yysp-(7-1)]), ((List)yyastk[yysp-(7-5)]), ((ParseInfo)yyastk[yysp-(7-7)])); } break;
          case 27:
{ yyval = _f.createLogicDeclaration(((ParseInfo)yyastk[yysp-(7-1)]), ((List)yyastk[yysp-(7-5)]), ((ParseInfo)yyastk[yysp-(7-7)])); } break;
          case 28:
{ yyval = _f.createLogicDeclaration(((ParseInfo)yyastk[yysp-(7-1)]), ((List)yyastk[yysp-(7-5)]), ((ParseInfo)yyastk[yysp-(7-7)])); } break;
          case 29:
{ _scanner.setRulesetMode(false); } break;
          case 30:
{ _scanner.setRulesetMode(true);  } break;
          case 31:
{ Map m = ((Map)yyastk[yysp-(4-1)]); m.put(((String)yyastk[yysp-(4-3)]), ((Ast.Expression)yyastk[yysp-(4-4)])); yyval = m; } break;
          case 32:
{ Map m = new HashMap(); m.put(((String)yyastk[yysp-(2-1)]), ((Ast.Expression)yyastk[yysp-(2-2)])); yyval = m; } break;
          case 33:
{ List l = ((List)yyastk[yysp-(3-1)]); l.add(((Ast.Expression)yyastk[yysp-(3-3)])); yyval = l; } break;
          case 34:
{ List l = new ArrayList(); l.add(((Ast.Expression)yyastk[yysp-(1-1)])); yyval = l; } break;
          case 35:
{ List l = ((List)yyastk[yysp-(3-1)]); l.add(((String)yyastk[yysp-(3-3)])); yyval = l; } break;
          case 36:
{ List l = new ArrayList(); l.add(((String)yyastk[yysp-(1-1)])); yyval = l; } break;
          case 37:
{ yyval = ((ParseInfo)yyastk[yysp-(1-1)]).getValue(); } break;
          case 38:
{ ((List)yyastk[yysp-(2-1)]).add(((Ast.Statement)yyastk[yysp-(2-2)])); yyval = ((List)yyastk[yysp-(2-1)]); } break;
          case 39:
{ yyval = new ArrayList(); } break;
          case 40:
{ yyval = _f.createPrintStatement(((ParseInfo)yyastk[yysp-(5-1)]), ((List)yyastk[yysp-(5-3)])); } break;
          case 41:
{ yyval = _f.createForeachStatement(((ParseInfo)yyastk[yysp-(7-1)]), ((Ast.Expression)yyastk[yysp-(7-3)]), ((Ast.Expression)yyastk[yysp-(7-5)]), ((Ast.Statement)yyastk[yysp-(7-7)])); } break;
          case 42:
{ yyval = _f.createWhileStatement(((ParseInfo)yyastk[yysp-(5-1)]), ((Ast.Expression)yyastk[yysp-(5-3)]), ((Ast.Statement)yyastk[yysp-(5-5)])); } break;
          case 43:
{ yyval = _f.createIfStatement(((ParseInfo)yyastk[yysp-(6-1)]), ((Ast.Expression)yyastk[yysp-(6-3)]), ((Ast.Statement)yyastk[yysp-(6-5)]), ((Ast.Statement)yyastk[yysp-(6-6)])); } break;
          case 44:
{ yyval = _f.createBreakStatement(((ParseInfo)yyastk[yysp-(2-1)])); } break;
          case 45:
{ yyval = _f.createContinueStatement(((ParseInfo)yyastk[yysp-(2-1)])); } break;
          case 46:
{ yyval = _f.createStagStatement(((ParseInfo)yyastk[yysp-(2-1)])); } break;
          case 47:
{ yyval = _f.createContStatement(((ParseInfo)yyastk[yysp-(2-1)])); } break;
          case 48:
{ yyval = _f.createEtagStatement(((ParseInfo)yyastk[yysp-(2-1)])); } break;
          case 49:
{ yyval = _f.createElemStatement(((ParseInfo)yyastk[yysp-(2-1)])); } break;
          case 50:
{ yyval = _f.createElementStatement(((ParseInfo)yyastk[yysp-(5-1)]), ((ParseInfo)yyastk[yysp-(5-3)])); } break;
          case 51:
{ yyval = _f.createContentStatement(((ParseInfo)yyastk[yysp-(5-1)]), ((ParseInfo)yyastk[yysp-(5-3)])); } break;
          case 52:
{ yyval = _f.createExpressionStatement(((ParseInfo)yyastk[yysp-(2-2)]), ((Ast.Expression)yyastk[yysp-(2-1)])); } break;
          case 53:
{ yyval = _f.createBlockStatement(((ParseInfo)yyastk[yysp-(3-1)]), ((List)yyastk[yysp-(3-2)])); } break;
          case 54:
{ yyval = _f.createIfStatement(((ParseInfo)yyastk[yysp-(6-1)]), ((Ast.Expression)yyastk[yysp-(6-3)]), ((Ast.Statement)yyastk[yysp-(6-5)]), ((Ast.Statement)yyastk[yysp-(6-6)])); } break;
          case 55:
{ yyval = _f.createIfStatement(((ParseInfo)yyastk[yysp-(7-2)]), ((Ast.Expression)yyastk[yysp-(7-4)]), ((Ast.Statement)yyastk[yysp-(7-6)]), ((Ast.Statement)yyastk[yysp-(7-7)])); } break;
          case 56:
{ yyval = ((Ast.Statement)yyastk[yysp-(2-2)]); } break;
          case 57:
{ yyval = null; } break;
          case 59:
{
	        if (! ((ParseInfo)yyastk[yysp-(1-1)]).getValue().equals("in")) {
	              throw new SyntaxException("syntax error", ((ParseInfo)yyastk[yysp-(1-1)]).getLinenum(), ((ParseInfo)yyastk[yysp-(1-1)]).getColumn());
		}
          } break;
          case 60:
{ yyval = _f.createArithmeticExpression(((ParseInfo)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 61:
{ yyval = _f.createArithmeticExpression(((ParseInfo)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 62:
{ yyval = _f.createArithmeticExpression(((ParseInfo)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 63:
{ yyval = _f.createArithmeticExpression(((ParseInfo)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 64:
{ yyval = _f.createArithmeticExpression(((ParseInfo)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 65:
{ yyval = _f.createArithmeticExpression(((ParseInfo)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 66:
{ yyval = _f.createRelationalExpression(((ParseInfo)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 67:
{ yyval = _f.createRelationalExpression(((ParseInfo)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 68:
{ yyval = _f.createRelationalExpression(((ParseInfo)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 69:
{ yyval = _f.createRelationalExpression(((ParseInfo)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 70:
{ yyval = _f.createRelationalExpression(((ParseInfo)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 71:
{ yyval = _f.createRelationalExpression(((ParseInfo)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 72:
{ yyval = _f.createLogicalExpression(((ParseInfo)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 73:
{ yyval = _f.createLogicalExpression(((ParseInfo)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 74:
{ yyval = _f.createLogicalExpression(((ParseInfo)yyastk[yysp-(2-1)]), ((Ast.Expression)yyastk[yysp-(2-2)]), null); } break;
          case 75:
{ yyval = _f.createUnaryExpression(((ParseInfo)yyastk[yysp-(2-1)]), ((Ast.Expression)yyastk[yysp-(2-2)])); } break;
          case 76:
{ yyval = _f.createUnaryExpression(((ParseInfo)yyastk[yysp-(2-1)]), ((Ast.Expression)yyastk[yysp-(2-2)])); } break;
          case 77:
{ yyval = _f.createConditionalExpression(((ParseInfo)yyastk[yysp-(5-2)]), ((Ast.Expression)yyastk[yysp-(5-1)]), ((Ast.Expression)yyastk[yysp-(5-3)]), ((Ast.Expression)yyastk[yysp-(5-5)])); } break;
          case 78:
{ yyval = _f.createAssignmentExpression(((ParseInfo)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 79:
{ yyval = _f.createAssignmentExpression(((ParseInfo)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 80:
{ yyval = _f.createAssignmentExpression(((ParseInfo)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 81:
{ yyval = _f.createAssignmentExpression(((ParseInfo)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 82:
{ yyval = _f.createAssignmentExpression(((ParseInfo)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 83:
{ yyval = _f.createAssignmentExpression(((ParseInfo)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 84:
{ yyval = _f.createAssignmentExpression(((ParseInfo)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 85:
{ yyval = _f.createAssignmentExpression(((ParseInfo)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 86:
{ yyval = _f.createAssignmentExpression(((ParseInfo)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 87:
{ yyval = ((Ast.Expression)yyastk[yysp-(1-1)]); } break;
          case 88:
{ yyval = _f.createIndexExpression(((ParseInfo)yyastk[yysp-(4-2)]), ((Ast.Expression)yyastk[yysp-(4-1)]), ((Ast.Expression)yyastk[yysp-(4-3)])); } break;
          case 89:
{ yyval = _f.createIndex2Expression(((ParseInfo)yyastk[yysp-(4-2)]), ((Ast.Expression)yyastk[yysp-(4-1)]), ((Ast.Literal)yyastk[yysp-(4-3)])); } break;
          case 90:
{ yyval = _f.createMethodExpression(((ParseInfo)yyastk[yysp-(6-2)]), ((Ast.Expression)yyastk[yysp-(6-1)]), (((ParseInfo)yyastk[yysp-(6-3)])).getValue(), ((List)yyastk[yysp-(6-5)])); } break;
          case 91:
{ yyval = _f.createPropertyExpression(((ParseInfo)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), (((ParseInfo)yyastk[yysp-(3-3)])).getValue()); } break;
          case 92:
{ yyval = _f.createFuncallExpression(((ParseInfo)yyastk[yysp-(4-1)]), ((List)yyastk[yysp-(4-3)])); } break;
          case 93:
{ yyval = ((Ast.Literal)yyastk[yysp-(1-1)]); } break;
          case 94:
{ yyval = ((Ast.Expression)yyastk[yysp-(3-2)]); } break;
          case 95:
{ yyval = _f.createVariableLiteral(((ParseInfo)yyastk[yysp-(1-1)])); } break;
          case 96:
{ yyval = _f.createStringLiteral(((ParseInfo)yyastk[yysp-(1-1)])); } break;
          case 97:
{ yyval = _f.createIntegerLiteral(((ParseInfo)yyastk[yysp-(1-1)])); } break;
          case 98:
{ yyval = _f.createFloatLiteral(((ParseInfo)yyastk[yysp-(1-1)])); } break;
          case 99:
{ yyval = _f.createTrueLiteral(((ParseInfo)yyastk[yysp-(1-1)])); } break;
          case 100:
{ yyval = _f.createFalseLiteral(((ParseInfo)yyastk[yysp-(1-1)])); } break;
          case 101:
{ yyval = _f.createNullLiteral(((ParseInfo)yyastk[yysp-(1-1)])); } break;
          case 102:
{ yyval = _f.createStringLiteral(((ParseInfo)yyastk[yysp-(1-1)])); } break;
          case 103:
{ ((List)yyastk[yysp-(3-1)]).add(((Ast.Expression)yyastk[yysp-(3-3)])); yyval = ((List)yyastk[yysp-(3-1)]); } break;
          case 104:
{ List l = new ArrayList(); l.add(((Ast.Expression)yyastk[yysp-(1-1)])); yyval = l; } break;
          case 105:
{ yyval = new ArrayList(); } break;
          }
	  if (!yyparseerror) {
            /* Goto - shift nonterminal */
            yysp -= yyl;
            yyn = yylhs[yyn];
            if ((yyp = yygbase[yyn] + yysstk[yysp]) >= 0 && yyp < YYGLAST
                && yygcheck[yyp] == yyn)
              yystate = yygoto[yyp];
            else
              yystate = yygdefault[yyn];
          
            if (++yysp >= yysstk.length)
              growStack();

            yysstk[yysp] = (short)yystate;
            yyastk[yysp] = yyval;
	  }
	}

	if (yyparseerror) {
          /* error */
          switch (yyerrflag) {
          case 0:
            yyerror("syntax error");
          case 1:
          case 2:
            yyerrflag = 3;
            /* Pop until error-expecting state uncovered */

            while (!((yyn = yybase[yystate] + YYINTERRTOK) >= 0
                     && yyn < YYLAST && yycheck[yyn] == YYINTERRTOK
                     || (yystate < YY2TBLSTATE
                         && (yyn = yybase[yystate + YYNLSTATES] + YYINTERRTOK) >= 0
                         && yyn < YYLAST && yycheck[yyn] == YYINTERRTOK))) {
              if (yysp <= 0)
                return 1;
              yystate = yysstk[--yysp];
            }
            yyn = yyaction[yyn];
            yysstk[++yysp] = (short)(yystate = yyn);
            break;

          case 3:
            if (yychar1 == 0)
              return 1;
	    yychar1 = yychar = -1;
            break;
          }
        }
        
        if (yystate < YYNLSTATES)
          break;
        /* >= YYNLSTATES means shift-and-reduce */
        yyn = yystate - YYNLSTATES;
      }
    }
  }

}




