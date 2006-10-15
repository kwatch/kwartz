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
  //private Object yylval;

  /** Semantic value */
  //private Object yyval;

  /** Semantic stack **/
  //private Object yyastk[];

  /** Syntax stack **/
  //private short yysstk[];

  /** Stack pointer **/
  //private int yysp;

  /** Error handling state **/
  //private int yyerrflag;

  /** lookahead token **/
  //private int yychar;

  /* code after %% in *.y */
  
  	//protected Object yyval() { return yyval; }
  	//protected Object yylval() { return yylval; }
  	//protected Object[] yyastk() { return yyastk; }
  
  	//protected Object getYyval() { return yyval; }
  	//protected Object getYylval() { return yylval; }
  	//protected Object[] getYyastk() { return yyastk; }
  
  	//protected void setYylval(Object val) { yylval = val; }
  
  	protected Scanner createScanner(String input, String filename) {
  		Scanner scanner = super.createScanner(input, filename);
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
  private static final int YYNONTERMS = 40;

  private static final short yyaction[] = {
     62,    0,   64,   65,   66,   67,   68,   69,   92,   93,
    317,  118,  451,   55,  316,  156,  281,  282,  330,  373,
    283,  284,  285,  286,  287,  288,  289,  290,  291,  292,
     78,   79,   80,  408,  329,  124,-32767,-32767,-32767,-32767,
  -32766,-32766,   73,  348,   74,   75,   76,   77,   78,   79,
     80,   92,   93,  153,   81,  341,   55,  206,  207,  208,
    209,  210,  211,  212,  213,  214,  215,  216,  217,  218,
    219,   57,   58,   59,   60,   61,-32766,   63,-32767,-32767,
    231,  347,  112,  230,   70,   71,  407,   57,   58,   59,
     60,   61,  228,   63,-32766,-32766,-32766,  227,  438,  226,
     70,   71,   57,   58,   59,   60,   61,   47,   63,  225,
    224,  223,  222,  221,  229,   70,   71,   72,  234,  325,
    233,   57,   58,   59,   60,   61,  232,   63,   48,  298,
  -32766,-32766,  443,   72,   70,   71,  152,  446,  447,  445,
    448,  449,  450,  320,  275,  299,  437,  322,   72,  300,
     85,  301,  308,  309,  331,  333,    0,  321,  319,  318,
    439,  441,  335,    0,  334,    0,   83,   72,  261,  201,
    119,   84,    0,  274,  273,  272,  202,  271,  327,  326,
    323,  310,  307,  306,    0,  305,  304,  303,  302,  280,
    279,  278,  277,    0,  248,  203,  324,  244,  247,  246,
    245,    0,  220,   56,  311,  312,  313,  314,    0,  315,
    332
  };
  private static final int YYLAST = 211;

  private static final byte yycheck[] = {
     14,    0,   16,   17,   18,   19,   20,   21,   60,   61,
      2,   24,    2,   65,    2,    2,   25,   26,   26,    5,
     29,   30,   31,   32,   33,   34,   35,   36,   37,   38,
     62,   63,   64,    2,   27,   28,   16,   17,   18,   19,
     20,   21,   56,    2,   58,   59,   60,   61,   62,   63,
     64,   60,   61,   66,   67,    5,   65,   41,   42,   43,
     44,   45,   46,   47,   48,   49,   50,   51,   52,   53,
     54,    9,   10,   11,   12,   13,   56,   15,   58,   59,
     57,   40,   39,   57,   22,   23,   55,    9,   10,   11,
     12,   13,   57,   15,   20,   21,   21,   57,   68,   57,
     22,   23,    9,   10,   11,   12,   13,   69,   15,   57,
     57,   57,   57,   57,   57,   22,   23,   55,   57,   70,
     57,    9,   10,   11,   12,   13,   57,   15,   69,   69,
     56,   56,   70,   55,   22,   23,    2,    3,    4,    5,
      6,    7,    8,   70,   72,   69,   68,   70,   55,   69,
     57,   69,   69,   69,   69,   69,   -1,   70,   70,   70,
     70,   70,   70,   -1,   70,   -1,   71,   55,   71,   71,
     71,   71,   -1,   72,   72,   72,   72,   72,   72,   72,
     72,   72,   72,   72,   -1,   72,   72,   72,   72,   72,
     72,   72,   72,   -1,   73,   73,   73,   73,   73,   73,
     73,   -1,   74,   69,   74,   74,   74,   74,   -1,   74,
     74
  };

  private static final short yybase[] = {
      0,   62,   93,   78,  112,  112,  112,  112,  112,  112,
    112,  112,  112,  112,  112,  112,  112,  112,  112,  112,
    112,  112,  112,  112,  112,  112,  112,  112,  112,  112,
     -9,   -9,   -9,   -9,   -9,   -9,  -14,   16,   75,   20,
     20,   20,   20,   74,   20,   20,  -52,  -52,  -52,  -52,
    -52,  -52,  -52,  -52,  -52,  -52,  -52,  -52,  -52,  -52,
    -52,  -52,  -52,  -52,  -52,  -52,  -52,  -52,  -52,  -52,
    -52,  -52,  -52,  -52,  -52,  -52,  -52,  -52,  -52,  -52,
    -52,  -52,  -52,  -52,  -52,  -52,  -52,  -52,  -52,  -52,
    -52,  -52,  134,  134,  134,   31,  -13,  -13,  -13,  -32,
    -32,  -32,   41,   41,    7,    7,    7,   91,   90,   43,
     14,   14,   50,   98,   14,   97,   95,   99,   10,   14,
     14,  100,  123,  123,   -8,  123,  123,  123,  123,    1,
    104,  122,  128,   56,   55,   54,   53,   52,   42,   40,
     35,   57,   26,   23,   69,   63,   61,  124,  127,  126,
    125,  121,   38,   13,  105,   30,   59,  103,  102,  101,
     72,  120,  119,  118,  117,   60,   76,   80,   82,  116,
    115,  114,  113,  111,  110,   83,   84,  109,  130,  131,
    132,  133,  135,   12,    8,   89,   88,   73,   87,   77,
    108,   49,  107,  106,   85,  136,   86,   94,   92,    0,
      0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
      0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
      0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
      0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
      0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
      0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
      0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
      0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
      0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
      0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
      0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
      0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
      0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
      0,    0,    0,    0,    0,    0,    0,  -14,  -14,  -14,
    -14,  -14,  -14,  -14,  -14,  -14,  -14,  -14,  -14,  -14,
    -14,  -14,  -14,  -14,  -14,  -14,  -14,  -14,  -14,  -14,
    -14,  -14,  -14,  -14,  -14,  -14,  134,  134,  134,  134,
    134,  134,    0,    0,  -14,  -14,  -14,  -14,  -14,  -14,
    -14,  -14,  134,  134,  134,  134,  134,  134,  134,  134,
    134,  134,  134,  134,  134,  134,  134,  134,  134,  134,
    134,  134,  134,  134,  134,  134,  134,  134,  134,  134,
    134,  134,  134,  134,  134,  134,  134,  134,  134,  134,
    134,  134,  134,  134,  134,  134,  134,  134,    0,    0,
      0,  -13,    0,    0,    0,    0,    0,    0,    0,    0,
      0,    0,    0,  100,  100
  };
  private static final int YY2TBLSTATE = 109;

  private static final short yydefault[] = {
      3,32767,32767,32767,   30,   30,   30,   30,   30,   64,
     62,   64,   59,   59,   59,   59,   59,   34,  117,   92,
     93,   94,   95,   96,   97,   98,   99,   91,   33,  116,
     30,   30,   30,   30,   30,   61,   90,   61,   86,   79,
     80,   82,   84,   85,   81,   83,32767,  118,  118,  118,
  32767,32767,32767,32767,32767,32767,32767,32767,32767,32767,
  32767,32767,32767,32767,32767,32767,32767,32767,32767,32767,
  32767,32767,32767,32767,32767,32767,32767,32767,32767,32767,
  32767,32767,32767,32767,32767,32767,32767,32767,32767,32767,
  32767,32767,32767,32767,32767,32767,  100,   89,   88,   78,
     73,   74,    1,32767,   56,   56,   56,32767,32767,    7,
  32767,32767,32767,   60,32767,   30,   30,   30,32767,32767,
  32767,   59,32767,32767,   60,32767,32767,32767,32767,32767,
  32767,32767,32767,32767,32767,32767,32767,32767,32767,32767,
  32767,32767,32767,32767,32767,32767,32767,32767,32767,32767,
  32767,32767,  108,32767,32767,32767,  104,32767,32767,32767,
  32767,32767,32767,32767,32767,32767,32767,32767,32767,32767,
  32767,32767,32767,32767,32767,32767,32767,32767,32767,32767,
  32767,32767,32767,32767,32767,32767,32767,32767,32767,32767,
  32767,32767,32767,32767,32767,32767,32767,32767,32767,   62,
     64,   67,   64,   69,   64,   14,   66,   66,   66,   66,
     66,   66,   66,   66,   66,   66,   66,   66,   66,   66,
     70,   29,   29,   29,   29,   29,   29,   29,   29,   29,
     60,   60,   60,   60,   60,   63,   63,   63,   63,   63,
     68,   63,   65,   65,   64,   64,   64,   64,   64,   63,
     30,   29,   29,   29,   29,   29,   62,   62,   62,   62,
     62,   68,   62,   62,   62,   62,   39,   39,   39,   39,
     39,   64,   64,   64,   64,   64,   63,   64,   64,   64,
     64,   58,   58,   58,   58,   62,   62,   62,   62,   62,
     62,   58,   58,   61,   61,   61,   61,   61,   63,   63,
     63,   63,   64,   64,   64,   64,   64,   64,   65,   65,
     64,   64,   64,   64,   64,   64,   59,   59,   62,   60,
     60,   62,   62,   64,   69,   60,   64,   64,   39,   58,
     58,   63,   70,   63,   60,   60
  };

  private static final short yygoto[] = {
     17,   18,   18,   18,    4,    5,    6,    7,    8,  423,
      1,   19,   20,   21,   22,   23,   99,   24,   39,   40,
     41,   42,   43,   38,   25,   26,   27,    2,   44,   45,
    100,  101,  411,  412,  413,    3,    9,   28,   29,   36,
     11,   12,   13,   14,   15,   16,  367,  130,  257,  258,
    259,  260,   51,   52,   53,   54,  204,   46,  108,  121,
    187,  191,  197,  198,  132,   82,  126,   31,   32,   33,
     34,  389,  390,  293,  294,  295,  296,  297,  120,  134,
    135,  136,  137,  138,  139,  140,  141,  142,  143,  144,
    145,  146,   86,  236,  237,  238,  239,  240,  241,  242,
    243,   97,   98,   95,  154,  157,  158,  159,  160,  328,
    161,  162,  163,  164,   49,   87,   88,   94,  114,  393,
      0,    0,  266,  267,  268,  269,  270,  378,   35,  377,
    391,  105,  106,  169,  170,  171,  172,  173,  174,    0,
      0,  166,  167,  168,    0,  372,    0,   90,  250,   91,
    175,  176,    0,  371,  276,    0,    0,    0,  262,  263,
    264,    0,    0,    0,    0,    0,  190,    0,  185,  192,
    193,    0,  147,  148,  149,  150,  151,    0,    0,    0,
      0,    0,    0,  183,  184,    0,    0,    0,  194,  196,
      0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
      0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
      0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
      0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
      0,    0,    0,    0,    0,  346,    0,  340,    0,  345,
      0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
      0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
      0,  122,  123,    0,    0,    0,    0,  125,    0,    0,
      0,    0,    0,    0,    0,    0,  127,  128,    0,  251,
    252,  253,  254,  255,    0,    0,    0,    0,    0,    0,
      0,    0,    0,  265,    0,    0,    0,    0,    0,    0,
      0,    0,    0,    0,    0,    0,  351,  353,  352,  354,
    355,    0,  356,  357,  358,  359,    0,    0,    0,    0,
    178,  179,  180,  181,  182,    0,    0,    0,    0,    0,
      0,    0,    0,    0,    0,    0,    0,  380,  381,  382,
    383,  384,  385,    0,    0,  388,  360,  361,  362,  363,
    364,    0,    0,    0,    0,    0,    0,    0,  376,    0,
      0,  386,  387,  188,  189
  };
  private static final int YYGLAST = 365;

  private static final byte yygcheck[] = {
      1,    1,    1,    1,    1,    1,    1,    1,    1,    1,
      1,    1,    1,    1,    1,    1,    1,    1,    1,    1,
      1,    1,    1,    1,    1,    1,    1,    1,    1,    1,
      1,    1,    1,    1,    1,    1,    1,    1,    1,    1,
      1,    1,    1,    1,    1,    1,   17,   15,   32,   32,
     32,   32,   16,   16,   16,   16,   29,   16,    5,    5,
     12,   12,   12,   12,   14,   16,   13,    6,    6,    6,
      6,    9,    9,   32,   32,   32,   32,   32,   39,   37,
     37,   37,   37,   37,   37,   37,   37,   37,   37,   37,
     37,   37,   16,   31,   31,   31,   31,   31,   31,   31,
     31,    2,    2,    2,   15,   15,   15,   15,   15,   19,
     15,   15,   15,   15,   16,   16,   16,   16,   18,   20,
     -1,   -1,   31,   31,   31,   31,   31,    8,    6,    8,
      8,    8,    8,   15,   15,   15,   15,   15,   15,   -1,
     -1,   11,   11,   11,   -1,   34,   -1,   16,   34,   16,
     11,   11,   -1,   34,   34,   -1,   -1,   -1,   32,   32,
     32,   -1,   -1,   -1,   -1,   -1,   15,   -1,   12,   15,
     15,   -1,   13,   13,   13,   13,   13,   -1,   -1,   -1,
     -1,   -1,   -1,   18,   18,   -1,   -1,   -1,   11,   11,
     -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
     -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
     -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
     -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
     -1,   -1,   -1,   -1,   -1,   17,   -1,   17,   -1,   17,
     -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
     -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
     -1,   13,   13,   -1,   -1,   -1,   -1,   13,   -1,   -1,
     -1,   -1,   -1,   -1,   -1,   -1,   13,   13,   -1,   17,
     17,   17,   17,   17,   -1,   -1,   -1,   -1,   -1,   -1,
     -1,   -1,   -1,   32,   -1,   -1,   -1,   -1,   -1,   -1,
     -1,   -1,   -1,   -1,   -1,   -1,   17,   17,   17,   17,
     17,   -1,   17,   17,   17,   17,   -1,   -1,   -1,   -1,
     14,   14,   14,   14,   14,   -1,   -1,   -1,   -1,   -1,
     -1,   -1,   -1,   -1,   -1,   -1,   -1,   17,   17,   17,
     17,   17,   17,   -1,   -1,   17,   17,   17,   17,   17,
     17,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   17,   -1,
     -1,   17,   17,   12,   12
  };

  private static final short yygbase[] = {
      0,  -46,    9,    0,    0,   10, -200,    0,    4,  -34,
      0, -141,   47,  -58,   27, -152, -184,   35, -125, -215,
   -213,    0,    0,    0,    0,    0,    0,    0,    0,  -47,
      0, -129,   43,    0,   34,    0,    0, -128,    0, -183
  };

  private static final short yygdefault[] = {
  -32768,   10,   96,  155,  442,  107,   30,  374,  104,  379,
     89,  165,  186,  131,  195,  177,   50,  368,  111,  205,
    344,  129,  102,  109,  338,  113,   37,  199,  342,  200,
    349,  235,  256,  115,  249,  116,  117,  133,  103,  110
  };

  private static final byte yylhs[] = {
      0,   21,   23,   23,   24,   27,   22,   22,   28,   25,
     25,   29,   29,   26,   26,   30,   30,   30,   30,   30,
     30,   30,   30,   30,   30,   30,   30,   30,   30,   31,
     32,   33,   33,   35,   35,   36,   36,   34,    6,    6,
      7,    7,    7,    7,    7,    7,    7,    7,    7,    7,
      7,    7,    7,    9,    9,    9,    9,    8,   11,   12,
     13,   14,   15,   16,   17,   18,   37,   38,   39,   19,
     20,   10,   10,    1,    1,    1,    1,    1,    1,    1,
      1,    1,    1,    1,    1,    1,    1,    1,    1,    1,
      1,    1,    1,    1,    1,    1,    1,    1,    1,    1,
      1,    2,    2,    2,    2,    2,    2,    2,    4,    4,
      4,    4,    4,    4,    4,    3,    5,    5,    5
  };

  private static final byte yylen[] = {
      1,    2,    2,    0,    5,    1,    2,    0,    8,    5,
      2,    1,    1,    2,    0,   10,   10,   10,   10,   10,
     10,   10,   10,   10,   12,   12,   12,   12,   12,    0,
      0,    7,    4,    3,    1,    3,    1,    1,    2,    0,
     10,   11,    9,   10,    4,    4,    4,    4,    4,    4,
     10,   10,    4,   10,   11,    3,    0,    6,    0,    0,
      0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
      0,    1,    1,    3,    3,    3,    3,    3,    3,    3,
      3,    3,    3,    3,    3,    3,    3,    2,    2,    2,
      5,    3,    3,    3,    3,    3,    3,    3,    3,    3,
      1,    4,    4,    6,    3,    4,    1,    3,    1,    1,
      1,    1,    1,    1,    1,    1,    3,    1,    0
  };
  private static final int YYSTATES = 402;
  private static final int YYNLSTATES = 336;
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
{ yyval = handleCommand(((ParseInfo)yyastk[yysp-(5-1)]).getValue(), ((String)yyastk[yysp-(5-2)]), ((ParseInfo)yyastk[yysp-(5-1)])); } break;
          case 5:
{ yyval = ((ParseInfo)yyastk[yysp-(1-1)]).getValue(); } break;
          case 6:
{ ((List)yyastk[yysp-(2-1)]).add(((Ast.Ruleset)yyastk[yysp-(2-2)])); yyval = ((List)yyastk[yysp-(2-1)]); } break;
          case 7:
{ yyval = new ArrayList(); } break;
          case 8:
{
		yyval = _f.createRuleset(((ParseInfo)yyastk[yysp-(8-3)]), ((List)yyastk[yysp-(8-1)]), ((List)yyastk[yysp-(8-5)]), ((ParseInfo)yyastk[yysp-(8-7)]));
	  } break;
          case 9:
{ ((List)yyastk[yysp-(5-1)]).add(((Ast.Selector)yyastk[yysp-(5-4)])); yyval = ((List)yyastk[yysp-(5-1)]); } break;
          case 10:
{ List l = new ArrayList(); l.add(((Ast.Selector)yyastk[yysp-(2-1)])); yyval = l; } break;
          case 11:
{ yyval = _f.createSelector(((ParseInfo)yyastk[yysp-(1-1)])); } break;
          case 12:
{ yyval = _f.createSelector(((ParseInfo)yyastk[yysp-(1-1)])); } break;
          case 13:
{ ((List)yyastk[yysp-(2-1)]).add(((Ast.Declaration)yyastk[yysp-(2-2)])); yyval = ((List)yyastk[yysp-(2-1)]); } break;
          case 14:
{ yyval = new ArrayList(); } break;
          case 15:
{ yyval = _f.createDeclaration(((ParseInfo)yyastk[yysp-(10-1)]), ((Ast.Expression)yyastk[yysp-(10-6)])); } break;
          case 16:
{ yyval = _f.createDeclaration(((ParseInfo)yyastk[yysp-(10-1)]), ((Ast.Expression)yyastk[yysp-(10-6)])); } break;
          case 17:
{ yyval = _f.createDeclaration(((ParseInfo)yyastk[yysp-(10-1)]), ((Ast.Expression)yyastk[yysp-(10-6)])); } break;
          case 18:
{ yyval = _f.createDeclaration(((ParseInfo)yyastk[yysp-(10-1)]), ((Ast.Expression)yyastk[yysp-(10-6)])); } break;
          case 19:
{ yyval = _f.createDeclaration(((ParseInfo)yyastk[yysp-(10-1)]), ((Ast.Expression)yyastk[yysp-(10-6)])); } break;
          case 20:
{ yyval = _f.createDeclaration(((ParseInfo)yyastk[yysp-(10-1)]), ((Map)yyastk[yysp-(10-6)])); } break;
          case 21:
{ yyval = _f.createDeclaration(((ParseInfo)yyastk[yysp-(10-1)]), ((List)yyastk[yysp-(10-6)])); } break;
          case 22:
{ yyval = _f.createDeclaration(((ParseInfo)yyastk[yysp-(10-1)]), ((List)yyastk[yysp-(10-6)])); } break;
          case 23:
{ yyval = _f.createDeclaration(((ParseInfo)yyastk[yysp-(10-1)]), ((String)yyastk[yysp-(10-6)])); } break;
          case 24:
{ yyval = _f.createLogicDeclaration(((ParseInfo)yyastk[yysp-(12-1)]), ((List)yyastk[yysp-(12-8)]), ((ParseInfo)yyastk[yysp-(12-11)])); } break;
          case 25:
{ yyval = _f.createLogicDeclaration(((ParseInfo)yyastk[yysp-(12-1)]), ((List)yyastk[yysp-(12-8)]), ((ParseInfo)yyastk[yysp-(12-11)])); } break;
          case 26:
{ yyval = _f.createLogicDeclaration(((ParseInfo)yyastk[yysp-(12-1)]), ((List)yyastk[yysp-(12-8)]), ((ParseInfo)yyastk[yysp-(12-11)])); } break;
          case 27:
{ yyval = _f.createLogicDeclaration(((ParseInfo)yyastk[yysp-(12-1)]), ((List)yyastk[yysp-(12-8)]), ((ParseInfo)yyastk[yysp-(12-11)])); } break;
          case 28:
{ yyval = _f.createLogicDeclaration(((ParseInfo)yyastk[yysp-(12-1)]), ((List)yyastk[yysp-(12-8)]), ((ParseInfo)yyastk[yysp-(12-11)])); } break;
          case 29:
{ _scanner.setRulesetMode(false); } break;
          case 30:
{ _scanner.setRulesetMode(true);  } break;
          case 31:
{ Map m = ((Map)yyastk[yysp-(7-1)]); m.put(((String)yyastk[yysp-(7-4)]), ((Ast.Expression)yyastk[yysp-(7-6)])); yyval = m; } break;
          case 32:
{ Map m = new HashMap(); m.put(((String)yyastk[yysp-(4-1)]), ((Ast.Expression)yyastk[yysp-(4-3)])); yyval = m; } break;
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
{ yyval = _f.createPrintStatement(((ParseInfo)yyastk[yysp-(10-1)]), ((List)yyastk[yysp-(10-5)])); } break;
          case 41:
{ yyval = _f.createForeachStatement(((ParseInfo)yyastk[yysp-(11-1)]), ((Ast.Expression)yyastk[yysp-(11-5)]), ((Ast.Expression)yyastk[yysp-(11-7)]), ((Ast.Statement)yyastk[yysp-(11-11)])); } break;
          case 42:
{ yyval = _f.createWhileStatement(((ParseInfo)yyastk[yysp-(9-1)]), ((Ast.Expression)yyastk[yysp-(9-5)]), ((Ast.Statement)yyastk[yysp-(9-9)])); } break;
          case 43:
{ yyval = _f.createIfStatement(((ParseInfo)yyastk[yysp-(10-1)]), ((Ast.Expression)yyastk[yysp-(10-5)]), ((Ast.Statement)yyastk[yysp-(10-9)]), ((Ast.Statement)yyastk[yysp-(10-10)])); } break;
          case 44:
{ yyval = _f.createBreakStatement(((ParseInfo)yyastk[yysp-(4-1)])); } break;
          case 45:
{ yyval = _f.createContinueStatement(((ParseInfo)yyastk[yysp-(4-1)])); } break;
          case 46:
{ yyval = _f.createStagStatement(((ParseInfo)yyastk[yysp-(4-1)])); } break;
          case 47:
{ yyval = _f.createContStatement(((ParseInfo)yyastk[yysp-(4-1)])); } break;
          case 48:
{ yyval = _f.createEtagStatement(((ParseInfo)yyastk[yysp-(4-1)])); } break;
          case 49:
{ yyval = _f.createElemStatement(((ParseInfo)yyastk[yysp-(4-1)])); } break;
          case 50:
{ yyval = _f.createElementStatement(((ParseInfo)yyastk[yysp-(10-1)]), ((ParseInfo)yyastk[yysp-(10-5)])); } break;
          case 51:
{ yyval = _f.createContentStatement(((ParseInfo)yyastk[yysp-(10-1)]), ((ParseInfo)yyastk[yysp-(10-5)])); } break;
          case 52:
{ yyval = _f.createExpressionStatement(((ParseInfo)yyastk[yysp-(4-3)]), ((Ast.Expression)yyastk[yysp-(4-1)])); } break;
          case 53:
{ yyval = _f.createIfStatement(((ParseInfo)yyastk[yysp-(10-1)]), ((Ast.Expression)yyastk[yysp-(10-5)]), ((Ast.Statement)yyastk[yysp-(10-9)]), ((Ast.Statement)yyastk[yysp-(10-10)])); } break;
          case 54:
{ yyval = _f.createIfStatement(((ParseInfo)yyastk[yysp-(11-2)]), ((Ast.Expression)yyastk[yysp-(11-6)]), ((Ast.Statement)yyastk[yysp-(11-10)]), ((Ast.Statement)yyastk[yysp-(11-11)])); } break;
          case 55:
{ yyval = ((Ast.Statement)yyastk[yysp-(3-3)]); } break;
          case 56:
{ yyval = null; } break;
          case 57:
{ yyval = _f.createBlockStatement(((ParseInfo)yyastk[yysp-(6-1)]), ((List)yyastk[yysp-(6-3)])); } break;
          case 58:
{ _expected = '('; } break;
          case 59:
{ _expected = ')'; } break;
          case 60:
{ _expected = '{'; } break;
          case 61:
{ _expected = '}'; } break;
          case 62:
{ _expected = ';'; } break;
          case 63:
{ _expected = 'X'; } break;
          case 64:
{ _expected =  0; } break;
          case 65:
{ _expected = 'N'; } break;
          case 66:
{ _expected = ':'; } break;
          case 67:
{ _expected = 'S'; } break;
          case 68:
{ _expected = 'A'; } break;
          case 69:
{  _expected = 0;  enterBlock(); } break;
          case 70:
{  _expected = 0;  exitBlock(); } break;
          case 72:
{
	        if (! ((ParseInfo)yyastk[yysp-(1-1)]).getValue().equals("in")) {
	              throw new SyntaxException("'in' or '=' expected.", _filename, ((ParseInfo)yyastk[yysp-(1-1)]).getLinenum(), ((ParseInfo)yyastk[yysp-(1-1)]).getColumn());
		}
          } break;
          case 73:
{ yyval = _f.createArithmeticExpression(((ParseInfo)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 74:
{ yyval = _f.createArithmeticExpression(((ParseInfo)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 75:
{ yyval = _f.createArithmeticExpression(((ParseInfo)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 76:
{ yyval = _f.createArithmeticExpression(((ParseInfo)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 77:
{ yyval = _f.createArithmeticExpression(((ParseInfo)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 78:
{ yyval = _f.createArithmeticExpression(((ParseInfo)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 79:
{ yyval = _f.createRelationalExpression(((ParseInfo)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 80:
{ yyval = _f.createRelationalExpression(((ParseInfo)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 81:
{ yyval = _f.createRelationalExpression(((ParseInfo)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 82:
{ yyval = _f.createRelationalExpression(((ParseInfo)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 83:
{ yyval = _f.createRelationalExpression(((ParseInfo)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 84:
{ yyval = _f.createRelationalExpression(((ParseInfo)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 85:
{ yyval = _f.createLogicalExpression(((ParseInfo)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 86:
{ yyval = _f.createLogicalExpression(((ParseInfo)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 87:
{ yyval = _f.createLogicalExpression(((ParseInfo)yyastk[yysp-(2-1)]), ((Ast.Expression)yyastk[yysp-(2-2)]), null); } break;
          case 88:
{ yyval = _f.createUnaryExpression(((ParseInfo)yyastk[yysp-(2-1)]), ((Ast.Expression)yyastk[yysp-(2-2)])); } break;
          case 89:
{ yyval = _f.createUnaryExpression(((ParseInfo)yyastk[yysp-(2-1)]), ((Ast.Expression)yyastk[yysp-(2-2)])); } break;
          case 90:
{ yyval = _f.createConditionalExpression(((ParseInfo)yyastk[yysp-(5-2)]), ((Ast.Expression)yyastk[yysp-(5-1)]), ((Ast.Expression)yyastk[yysp-(5-3)]), ((Ast.Expression)yyastk[yysp-(5-5)])); } break;
          case 91:
{ yyval = _f.createAssignmentExpression(((ParseInfo)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 92:
{ yyval = _f.createAssignmentExpression(((ParseInfo)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 93:
{ yyval = _f.createAssignmentExpression(((ParseInfo)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 94:
{ yyval = _f.createAssignmentExpression(((ParseInfo)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 95:
{ yyval = _f.createAssignmentExpression(((ParseInfo)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 96:
{ yyval = _f.createAssignmentExpression(((ParseInfo)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 97:
{ yyval = _f.createAssignmentExpression(((ParseInfo)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 98:
{ yyval = _f.createAssignmentExpression(((ParseInfo)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 99:
{ yyval = _f.createAssignmentExpression(((ParseInfo)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 100:
{ yyval = ((Ast.Expression)yyastk[yysp-(1-1)]); } break;
          case 101:
{ yyval = _f.createIndexExpression(((ParseInfo)yyastk[yysp-(4-2)]), ((Ast.Expression)yyastk[yysp-(4-1)]), ((Ast.Expression)yyastk[yysp-(4-3)])); } break;
          case 102:
{ yyval = _f.createIndex2Expression(((ParseInfo)yyastk[yysp-(4-2)]), ((Ast.Expression)yyastk[yysp-(4-1)]), ((Ast.Literal)yyastk[yysp-(4-3)])); } break;
          case 103:
{ yyval = _f.createMethodExpression(((ParseInfo)yyastk[yysp-(6-2)]), ((Ast.Expression)yyastk[yysp-(6-1)]), (((ParseInfo)yyastk[yysp-(6-3)])).getValue(), ((List)yyastk[yysp-(6-5)])); } break;
          case 104:
{ yyval = _f.createPropertyExpression(((ParseInfo)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), (((ParseInfo)yyastk[yysp-(3-3)])).getValue()); } break;
          case 105:
{ yyval = _f.createFuncallExpression(((ParseInfo)yyastk[yysp-(4-1)]), ((List)yyastk[yysp-(4-3)])); } break;
          case 106:
{ yyval = ((Ast.Literal)yyastk[yysp-(1-1)]); } break;
          case 107:
{ yyval = ((Ast.Expression)yyastk[yysp-(3-2)]); } break;
          case 108:
{ yyval = _f.createVariableLiteral(((ParseInfo)yyastk[yysp-(1-1)])); } break;
          case 109:
{ yyval = _f.createStringLiteral(((ParseInfo)yyastk[yysp-(1-1)])); } break;
          case 110:
{ yyval = _f.createIntegerLiteral(((ParseInfo)yyastk[yysp-(1-1)])); } break;
          case 111:
{ yyval = _f.createFloatLiteral(((ParseInfo)yyastk[yysp-(1-1)])); } break;
          case 112:
{ yyval = _f.createTrueLiteral(((ParseInfo)yyastk[yysp-(1-1)])); } break;
          case 113:
{ yyval = _f.createFalseLiteral(((ParseInfo)yyastk[yysp-(1-1)])); } break;
          case 114:
{ yyval = _f.createNullLiteral(((ParseInfo)yyastk[yysp-(1-1)])); } break;
          case 115:
{ yyval = _f.createStringLiteral(((ParseInfo)yyastk[yysp-(1-1)])); } break;
          case 116:
{ ((List)yyastk[yysp-(3-1)]).add(((Ast.Expression)yyastk[yysp-(3-3)])); yyval = ((List)yyastk[yysp-(3-1)]); } break;
          case 117:
{ List l = new ArrayList(); l.add(((Ast.Expression)yyastk[yysp-(1-1)])); yyval = l; } break;
          case 118:
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




