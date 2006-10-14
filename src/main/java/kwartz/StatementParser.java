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


public class StatementParser extends Parser {


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
  



  private static final byte yytranslate[] = {
      0,   59,   59,   59,   59,   59,   59,   59,   59,   59,
     59,   59,   59,   59,   59,   59,   59,   59,   59,   59,
     59,   59,   59,   59,   59,   59,   59,   59,   59,   59,
     59,   59,   59,   49,   59,   59,   59,   48,   59,   59,
     53,   54,   46,   44,   55,   45,   50,   47,   59,   59,
     59,   59,   59,   59,   59,   59,   59,   59,   41,   56,
     43,   39,   42,   40,   59,   59,   59,   59,   59,   59,
     59,   59,   59,   59,   59,   59,   59,   59,   59,   59,
     59,   59,   59,   59,   59,   59,   59,   59,   59,   59,
     59,   51,   59,   52,   59,   59,   59,   59,   59,   59,
     59,   59,   59,   59,   59,   59,   59,   59,   59,   59,
     59,   59,   59,   59,   59,   59,   59,   59,   59,   59,
     59,   59,   59,   57,   59,   58,   59,   59,   59,   59,
     59,   59,   59,   59,   59,   59,   59,   59,   59,   59,
     59,   59,   59,   59,   59,   59,   59,   59,   59,   59,
     59,   59,   59,   59,   59,   59,   59,   59,   59,   59,
     59,   59,   59,   59,   59,   59,   59,   59,   59,   59,
     59,   59,   59,   59,   59,   59,   59,   59,   59,   59,
     59,   59,   59,   59,   59,   59,   59,   59,   59,   59,
     59,   59,   59,   59,   59,   59,   59,   59,   59,   59,
     59,   59,   59,   59,   59,   59,   59,   59,   59,   59,
     59,   59,   59,   59,   59,   59,   59,   59,   59,   59,
     59,   59,   59,   59,   59,   59,   59,   59,   59,   59,
     59,   59,   59,   59,   59,   59,   59,   59,   59,   59,
     59,   59,   59,   59,   59,   59,   59,   59,   59,   59,
     59,   59,   59,   59,   59,   59,    1,    2,   59,    3,
      4,    5,    6,    7,    8,    9,   10,   11,   12,   13,
     14,   15,   16,   17,   59,   18,   59,   19,   20,   21,
     22,   23,   59,   59,   59,   59,   24,   59,   59,   59,
     25,   59,   26,   27,   28,   29,   30,   31,   32,   59,
     59,   59,   33,   34,   35,   36,   37,   38,   59,   59,
     59,   59,   59,   59,   59,   59,   59,   59,   59,   59,
     59,   59,   59,   59,   59,   59,   59,   59
  };
  private static final int YYBADCH = 59;
  private static final int YYMAXLEX = 328;
  private static final int YYTERMS = 59;
  private static final int YYNONTERMS = 21;

  private static final short yyaction[] = {
     42,  246,   44,   45,   46,   47,   48,   49,  126,  127,
      0,   84,  128,  129,  130,  131,  132,  133,  134,  135,
    136,  137,-32766,-32766,  109,  203,   53,-32766,   54,   55,
     56,   57,   58,   59,   60,  126,  127,  107,   61,  128,
    129,  130,  131,  132,  133,  134,  135,  136,  137,   93,
    241,  242,  240,  243,  244,  245,  151,   37,   38,   39,
     40,   41,  202,   43,-32766,-32766,   58,   59,   60,  152,
     50,   51,  164,   88,-32766,   37,   38,   39,   40,   41,
    233,   43,  165,  140,-32766,   32,   34,   52,   50,   51,
    138,   69,   70,-32766,  139,  141,   35,  153,  167,  148,
     36,    0,  238,  149,  166,   52,   37,   38,   39,   40,
     41,  168,   43,  234,  236,  170,  169,  160,  232,   50,
     51,   37,   38,   39,   40,   41,  157,   43,  156,  155,
    154,    0,   62,    0,   50,   51,   52,  142,   65,-32767,
  -32767,-32767,-32767,-32766,-32766,  162,  161,  158,  145,  144,
    143,   52,  150,    0,  147,  146,    0,  159,    0,    0,
      0,    0,    0,-32766,    0,-32767,-32767
  };
  private static final int YYLAST = 167;

