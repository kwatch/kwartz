/**
 *  @(#) CharacterUtil.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz;

public class CharacterUtil {

    public static boolean isWhitespace(char ch) {
        return Character.isWhitespace(ch);
    }

    public static boolean isAlphabet(char ch) {
        //return Character.isLetter(ch);
        return ('a' <= ch && ch <= 'z') || ('A' <= ch && ch <= 'Z');
    }

    public static boolean isDigit(char ch) {
        return Character.isDigit(ch);
    }

    public static boolean isWordLetter(char ch) {
        return isAlphabet(ch) || isDigit(ch) || ch == '_';
    }

}
