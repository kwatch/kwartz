/**
 *  @(#) Attr.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz;

class Attr {
    String space;
    String name;
    Object value;        // Expression or String

    Attr(String space, String name, Object value) {
        this.space = space;
        this.name  = name;
        this.value = value;
    }

    /*
    String space() { return space; }
    String name()  { return name;  }
    Object value() { return value; }
     */
}