  private static final byte yycheck[] = {
     14,    2,   16,   17,   18,   19,   20,   21,   25,   26,
      0,   24,   29,   30,   31,   32,   33,   34,   35,   36,
     37,   38,   44,   45,    2,    2,   40,   49,   42,   43,
     44,   45,   46,   47,   48,   25,   26,   50,   51,   29,
     30,   31,   32,   33,   34,   35,   36,   37,   38,    2,
      3,    4,    5,    6,    7,    8,    2,    9,   10,   11,
     12,   13,   39,   15,   20,   21,   46,   47,   48,    2,
     22,   23,   27,   28,   21,    9,   10,   11,   12,   13,
     52,   15,   26,   53,   40,   53,   53,   39,   22,   23,
     53,   44,   45,   40,   53,   53,   49,   54,   58,   53,
     53,   -1,   54,   53,   53,   39,    9,   10,   11,   12,
     13,   53,   15,   54,   54,   54,   54,   54,   52,   22,
     23,    9,   10,   11,   12,   13,   54,   15,   54,   54,
     54,   -1,   55,   -1,   22,   23,   39,   56,   41,   16,
     17,   18,   19,   20,   21,   56,   56,   56,   56,   56,
     56,   39,   56,   -1,   56,   56,   -1,   57,   -1,   -1,
     -1,   -1,   -1,   40,   -1,   42,   43
  };

  private static final short yybase[] = {
      0,   48,   97,   66,   10,  112,  112,  112,  112,  112,
    112,  112,  112,  112,  112,  112,  112,  112,  112,  112,
    112,  112,  -17,  -14,   53,  123,  123,  123,  123,   44,
    123,  123,   47,   47,   47,   47,   47,   47,   47,   47,
     47,   47,   47,   47,   47,   47,   47,   47,   47,   47,
     47,   47,   47,   47,   47,   47,   47,   47,   47,   47,
     47,   47,   47,   47,   47,   47,   47,   47,   47,  -22,
    -22,  -22,   23,  -13,  -13,  -13,   20,   20,   20,   45,
     45,   45,   60,   59,   -1,   77,  100,  100,   56,  100,
    100,  100,  100,   32,   37,   41,   30,   42,   81,   94,
     93,   92,   99,   98,   46,   50,   96,   22,   28,   33,
     54,   67,   43,   76,   75,   74,   72,   91,   63,   90,
     89,   51,   40,   58,   62,   61,    0,    0,    0,    0,
      0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
      0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
      0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
      0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
      0,    0,  -14,  -14,  -14,   47,  -14,  -14,  -14,  -14,
    -14,  -14,  -14,  -14,  -14,  -14,  -14,  -14,  -14,  -14,
    -14,  -14,  -14,   47,    0,  -14,  -14,  -14,  -14,  -14,
    -14,  -14,  -14,    0,    0,    0,    0,    0,    0,    0,
      0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
      0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
      0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
     47,   47,   47,  -13,    0,    0,    0,    0,    0,    0,
      0,    0,    0,   77,   77
  };
  private static final int YY2TBLSTATE = 84;

  private static final short yydefault[] = {
      2,32767,32767,32767,32767,   25,   22,   22,   22,   22,
     22,   77,   52,   53,   54,   55,   56,   57,   58,   59,
     51,   76,   24,   50,   46,   39,   40,   42,   44,   45,
     41,   43,   78,   78,   78,32767,32767,32767,32767,32767,
  32767,32767,32767,32767,32767,32767,32767,32767,32767,32767,
  32767,32767,32767,32767,32767,32767,32767,32767,32767,32767,
  32767,32767,32767,32767,32767,32767,32767,32767,32767,32767,
  32767,32767,32767,   60,   49,   48,   38,   33,   34,   19,
     19,   19,32767,32767,32767,   22,32767,32767,   23,32767,
  32767,32767,32767,   68,32767,32767,32767,32767,32767,32767,
  32767,32767,32767,32767,32767,32767,32767,32767,32767,   64,
  32767,32767,32767,32767,32767,32767,32767,32767,32767,32767,
  32767,32767,32767,32767,32767,32767,   21,   21,   21,   21,
     25,   25,   25,   25,   25,   25,   21,   21,   26,   26,
     26,   26,   27,   27,   27,   27,   27,   27,   28,   28,
     27,   22,   22,   25,   23,   23,   25,   25,   27,   29,
     23,   27,   27,    2,   21,   21,   26,   30,   26,   23,
     23
  };

