/**
 *  @(#) KwartzTest.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz;
import junit.framework.TestCase;
import junit.framework.TestSuite;

public class KwartzTest extends TestCase {
    public static void main(String[] args) {
        TestSuite suite = new TestSuite();
        suite.addTest(new TestSuite(ExpressionTest.class));
        suite.addTest(new TestSuite(StatementTest.class));
        suite.addTest(new TestSuite(ScannerTest.class));
        suite.addTest(new TestSuite(ExpressionParserTest.class));
        suite.addTest(new TestSuite(StatementParserTest.class));
        suite.addTest(new TestSuite(InterpreterTest.class));
        suite.addTest(new TestSuite(ConverterTest.class));
        suite.addTest(new TestSuite(TagHelperTest.class));
        suite.addTest(new TestSuite(DeclarationParserTest.class));
        suite.addTest(new TestSuite(ExpanderTest.class));
        suite.addTest(new TestSuite(CompilerTest.class));
        suite.addTest(new TestSuite(OptimizerTest.class));
        suite.addTest(new TestSuite(FunctionTest.class));
        suite.addTest(new TestSuite(KwartzClassTest.class));
        junit.textui.TestRunner.run(suite);
    }
}
