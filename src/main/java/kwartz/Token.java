/*
 * $Rev$
 * $Release$
 * $Copyright$
 */


/* Here goes %{ ... %} */

package kwartz;


public interface Token {

  public static final int YYERRTOK = 256;
  public static final int IDENT = 257;
  public static final int VARIABLE = 258;
  public static final int INTEGER = 259;
  public static final int FLOAT = 260;
  public static final int STRING = 261;
  public static final int TRUE = 262;
  public static final int FALSE = 263;
  public static final int NULL = 264;
  public static final int PLUS_EQ = 265;
  public static final int MINUS_EQ = 266;
  public static final int STAR_EQ = 267;
  public static final int SLASH_EQ = 268;
  public static final int PERCENT_EQ = 269;
  public static final int CONCAT = 270;
  public static final int CONCAT_EQ = 271;
  public static final int EQ = 272;
  public static final int NE = 273;
  public static final int GT = 274;
  public static final int GE = 275;
  public static final int LT = 276;
  public static final int LE = 277;
  public static final int AND = 278;
  public static final int OR = 279;
  public static final int AND_EQ = 280;
  public static final int OR_EQ = 281;
  public static final int FUNCALL = 282;
  public static final int METHOD = 283;
  public static final int PROPERTY = 284;
  public static final int INDEX = 285;
  public static final int INDEX2 = 286;
  public static final int UPLUS = 287;
  public static final int UMINUS = 288;
  public static final int CONDITIONAL = 289;
  public static final int PRINT = 290;
  public static final int EXPR = 291;
  public static final int IF = 292;
  public static final int ELSEIF = 293;
  public static final int ELSE = 294;
  public static final int WHILE = 295;
  public static final int FOREACH = 296;
  public static final int BREAK = 297;
  public static final int CONTINUE = 298;
  public static final int BLOCK = 299;
  public static final int NATIVE_STMT = 300;
  public static final int NATIVE_EXPR = 301;
  public static final int STAG = 302;
  public static final int CONT = 303;
  public static final int ETAG = 304;
  public static final int ELEM = 305;
  public static final int ELEMENT = 306;
  public static final int CONTENT = 307;
  public static final int COMMAND = 308;
  public static final int SELECTOR = 309;
  public static final int DECLARATION = 310;
  public static final int RULESET = 311;
  public static final int P_STAG = 312;
  public static final int P_CONT = 313;
  public static final int P_ETAG = 314;
  public static final int P_ELEM = 315;
  public static final int P_VALUE = 316;
  public static final int P_ATTRS = 317;
  public static final int P_APPEND = 318;
  public static final int P_REMOVE = 319;
  public static final int P_TAGNAME = 320;
  public static final int P_LOGIC = 321;
  public static final int P_BEGIN = 322;
  public static final int P_END = 323;
  public static final int P_BEFORE = 324;
  public static final int P_AFTER = 325;
  public static final int P_GLOBAL = 326;
  public static final int ERROR = 327;


}