  private static final short yygoto[] = {
      5,   98,   99,  100,  101,  102,  103,  179,  180,  181,
    182,  183,   85,   83,  186,   74,   75,   72,    5,  187,
    188,  111,  174,   22,  117,  184,  185,  119,  120,    0,
      0,  218,    1,   12,   13,   14,   15,   16,   76,   17,
     25,   26,   27,   28,   29,   24,   18,   19,   20,    2,
     30,   31,   77,   78,  206,  207,  208,    3,   21,    6,
      7,   23,    8,    9,   10,  114,  118,  124,  125,   95,
     96,   97,   63,   64,   71,   86,   87,    0,  104,  105,
    176,   89,  175,  189,   80,   81,    0,    0,    0,    0,
     91,   92,    0,    0,    0,    0,    0,    0,    0,   67,
      0,   68,    0,    0,    0,    0,  121,  123,    0,    0,
      0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
      0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
      0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
      0,    0,    0,  112,    0,    0,    0,    0,    0,    0,
      0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
      0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
      0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
      0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
      0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
      0,    0,    0,    0,    0,    0,    0,    0,    0,  115,
    116
  };
  private static final int YYGLAST = 211;

  private static final byte yygcheck[] = {
      1,   15,   15,   15,   15,   15,   15,   17,   17,   17,
     17,   17,    5,    5,   17,    2,    2,    2,    1,    9,
      9,   18,   17,    6,   15,   17,   17,   15,   15,   -1,
     -1,    1,    1,    1,    1,    1,    1,    1,    1,    1,
      1,    1,    1,    1,    1,    1,    1,    1,    1,    1,
      1,    1,    1,    1,    1,    1,    1,    1,    1,    1,
      1,    1,    1,    1,    1,   12,   12,   12,   12,   11,
     11,   11,   16,   16,   16,   13,   13,   -1,   11,   11,
      8,   13,    8,    8,    8,    8,   -1,   -1,   -1,   -1,
     13,   13,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   16,
     -1,   16,   -1,   -1,   -1,   -1,   11,   11,   -1,   -1,
     -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
     -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
     -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
     -1,   -1,   -1,   12,   -1,   -1,   -1,   -1,   -1,   -1,
     -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
     -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
     -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
     -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
     -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
     -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   12,
     12
  };

  private static final short yygbase[] = {
      0,   -4,  -54,    0,    0,  -21, -140,    0,   -7,  -61,
      0,  -58,   58,  -79,    0, -129,  -67, -136, -128,    0,
      0
  };

  private static final short yygdefault[] = {
  -32768,   11,   73,  108,  237,   82,    4,  172,   79,  177,
     66,   94,  113,   90,  122,  106,   33,  178,  110,  163,
    191
  };

  private static final byte yylhs[] = {
      0,    6,    6,    7,    7,    7,    7,    7,    7,    7,
      7,    7,    7,    7,    7,    7,    9,    9,    9,    9,
      8,   11,   12,   13,   14,   15,   16,   17,   18,   19,
     20,   10,   10,    1,    1,    1,    1,    1,    1,    1,
      1,    1,    1,    1,    1,    1,    1,    1,    1,    1,
      1,    1,    1,    1,    1,    1,    1,    1,    1,    1,
      1,    2,    2,    2,    2,    2,    2,    2,    4,    4,
      4,    4,    4,    4,    4,    3,    5,    5,    5
  };

