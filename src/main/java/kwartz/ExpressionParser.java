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


public class ExpressionParser extends Parser {


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
      0,   42,   42,   42,   42,   42,   42,   42,   42,   42,
     42,   42,   42,   42,   42,   42,   42,   42,   42,   42,
     42,   42,   42,   42,   42,   42,   42,   42,   42,   42,
     42,   42,   42,   35,   42,   42,   42,   34,   42,   42,
     39,   40,   32,   30,   41,   31,   36,   33,   42,   42,
     42,   42,   42,   42,   42,   42,   42,   42,   27,   42,
     29,   25,   28,   26,   42,   42,   42,   42,   42,   42,
     42,   42,   42,   42,   42,   42,   42,   42,   42,   42,
     42,   42,   42,   42,   42,   42,   42,   42,   42,   42,
     42,   37,   42,   38,   42,   42,   42,   42,   42,   42,
     42,   42,   42,   42,   42,   42,   42,   42,   42,   42,
     42,   42,   42,   42,   42,   42,   42,   42,   42,   42,
     42,   42,   42,   42,   42,   42,   42,   42,   42,   42,
     42,   42,   42,   42,   42,   42,   42,   42,   42,   42,
     42,   42,   42,   42,   42,   42,   42,   42,   42,   42,
     42,   42,   42,   42,   42,   42,   42,   42,   42,   42,
     42,   42,   42,   42,   42,   42,   42,   42,   42,   42,
     42,   42,   42,   42,   42,   42,   42,   42,   42,   42,
     42,   42,   42,   42,   42,   42,   42,   42,   42,   42,
     42,   42,   42,   42,   42,   42,   42,   42,   42,   42,
     42,   42,   42,   42,   42,   42,   42,   42,   42,   42,
     42,   42,   42,   42,   42,   42,   42,   42,   42,   42,
     42,   42,   42,   42,   42,   42,   42,   42,   42,   42,
     42,   42,   42,   42,   42,   42,   42,   42,   42,   42,
     42,   42,   42,   42,   42,   42,   42,   42,   42,   42,
     42,   42,   42,   42,   42,   42,    1,    2,   42,    3,
      4,    5,    6,    7,    8,    9,   10,   11,   12,   13,
     14,   15,   16,   17,   42,   18,   42,   19,   20,   21,
     22,   23,   42,   42,   42,   42,   24,   42,   42,   42,
     42,   42,   42,   42,   42,   42,   42,   42,   42,   42,
     42,   42,   42,   42,   42,   42,   42,   42,   42,   42,
     42,   42,   42,   42,   42,   42,   42,   42,   42,   42,
     42,   42,   42,   42,   42,   42,   42,   42
  };
  private static final int YYBADCH = 42;
  private static final int YYMAXLEX = 328;
  private static final int YYTERMS = 42;
  private static final int YYNONTERMS = 6;

  private static final short yyaction[] = {
     29,   30,   31,   32,   33,   34,   35,   36,   37,   38,
     39,   40,   41,   42,   43,    0,   44,   45,   70,   46,
     47,   48,   49,   50,   51,   52,-32766,-32766,-32766,-32766,
  -32766,  114,-32766,   50,   51,   52,   55,-32766,-32766,-32766,
  -32766,  100,-32766,-32766,-32766,-32766,-32766,-32766,-32766,  101,
  -32766,   25,   26,    0,   56,   57,-32766,-32766,-32766,   27,
  -32766,-32766,   34,  104,-32767,-32767,-32767,-32767,-32766,-32766,
  -32766,-32766,-32766,  102,-32766,   54,-32767,-32767,   48,   49,
     66,-32766,-32766,  106,-32766,   67,  109,  110,  108,  111,
    112,  113,   68,   53,    0,    0,    0,    0,    0,    0,
      0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
      0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
      0,    0,   28
  };
  private static final int YYLAST = 123;

  private static final byte yycheck[] = {
      9,   10,   11,   12,   13,   14,   15,   16,   17,   18,
     19,   20,   21,   22,   23,    0,   25,   26,    2,   28,
     29,   30,   31,   32,   33,   34,    9,   10,   11,   12,
     13,    2,   15,   32,   33,   34,   27,   20,   21,   22,
     23,   38,   25,   26,    9,   10,   11,   12,   13,   38,
     15,   39,   39,   -1,   30,   31,   21,   22,   23,   35,
     25,   26,   14,   40,   16,   17,   18,   19,    9,   10,
     11,   12,   13,   40,   15,   41,   28,   29,   30,   31,
     24,   22,   23,   40,   25,    2,    3,    4,    5,    6,
      7,    8,   36,   37,   -1,   -1,   -1,   -1,   -1,   -1,
     -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
     -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
     -1,   -1,   39
  };

  private static final short yybase[] = {
     24,   15,   43,    9,    3,   -9,   -9,   -9,   -9,   -9,
     -9,   -9,   -9,   -9,   -9,   -9,   59,   35,   48,   48,
     48,   48,   17,   48,   48,   24,   24,   24,   24,   24,
     24,   24,   24,   24,   24,   24,   24,   24,   24,   24,
     24,   24,   24,   24,   24,   24,   24,   24,   24,   24,
     24,   24,   24,   24,   24,   24,   83,   83,   56,   56,
     56,    1,    1,    1,   23,   33,   29,   12,   16,   11,
     13,   83,   -9,   -9,   -9,   -9,    0,    0,    0,    0,
      0,    0,    0,    0,    0,    0,    0,   -9,   -9,    1,
      1,    1,    1,   -9,    1,    1,   83,   83,   83,   83,
     83,   83,   83,   83,   83,   83,   83,   83,   83,   83,
     83,   83,   83,   83,   83,   83,   83,   83,   83,   83,
     83,   83,   83,   83,   83,   83,   83,    0,    0,    0,
      0,    0,    0,    0,    0,   34,   34
  };
  private static final int YY2TBLSTATE = 66;

  private static final short yydefault[] = {
  32767,32767,32767,32767,32767,   45,   20,   21,   22,   23,
     24,   25,   26,   27,   19,   44,   18,   14,    7,    8,
     10,   12,   13,    9,   11,   46,   46,32767,32767,32767,
  32767,32767,32767,32767,32767,32767,32767,32767,32767,32767,
  32767,32767,32767,32767,32767,32767,32767,32767,32767,32767,
  32767,32767,32767,32767,32767,32767,32767,32767,   28,   17,
     16,    6,    1,    2,32767,32767,32767,   36,32767,32767,
     32
  };

  private static final short yygoto[] = {
     65,    1,   59,   60,    0,    0,    0,    0,    0,    0,
      0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
      0,    0,    0,    0,    0,    0,    0,    0,   86,    2,
      6,    7,    8,    9,   10,   61,   11,   18,   19,   20,
     21,   22,   17,   12,   13,   14,    3,   23,   24,   62,
     63,   74,   75,   76,    4,   15,   16
  };
  private static final int YYGLAST = 57;

  private static final byte yygcheck[] = {
      5,    1,    2,    2,   -1,   -1,   -1,   -1,   -1,   -1,
     -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
     -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,    1,    1,
      1,    1,    1,    1,    1,    1,    1,    1,    1,    1,
      1,    1,    1,    1,    1,    1,    1,    1,    1,    1,
      1,    1,    1,    1,    1,    1,    1
  };

  private static final short yygbase[] = {
      0,    1,  -54,    0,    0,  -26
  };

  private static final short yygdefault[] = {
  -32768,    5,   58,   69,  105,   64
  };

  private static final byte yylhs[] = {
      0,    1,    1,    1,    1,    1,    1,    1,    1,    1,
      1,    1,    1,    1,    1,    1,    1,    1,    1,    1,
      1,    1,    1,    1,    1,    1,    1,    1,    1,    2,
      2,    2,    2,    2,    2,    2,    4,    4,    4,    4,
      4,    4,    4,    3,    5,    5,    5
  };

  private static final byte yylen[] = {
      1,    3,    3,    3,    3,    3,    3,    3,    3,    3,
      3,    3,    3,    3,    3,    2,    2,    2,    5,    3,
      3,    3,    3,    3,    3,    3,    3,    3,    1,    4,
      4,    6,    3,    4,    1,    3,    1,    1,    1,    1,
      1,    1,    1,    1,    3,    1,    0
  };
  private static final int YYSTATES = 88;
  private static final int YYNLSTATES = 71;
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
{ yyval = _f.createArithmeticExpression(((ParseInfo)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 2:
{ yyval = _f.createArithmeticExpression(((ParseInfo)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 3:
{ yyval = _f.createArithmeticExpression(((ParseInfo)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 4:
{ yyval = _f.createArithmeticExpression(((ParseInfo)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 5:
{ yyval = _f.createArithmeticExpression(((ParseInfo)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 6:
{ yyval = _f.createArithmeticExpression(((ParseInfo)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 7:
{ yyval = _f.createRelationalExpression(((ParseInfo)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 8:
{ yyval = _f.createRelationalExpression(((ParseInfo)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 9:
{ yyval = _f.createRelationalExpression(((ParseInfo)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 10:
{ yyval = _f.createRelationalExpression(((ParseInfo)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 11:
{ yyval = _f.createRelationalExpression(((ParseInfo)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 12:
{ yyval = _f.createRelationalExpression(((ParseInfo)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 13:
{ yyval = _f.createLogicalExpression(((ParseInfo)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 14:
{ yyval = _f.createLogicalExpression(((ParseInfo)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 15:
{ yyval = _f.createLogicalExpression(((ParseInfo)yyastk[yysp-(2-1)]), ((Ast.Expression)yyastk[yysp-(2-2)]), null); } break;
          case 16:
{ yyval = _f.createUnaryExpression(((ParseInfo)yyastk[yysp-(2-1)]), ((Ast.Expression)yyastk[yysp-(2-2)])); } break;
          case 17:
{ yyval = _f.createUnaryExpression(((ParseInfo)yyastk[yysp-(2-1)]), ((Ast.Expression)yyastk[yysp-(2-2)])); } break;
          case 18:
{ yyval = _f.createConditionalExpression(((ParseInfo)yyastk[yysp-(5-2)]), ((Ast.Expression)yyastk[yysp-(5-1)]), ((Ast.Expression)yyastk[yysp-(5-3)]), ((Ast.Expression)yyastk[yysp-(5-5)])); } break;
          case 19:
{ yyval = _f.createAssignmentExpression(((ParseInfo)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 20:
{ yyval = _f.createAssignmentExpression(((ParseInfo)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 21:
{ yyval = _f.createAssignmentExpression(((ParseInfo)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 22:
{ yyval = _f.createAssignmentExpression(((ParseInfo)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 23:
{ yyval = _f.createAssignmentExpression(((ParseInfo)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 24:
{ yyval = _f.createAssignmentExpression(((ParseInfo)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 25:
{ yyval = _f.createAssignmentExpression(((ParseInfo)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 26:
{ yyval = _f.createAssignmentExpression(((ParseInfo)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 27:
{ yyval = _f.createAssignmentExpression(((ParseInfo)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), ((Ast.Expression)yyastk[yysp-(3-3)])); } break;
          case 28:
{ yyval = ((Ast.Expression)yyastk[yysp-(1-1)]); } break;
          case 29:
{ yyval = _f.createIndexExpression(((ParseInfo)yyastk[yysp-(4-2)]), ((Ast.Expression)yyastk[yysp-(4-1)]), ((Ast.Expression)yyastk[yysp-(4-3)])); } break;
          case 30:
{ yyval = _f.createIndex2Expression(((ParseInfo)yyastk[yysp-(4-2)]), ((Ast.Expression)yyastk[yysp-(4-1)]), ((Ast.Literal)yyastk[yysp-(4-3)])); } break;
          case 31:
{ yyval = _f.createMethodExpression(((ParseInfo)yyastk[yysp-(6-2)]), ((Ast.Expression)yyastk[yysp-(6-1)]), (((ParseInfo)yyastk[yysp-(6-3)])).getValue(), ((List)yyastk[yysp-(6-5)])); } break;
          case 32:
{ yyval = _f.createPropertyExpression(((ParseInfo)yyastk[yysp-(3-2)]), ((Ast.Expression)yyastk[yysp-(3-1)]), (((ParseInfo)yyastk[yysp-(3-3)])).getValue()); } break;
          case 33:
{ yyval = _f.createFuncallExpression(((ParseInfo)yyastk[yysp-(4-1)]), ((List)yyastk[yysp-(4-3)])); } break;
          case 34:
{ yyval = ((Ast.Literal)yyastk[yysp-(1-1)]); } break;
          case 35:
{ yyval = ((Ast.Expression)yyastk[yysp-(3-2)]); } break;
          case 36:
{ yyval = _f.createVariableLiteral(((ParseInfo)yyastk[yysp-(1-1)])); } break;
          case 37:
{ yyval = _f.createStringLiteral(((ParseInfo)yyastk[yysp-(1-1)])); } break;
          case 38:
{ yyval = _f.createIntegerLiteral(((ParseInfo)yyastk[yysp-(1-1)])); } break;
          case 39:
{ yyval = _f.createFloatLiteral(((ParseInfo)yyastk[yysp-(1-1)])); } break;
          case 40:
{ yyval = _f.createTrueLiteral(((ParseInfo)yyastk[yysp-(1-1)])); } break;
          case 41:
{ yyval = _f.createFalseLiteral(((ParseInfo)yyastk[yysp-(1-1)])); } break;
          case 42:
{ yyval = _f.createNullLiteral(((ParseInfo)yyastk[yysp-(1-1)])); } break;
          case 43:
{ yyval = _f.createStringLiteral(((ParseInfo)yyastk[yysp-(1-1)])); } break;
          case 44:
{ ((List)yyastk[yysp-(3-1)]).add(((Ast.Expression)yyastk[yysp-(3-3)])); yyval = ((List)yyastk[yysp-(3-1)]); } break;
          case 45:
{ List l = new ArrayList(); l.add(((Ast.Expression)yyastk[yysp-(1-1)])); yyval = l; } break;
          case 46:
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




