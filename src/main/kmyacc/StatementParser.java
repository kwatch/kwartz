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
  private static final int YYNONTERMS = 11;

  private static final short yyaction[] = {
     39,   40,   41,   42,   43,   44,   45,   46,   47,   48,
     49,   50,   51,   52,   53,    0,   86,-32766,-32766,  140,
    115,   80,-32766,   60,   61,   62,  183,  111,  109,  108,
     54,   55,  116,   56,   57,   58,   59,   60,   61,   62,
     93,   94,  107,   63,   95,   96,   97,   98,   99,  100,
    101,  102,  103,  104,   93,   94,  139,   66,   95,   96,
     97,   98,   99,  100,  101,  102,  103,  104,-32766,-32766,
  -32766,-32766,-32766,  169,-32766,  170,  175,  117,    0,-32766,
  -32766,-32766,-32766,   38,   68,   71,  105,  134,   92,  178,
    179,  177,  180,  181,  182,  106,   32,   37,-32766,-32766,
     34,   33,-32766,-32766,-32766,-32766,-32766,   67,-32766,  112,
    113,  114,  173,    0,-32766,-32766,-32766,   44,  171,-32767,
  -32767,-32767,-32767,-32766,-32766,-32766,-32766,-32766,   87,-32766,
     69,   70,-32766,-32766,   88,   35,-32766,-32766,   89,   36,
     64,   90,   91,    0,    0,-32767,-32767,   58,   59,    0,
    133,  132,  131,-32766,  121,  130,  128,  127,  126,    0,
    125,  129
  };
  private static final int YYLAST = 162;

  private static final byte yycheck[] = {
      9,   10,   11,   12,   13,   14,   15,   16,   17,   18,
     19,   20,   21,   22,   23,    0,   24,   44,   45,    2,
     27,   28,   49,   46,   47,   48,    2,    2,    2,    2,
     39,   40,   26,   42,   43,   44,   45,   46,   47,   48,
     25,   26,   50,   51,   29,   30,   31,   32,   33,   34,
     35,   36,   37,   38,   25,   26,   39,   41,   29,   30,
     31,   32,   33,   34,   35,   36,   37,   38,    9,   10,
     11,   12,   13,   52,   15,   52,   54,   57,   -1,   20,
     21,   22,   23,   53,   53,   53,   53,   58,    2,    3,
      4,    5,    6,    7,    8,   53,   53,   53,   39,   40,
     53,   53,    9,   10,   11,   12,   13,   53,   15,   54,
     54,   54,   54,   -1,   21,   22,   23,   14,   54,   16,
     17,   18,   19,    9,   10,   11,   12,   13,   54,   15,
     44,   45,   39,   40,   54,   49,   22,   23,   54,   53,
     55,   54,   54,   -1,   -1,   42,   43,   44,   45,   -1,
     56,   56,   56,   39,   56,   56,   56,   56,   56,   -1,
     56,   56
  };

  private static final short yybase[] = {
      0,   94,   22,   74,   80,   16,   21,   84,   87,   88,
     15,   29,   -9,   -9,   -9,   -9,   -9,   -9,   -9,   -9,
     -9,   -9,   -9,  114,   93,  103,  103,  103,  103,   59,
    103,  103,   86,   86,   86,   86,   86,   86,   86,   86,
     86,   86,   86,   86,   86,   86,   86,   86,   86,   86,
     86,   86,   86,   86,   86,   86,   86,   86,   86,   86,
     86,   86,   86,   86,   86,   86,   86,   86,   86,  -27,
    -27,  -27,   17,   -8,   -8,   -8,  -23,  -23,  -23,   -7,
      6,   -7,   -7,   58,   55,   64,   24,   20,   20,   20,
     20,   20,   43,   48,   44,   30,   32,  104,  102,  101,
    100,  105,   99,   33,   42,   27,   26,   25,   56,   57,
     23,   47,   98,   96,   95,   54,   31,    0,    0,   -9,
     -9,   -9,   -9,   -9,   -9,   -9,   -9,   -9,   86,   86,
      0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
      0,   -9,   -9,  -23,  -23,  -23,  -23,   -9,  -23,  -23,
      0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
      0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
      0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
      0,    0,    0,    0,    0,    0,    0,   86,   86,   86,
     -8,    0,    0,    0,    0,    0,    0,    0,   20,    0,
      0,   85,   85,   85
  };
  private static final int YY2TBLSTATE = 86;

  private static final short yydefault[] = {
      2,32767,32767,32767,32767,32767,32767,32767,32767,32767,
  32767,32767,   67,   42,   43,   44,   45,   46,   47,   48,
     49,   41,   66,   40,   36,   29,   30,   32,   34,   35,
     31,   33,   68,   68,   68,32767,32767,32767,32767,32767,
  32767,32767,32767,32767,32767,32767,32767,32767,32767,32767,
  32767,32767,32767,32767,32767,32767,32767,32767,32767,32767,
  32767,32767,32767,32767,32767,32767,32767,32767,32767,32767,
  32767,32767,32767,   50,   39,   38,   28,   23,   24,   20,
  32767,   20,   20,32767,32767,32767,32767,32767,32767,32767,
  32767,32767,   58,32767,32767,32767,32767,32767,32767,32767,
  32767,32767,32767,32767,32767,32767,32767,32767,32767,32767,
  32767,   54,32767,32767,32767,32767,32767,    2
  };

  private static final short yygoto[] = {
      1,    1,   79,  123,  122,   81,   82,   74,   75,   72,
     84,   85,  135,  136,   11,    0,    0,    0,    0,    0,
      0,    0,    0,    0,    0,  155,    2,    3,    4,   13,
     14,   15,   16,   17,   76,   18,   25,   26,   27,   28,
     29,   24,   19,   20,   21,    5,   30,   31,   77,   78,
    143,  144,  145,    6,   22,    7,   23,    8,    9
  };
  private static final int YYGLAST = 59;

  private static final byte yygcheck[] = {
      1,    1,    8,    8,    8,    8,    8,    2,    2,    2,
      5,    5,    9,    9,    6,   -1,   -1,   -1,   -1,   -1,
     -1,   -1,   -1,   -1,   -1,    1,    1,    1,    1,    1,
      1,    1,    1,    1,    1,    1,    1,    1,    1,    1,
      1,    1,    1,    1,    1,    1,    1,    1,    1,    1,
      1,    1,    1,    1,    1,    1,    1,    1,    1
  };

  private static final short yygbase[] = {
      0,  -10,  -62,    0,    0,  -23, -103,    0,  -85,  -69,
      0
  };

  private static final short yygdefault[] = {
  -32768,   12,   73,  110,  174,   83,   10,  119,  137,  124,
     65
  };

  private static final byte yylhs[] = {
      0,    6,    6,    7,    7,    7,    7,    7,    7,    7,
      7,    7,    7,    7,    7,    7,    8,    9,    9,    9,
      9,   10,   10,    1,    1,    1,    1,    1,    1,    1,
      1,    1,    1,    1,    1,    1,    1,    1,    1,    1,
      1,    1,    1,    1,    1,    1,    1,    1,    1,    1,
      1,    2,    2,    2,    2,    2,    2,    2,    4,    4,
      4,    4,    4,    4,    4,    3,    5,    5,    5
  };

  private static final byte yylen[] = {
      1,    2,    0,    5,    7,    5,    6,    2,    2,    2,
      2,    2,    2,    5,    5,    2,    3,    6,    7,    2,
      0,    1,    1,    3,    3,    3,    3,    3,    3,    3,
      3,    3,    3,    3,    3,    3,    3,    2,    2,    2,
      5,    3,    3,    3,    3,    3,    3,    3,    3,    3,
      1,    4,    4,    6,    3,    4,    1,    3,    1,    1,
      1,    1,    1,    1,    1,    1,    3,    1,    0
  };
  private static final int YYSTATES = 155;
  private static final int YYNLSTATES = 118;
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
{ yyval = _f.createPrintStatement(((Parser.Info)yyastk[yysp-(5-1)]), ((List)yyastk[yysp-(5-3)])); } break;
          case 4:
{ yyval = _f.createForeachStatement(((Parser.Info)yyastk[yysp-(7-1)]), ((Ast.Expression)yyastk[yysp-(7-3)]), ((Ast.Expression)yyastk[yysp-(7-5)]), ((Ast.Statement)yyastk[yysp-(7-7)])); } break;
          case 5:
{ yyval = _f.createWhileStatement(((Parser.Info)yyastk[yysp-(5-1)]), ((Ast.Expression)yyastk[yysp-(5-3)]), ((Ast.Statement)yyastk[yysp-(5-5)])); } break;
          case 6:
{ yyval = _f.createIfStatement(((Parser.Info)yyastk[yysp-(6-1)]), ((Ast.Expression)yyastk[yysp-(6-3)]), ((Ast.Statement)yyastk[yysp-(6-5)]), ((Ast.Statement)yyastk[yysp-(6-6)])); } break;
          case 7:
{ yyval = _f.createBreakStatement(((Parser.Info)yyastk[yysp-(2-1)])); } break;
          case 8:
{ yyval = _f.createContinueStatement(((Parser.Info)yyastk[yysp-(2-1)])); } break;
          case 9:
{ yyval = _f.createStagStatement(((Parser.Info)yyastk[yysp-(2-1)])); } break;
          case 10:
{ yyval = _f.createContStatement(((Parser.Info)yyastk[yysp-(2-1)])); } break;
          case 11:
{ yyval = _f.createEtagStatement(((Parser.Info)yyastk[yysp-(2-1)])); } break;
          case 12:
{ yyval = _f.createElemStatement(((Parser.Info)yyastk[yysp-(2-1)])); } break;
          case 13:
{ yyval = _f.createElementStatement(((Parser.Info)yyastk[yysp-(5-1)]), ((Parser.Info)yyastk[yysp-(5-3)])); } break;
          case 14:
{ yyval = _f.createContentStatement(((Parser.Info)yyastk[yysp-(5-1)]), ((Parser.Info)yyastk[yysp-(5-3)])); } break;
          case 15:
{ yyval = _f.createExpressionStatement(((Parser.Info)yyastk[yysp-(2-2)]), ((Ast.Expression)yyastk[yysp-(2-1)])); } break;
          case 16:
{ yyval = _f.createBlockStatement(((Parser.Info)yyastk[yysp-(3-1)]), ((List)yyastk[yysp-(3-2)])); } break;
          case 17:
{ yyval = _f.createIfStatement(((Parser.Info)yyastk[yysp-(6-1)]), ((Ast.Expression)yyastk[yysp-(6-3)]), ((Ast.Statement)yyastk[yysp-(6-5)]), ((Ast.Statement)yyastk[yysp-(6-6)])); } break;
          case 18:
{ yyval = _f.createIfStatement(((Parser.Info)yyastk[yysp-(7-2)]), ((Ast.Expression)yyastk[yysp-(7-4)]), ((Ast.Statement)yyastk[yysp-(7-6)]), ((Ast.Statement)yyastk[yysp-(7-7)])); } break;
          case 19:
{ yyval = ((Ast.Statement)yyastk[yysp-(2-2)]); } break;
          case 20:
{ yyval = null; } break;
          case 22:
{
	        if (! ((Parser.Info)yyastk[yysp-(1-1)]).getValue().equals("in")) {
	              throw new SyntaxException("syntax error", ((Parser.Info)yyastk[yysp-(1-1)]).getLinenum(), ((Parser.Info)yyastk[yysp-(1-1)]).getColumn());
		}
          } break;
          case 23:
{ yyval = _f.createArithmeticExpression(((Parser.Info)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 24:
{ yyval = _f.createArithmeticExpression(((Parser.Info)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 25:
{ yyval = _f.createArithmeticExpression(((Parser.Info)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 26:
{ yyval = _f.createArithmeticExpression(((Parser.Info)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 27:
{ yyval = _f.createArithmeticExpression(((Parser.Info)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 28:
{ yyval = _f.createArithmeticExpression(((Parser.Info)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 29:
{ yyval = _f.createRelationalExpression(((Parser.Info)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 30:
{ yyval = _f.createRelationalExpression(((Parser.Info)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 31:
{ yyval = _f.createRelationalExpression(((Parser.Info)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 32:
{ yyval = _f.createRelationalExpression(((Parser.Info)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 33:
{ yyval = _f.createRelationalExpression(((Parser.Info)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 34:
{ yyval = _f.createRelationalExpression(((Parser.Info)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 35:
{ yyval = _f.createLogicalExpression(((Parser.Info)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 36:
{ yyval = _f.createLogicalExpression(((Parser.Info)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 37:
{ yyval = _f.createLogicalExpression(((Parser.Info)yyastk[yysp-(2-1)]), ((Ast.Expression)yyastk[yysp-(2-2)]), null); } break;
          case 38:
{ yyval = _f.createUnaryExpression(((Parser.Info)yyastk[yysp-(2-1)]), ((Ast.Expression)yyastk[yysp-(2-2)])); } break;
          case 39:
{ yyval = _f.createUnaryExpression(((Parser.Info)yyastk[yysp-(2-1)]), ((Ast.Expression)yyastk[yysp-(2-2)])); } break;
          case 40:
{ yyval = _f.createConditionalExpression(((Parser.Info)yyastk[yysp-(5-2)]), ((Ast.Expression)yyastk[yysp-(5-1)]), ((Ast.Expression)yyastk[yysp-(5-3)]), ((Ast.Expression)yyastk[yysp-(5-5)])); } break;
          case 41:
{ yyval = _f.createAssignmentExpression(((Parser.Info)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 42:
{ yyval = _f.createAssignmentExpression(((Parser.Info)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 43:
{ yyval = _f.createAssignmentExpression(((Parser.Info)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 44:
{ yyval = _f.createAssignmentExpression(((Parser.Info)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 45:
{ yyval = _f.createAssignmentExpression(((Parser.Info)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 46:
{ yyval = _f.createAssignmentExpression(((Parser.Info)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 47:
{ yyval = _f.createAssignmentExpression(((Parser.Info)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 48:
{ yyval = _f.createAssignmentExpression(((Parser.Info)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 49:
{ yyval = _f.createAssignmentExpression(((Parser.Info)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 50:
{ yyval = ((Ast.Expression)yyastk[yysp-(1-1)]); } break;
          case 51:
{ yyval = _f.createIndexExpression(((Parser.Info)yyastk[yysp-(4-2)]), ((Ast.Expression)yyastk[yysp-(4-1)]), ((Ast.Expression)yyastk[yysp-(4-3)])); } break;
          case 52:
{ yyval = _f.createIndex2Expression(((Parser.Info)yyastk[yysp-(4-2)]), ((Ast.Expression)yyastk[yysp-(4-1)]), ((Ast.Literal)yyastk[yysp-(4-3)])); } break;
          case 53:
{ yyval = _f.createMethodExpression(((Parser.Info)yyastk[yysp-(6-2)]), ((Ast.Expression)yyastk[yysp-(6-1)]), (((Parser.Info)yyastk[yysp-(6-3)])).getValue(), ((List)yyastk[yysp-(6-5)])); } break;
          case 54:
{ yyval = _f.createPropertyExpression(((Parser.Info)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), (((Parser.Info)yyastk[yysp-(3-3)])).getValue()); } break;
          case 55:
{ yyval = _f.createFuncallExpression(((Parser.Info)yyastk[yysp-(4-1)]), ((List)yyastk[yysp-(4-3)])); } break;
          case 56:
{ yyval = ((Ast.Literal)yyastk[yysp-(1-1)]); } break;
          case 57:
{ yyval = ((Ast.Expression)yyastk[yysp-(3-2)]); } break;
          case 58:
{ yyval = _f.createVariableLiteral(((Parser.Info)yyastk[yysp-(1-1)])); } break;
          case 59:
{ yyval = _f.createStringLiteral(((Parser.Info)yyastk[yysp-(1-1)])); } break;
          case 60:
{ yyval = _f.createIntegerLiteral(((Parser.Info)yyastk[yysp-(1-1)])); } break;
          case 61:
{ yyval = _f.createFloatLiteral(((Parser.Info)yyastk[yysp-(1-1)])); } break;
          case 62:
{ yyval = _f.createTrueLiteral(((Parser.Info)yyastk[yysp-(1-1)])); } break;
          case 63:
{ yyval = _f.createFalseLiteral(((Parser.Info)yyastk[yysp-(1-1)])); } break;
          case 64:
{ yyval = _f.createNullLiteral(((Parser.Info)yyastk[yysp-(1-1)])); } break;
          case 65:
{ yyval = _f.createStringLiteral(((Parser.Info)yyastk[yysp-(1-1)])); } break;
          case 66:
{ ((List)yyastk[yysp-(3-1)]).add(((Ast.Expression)yyastk[yysp-(3-3)])); yyval = ((List)yyastk[yysp-(3-1)]); } break;
          case 67:
{ List l = new ArrayList(); l.add(((Ast.Expression)yyastk[yysp-(1-1)])); yyval = l; } break;
          case 68:
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