  private static final byte yylen[] = {
      1,    2,    0,   10,   11,    9,   10,    4,    4,    4,
      4,    4,    4,   10,   10,    4,   10,   11,    3,    0,
      6,    0,    0,    0,    0,    0,    0,    0,    0,    0,
      0,    1,    1,    3,    3,    3,    3,    3,    3,    3,
      3,    3,    3,    3,    3,    3,    3,    2,    2,    2,
      5,    3,    3,    3,    3,    3,    3,    3,    3,    3,
      1,    4,    4,    6,    3,    4,    1,    3,    1,    1,
      1,    1,    1,    1,    1,    1,    3,    1,    0
  };
  private static final int YYSTATES = 208;
  private static final int YYNLSTATES = 171;
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
{ ((List)yyastk[yysp-(2-1)]).add(((Ast.Statement)yyastk[yysp-(2-2)])); yyval = ((List)yyastk[yysp-(2-1)]); } break;
          case 2:
{ yyval = new ArrayList(); } break;
          case 3:
{ yyval = _f.createPrintStatement(((ParseInfo)yyastk[yysp-(10-1)]), ((List)yyastk[yysp-(10-5)])); } break;
          case 4:
{ yyval = _f.createForeachStatement(((ParseInfo)yyastk[yysp-(11-1)]), ((Ast.Expression)yyastk[yysp-(11-5)]), ((Ast.Expression)yyastk[yysp-(11-7)]), ((Ast.Statement)yyastk[yysp-(11-11)])); } break;
          case 5:
{ yyval = _f.createWhileStatement(((ParseInfo)yyastk[yysp-(9-1)]), ((Ast.Expression)yyastk[yysp-(9-5)]), ((Ast.Statement)yyastk[yysp-(9-9)])); } break;
          case 6:
{ yyval = _f.createIfStatement(((ParseInfo)yyastk[yysp-(10-1)]), ((Ast.Expression)yyastk[yysp-(10-5)]), ((Ast.Statement)yyastk[yysp-(10-9)]), ((Ast.Statement)yyastk[yysp-(10-10)])); } break;
          case 7:
{ yyval = _f.createBreakStatement(((ParseInfo)yyastk[yysp-(4-1)])); } break;
          case 8:
{ yyval = _f.createContinueStatement(((ParseInfo)yyastk[yysp-(4-1)])); } break;
          case 9:
{ yyval = _f.createStagStatement(((ParseInfo)yyastk[yysp-(4-1)])); } break;
          case 10:
{ yyval = _f.createContStatement(((ParseInfo)yyastk[yysp-(4-1)])); } break;
          case 11:
{ yyval = _f.createEtagStatement(((ParseInfo)yyastk[yysp-(4-1)])); } break;
          case 12:
{ yyval = _f.createElemStatement(((ParseInfo)yyastk[yysp-(4-1)])); } break;
          case 13:
{ yyval = _f.createElementStatement(((ParseInfo)yyastk[yysp-(10-1)]), ((ParseInfo)yyastk[yysp-(10-5)])); } break;
          case 14:
{ yyval = _f.createContentStatement(((ParseInfo)yyastk[yysp-(10-1)]), ((ParseInfo)yyastk[yysp-(10-5)])); } break;
          case 15:
{ yyval = _f.createExpressionStatement(((ParseInfo)yyastk[yysp-(4-3)]), ((Ast.Expression)yyastk[yysp-(4-1)])); } break;
          case 16:
{ yyval = _f.createIfStatement(((ParseInfo)yyastk[yysp-(10-1)]), ((Ast.Expression)yyastk[yysp-(10-5)]), ((Ast.Statement)yyastk[yysp-(10-9)]), ((Ast.Statement)yyastk[yysp-(10-10)])); } break;
          case 17:
{ yyval = _f.createIfStatement(((ParseInfo)yyastk[yysp-(11-2)]), ((Ast.Expression)yyastk[yysp-(11-6)]), ((Ast.Statement)yyastk[yysp-(11-10)]), ((Ast.Statement)yyastk[yysp-(11-11)])); } break;
          case 18:
{ yyval = ((Ast.Statement)yyastk[yysp-(3-3)]); } break;
          case 19:
{ yyval = null; } break;
          case 20:
{ yyval = _f.createBlockStatement(((ParseInfo)yyastk[yysp-(6-1)]), ((List)yyastk[yysp-(6-3)])); } break;
          case 21:
{ _expected = '('; } break;
          case 22:
{ _expected = ')'; } break;
          case 23:
{ _expected = '{'; } break;
          case 24:
{ _expected = '}'; } break;
          case 25:
{ _expected = ';'; } break;
          case 26:
{ _expected = 'X'; } break;
          case 27:
{ _expected =  0; } break;
          case 28:
{ _expected = 'N'; } break;
          case 29:
{  _expected = 0;  enterBlock(); } break;
          case 30:
{  _expected = 0;  exitBlock(); } break;
          case 32:
{
	        if (! ((ParseInfo)yyastk[yysp-(1-1)]).getValue().equals("in")) {
	              throw new SyntaxException("'in' or '=' expected.", ((ParseInfo)yyastk[yysp-(1-1)]).getLinenum(), ((ParseInfo)yyastk[yysp-(1-1)]).getColumn());
		}
          } break;
          case 33:
{ yyval = _f.createArithmeticExpression(((ParseInfo)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 34:
{ yyval = _f.createArithmeticExpression(((ParseInfo)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 35:
{ yyval = _f.createArithmeticExpression(((ParseInfo)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 36:
{ yyval = _f.createArithmeticExpression(((ParseInfo)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 37:
{ yyval = _f.createArithmeticExpression(((ParseInfo)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 38:
{ yyval = _f.createArithmeticExpression(((ParseInfo)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 39:
{ yyval = _f.createRelationalExpression(((ParseInfo)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 40:
{ yyval = _f.createRelationalExpression(((ParseInfo)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 41:
{ yyval = _f.createRelationalExpression(((ParseInfo)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 42:
{ yyval = _f.createRelationalExpression(((ParseInfo)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 43:
{ yyval = _f.createRelationalExpression(((ParseInfo)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 44:
{ yyval = _f.createRelationalExpression(((ParseInfo)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 45:
{ yyval = _f.createLogicalExpression(((ParseInfo)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 46:
{ yyval = _f.createLogicalExpression(((ParseInfo)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 47:
{ yyval = _f.createLogicalExpression(((ParseInfo)yyastk[yysp-(2-1)]), ((Ast.Expression)yyastk[yysp-(2-2)]), null); } break;
          case 48:
{ yyval = _f.createUnaryExpression(((ParseInfo)yyastk[yysp-(2-1)]), ((Ast.Expression)yyastk[yysp-(2-2)])); } break;
          case 49:
{ yyval = _f.createUnaryExpression(((ParseInfo)yyastk[yysp-(2-1)]), ((Ast.Expression)yyastk[yysp-(2-2)])); } break;
          case 50:
{ yyval = _f.createConditionalExpression(((ParseInfo)yyastk[yysp-(5-2)]), ((Ast.Expression)yyastk[yysp-(5-1)]), ((Ast.Expression)yyastk[yysp-(5-3)]), ((Ast.Expression)yyastk[yysp-(5-5)])); } break;
          case 51:
{ yyval = _f.createAssignmentExpression(((ParseInfo)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 52:
{ yyval = _f.createAssignmentExpression(((ParseInfo)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 53:
{ yyval = _f.createAssignmentExpression(((ParseInfo)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 54:
{ yyval = _f.createAssignmentExpression(((ParseInfo)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 55:
{ yyval = _f.createAssignmentExpression(((ParseInfo)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 56:
{ yyval = _f.createAssignmentExpression(((ParseInfo)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 57:
{ yyval = _f.createAssignmentExpression(((ParseInfo)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 58:
{ yyval = _f.createAssignmentExpression(((ParseInfo)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 59:
{ yyval = _f.createAssignmentExpression(((ParseInfo)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 60:
{ yyval = ((Ast.Expression)yyastk[yysp-(1-1)]); } break;
          case 61:
{ yyval = _f.createIndexExpression(((ParseInfo)yyastk[yysp-(4-2)]), ((Ast.Expression)yyastk[yysp-(4-1)]), ((Ast.Expression)yyastk[yysp-(4-3)])); } break;
          case 62:
{ yyval = _f.createIndex2Expression(((ParseInfo)yyastk[yysp-(4-2)]), ((Ast.Expression)yyastk[yysp-(4-1)]), ((Ast.Literal)yyastk[yysp-(4-3)])); } break;
          case 63:
{ yyval = _f.createMethodExpression(((ParseInfo)yyastk[yysp-(6-2)]), ((Ast.Expression)yyastk[yysp-(6-1)]), (((ParseInfo)yyastk[yysp-(6-3)])).getValue(), ((List)yyastk[yysp-(6-5)])); } break;
          case 64:
{ yyval = _f.createPropertyExpression(((ParseInfo)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), (((ParseInfo)yyastk[yysp-(3-3)])).getValue()); } break;
          case 65:
{ yyval = _f.createFuncallExpression(((ParseInfo)yyastk[yysp-(4-1)]), ((List)yyastk[yysp-(4-3)])); } break;
          case 66:
{ yyval = ((Ast.Literal)yyastk[yysp-(1-1)]); } break;
          case 67:
{ yyval = ((Ast.Expression)yyastk[yysp-(3-2)]); } break;
          case 68:
{ yyval = _f.createVariableLiteral(((ParseInfo)yyastk[yysp-(1-1)])); } break;
          case 69:
{ yyval = _f.createStringLiteral(((ParseInfo)yyastk[yysp-(1-1)])); } break;
          case 70:
{ yyval = _f.createIntegerLiteral(((ParseInfo)yyastk[yysp-(1-1)])); } break;
          case 71:
{ yyval = _f.createFloatLiteral(((ParseInfo)yyastk[yysp-(1-1)])); } break;
          case 72:
{ yyval = _f.createTrueLiteral(((ParseInfo)yyastk[yysp-(1-1)])); } break;
          case 73:
{ yyval = _f.createFalseLiteral(((ParseInfo)yyastk[yysp-(1-1)])); } break;
          case 74:
{ yyval = _f.createNullLiteral(((ParseInfo)yyastk[yysp-(1-1)])); } break;
          case 75:
{ yyval = _f.createStringLiteral(((ParseInfo)yyastk[yysp-(1-1)])); } break;
          case 76:
{ ((List)yyastk[yysp-(3-1)]).add(((Ast.Expression)yyastk[yysp-(3-3)])); yyval = ((List)yyastk[yysp-(3-1)]); } break;
          case 77:
{ List l = new ArrayList(); l.add(((Ast.Expression)yyastk[yysp-(1-1)])); yyval = l; } break;
          case 78:
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




