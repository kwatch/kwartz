###
### copyright(c) 2005 kuwata-lab all rights reserved
###
### $Id$
###

require 'kwartz/exception'
require 'kwartz/scanner'
require 'kwartz/node'
require 'kwartz/element'

module Kwartz

   class ParseError < BaseError
      def initialize(message, linenum, filename)
         super(message, linenum, filename)
      end
   end

   class SyntaxError < ParseError
      def initialize(message, linenum, filename)
         super(message, linenum, filename)
      end
   end

   class SemanticError < ParseError
      def initialize(message, linenum, filename)
         super(message, linenum, filename)
      end
   end


   class Parser

      def initialize(input, properties={})
         @scanner = Scanner.new(input, properties)
         @properties = properties
         _init()
      end
      attr_reader :properties

      def reset(input, linenum=nil)
         @scanner.reset(input, linenum)
         _init()
      end

      def _init()
         @scanner.scan()
         @element_name_stack = []
         @current_element_name = nil
      end
      private :_init

      def scan()
         return @scanner.scan()
      end

      def token()
         return @scanner.token()
      end

      def token_str()
         return @scanner.value()
      end

      def value()
         return @scanner.value()
      end

      def syntax_error(msg)
         raise SyntaxError.new(msg, @scanner.linenum, @scanner.filename)
      end

      def semantic_error(msg)
         raise SemanticError.new(msg, @scanner.linenum, @scanner.filename)
      end


      ###
      ### expression
      ###

      ##
      ## BNF:
      ##  arguments    ::=  expression | arguments ',' expression | e
      ##               ::=  [ expression { ',' expression } ]
      ##
      def parse_arguments
         arguments = []
         return arguments if token() == ')'
         expr = parse_expression()
         arguments << expr
         while token() == ','
            scan()
            expr = parse_expression()
            arguments << expr
         end
         return arguments
      end


      ##
      ## BNF:
      ##  item         ::=  variable | function '(' arguments ')' | '(' expression ')'
      ##
      def parse_item_expr
         tkn = token()
         if tkn == :name
            name = value()
            tkn = scan()
            if tkn != '('
               return VariableExpression.new(name)
            end
            scan()
            arguments = parse_arguments()
            syntax_error("missing ')' of function '#{name}()'.") unless token() == ')'
            scan()
            if ! (name == 'C' || name == 'S' || name == 'D')
               return FunctionExpression.new(name, arguments)
            end
            semantic_error("#{name}(): should take only one argument.") unless arguments.length == 1
            condition = arguments.first
            case name
            when 'C';  s = ' checked="checked"'
            when 'S';  s = ' selected="selected"'
            when 'D';  s = ' disabled="disabled"'
            end
            return ConditionalExpression.new(condition, StringExpression.new(s), StringExpression.new(''))
         elsif tkn == '('
            scan()
            expr = parse_expression()
            syntax_error("')' expected ('(' is not closed by ')').") unless token() == ')'
            scan()
            return expr
         else
            Kwartz::assert("tkn == #{tkn}")
         end
      end


      ##
      ## BNF:
      ##  literal      ::=  numeric | string | 'true' | 'false' | 'null' | 'empty'
      ##
      def parse_literal_expr
         tkn = token()
         case tkn
         when :numeric
            val = value()
            scan()
            return NumericExpression.new(val)
         when :string
            str = value()
            scan()
            return StringExpression.new(str)
         when :true, :false
            val = value()
            scan()
            return BooleanExpression.new(tkn == :true)
         when :null
            val = value()
            scan()
            return NullExpression.new()
         when :empty
            syntax_error("'empty' is allowed only in right-side of '==' or '!='.")
         end
         Kwartz::assert("tkn = #{token}")
      end


      ##
      ## BNF:
      ##  factor       ::=  literal | item | item '[' expression ']' | item '[:' name ']' | item '.' property | item '.' method '(' [ arguments ] ')'
      ##
      def parse_factor_expr
         tkn = token()
         case tkn
         when :name, '('
            expr = parse_item_expr()
            if token() == '['
               scan()
               expr2 = parse_expression()
               syntax_error("']' expected ('[' is not closed by ']').") unless token() == ']'
               scan()
               return IndexExpression.new('[]', expr, expr2)
            elsif token() == '[:'
               scan()
               word = value()
               syntax_error("'#{tkn}': '[:' requires a word following.") unless token() == :name
               tkn = scan()
               syntax_error("'[:' is not closed by ']'.") unless tkn == ']'
               scan()
               return IndexExpression.new('[:]', expr, StringExpression.new(word))
            elsif token() == '.'
               scan()
               name = value()
               syntax_error("'#{tkn}': '.' requires a property or method name following.") unless token() == :name
               scan()
               if token() == '('
                  method_name = name
                  scan()
                  arguments = parse_arguments()
                  syntax_error("')' expected (method '#{method_name}()' is not closed by ')').") unless token() == ')'
                  scan()
                  return MethodExpression.new(expr, method_name, arguments)
               else
                  prop_name = name
                  return PropertyExpression.new(expr, prop_name)
               end
            else
               return expr
            end
         when :numeric, :string, :true, :false, :null, :empty
            expr = parse_literal_expr()
            return expr
         else
            syntax_error("'#{tkn}': unexpected token.")
         end
      end


      ##
      ## BNF:
      ##  unary        ::=  factor | '+' factor | '-' factor | '!' factor
      ##               ::=  [ '+' | '-' | '!' ] factor
      ##
      def parse_unary_expr
         if (tkn = token()) == '+' || tkn == '-' || tkn == '!'
            scan()
            expr2 = parse_factor_expr()
            op = tkn == '!' ? tkn : tkn + '.'
            expr = UnaryExpression.new(op, expr2)
         else
            expr = parse_factor_expr()
         end
         return expr
      end


      ##
      ## BNF:
      ##  term         ::=  unary | term * factor | term '/' factor | term '%' factor
      ##               ::=  unary { ('*' | '/' | '%') factor }
      ##
      def parse_term_expr
         expr = parse_unary_expr()
         while (tkn = token()) == '*' || tkn == '/' || tkn == '%'
            scan()
            expr2 = parse_factor_expr()
            expr = ArithmeticExpression.new(tkn, expr, expr2)
         end
         return expr
      end


      ##
      ## BNF:
      ##  arith        ::=  term | arith '+' term | arith '-' term | arith '.+' term
      ##               ::=  term { ('+' | '-' | '.+') term }
      ##
      def parse_arith_expr
         expr = parse_term_expr()
         while (tkn = token()) == '+' || tkn == '-' || tkn == '.+'
            scan()
            expr2 = parse_term_expr()
            expr = ArithmeticExpression.new(tkn, expr, expr2)
         end
         return expr
      end


      ##
      ## BNF:
      ##  relational-op   ::=  '==' |  '!=' |  '>' |  '>=' |  '<' |  '<='
      ##  relational      ::=  arith | arith relational-op arith | arith '==' 'empty' | arith '!=' 'empty'
      ##                  ::=  arith [ relational-op arith ] | arith ('==' | '!=') 'empty'
      ##
      def parse_relational_expr
         expr = parse_arith_expr()
         while (op = token()) == '==' || op == '!=' || op == '>' || op == '>=' || op == '<' || op == '<='
            scan()
            if token() == :empty
               if op == '=='
                  scan()
                  expr = EmptyExpression.new(:empty, expr)
               elsif op == '!='
                  scan()
                  expr = EmptyExpression.new(:notempty, expr)
               else
                  syntax_error("'empty' is allowed only at the right-side of '==' or '!='.")
               end
            else
               expr2 = parse_arith_expr()
               expr = RelationalExpression.new(op, expr, expr2)
            end
         end
         return expr
      end


      ##
      ## BNF:
      ##  logical-and  ::=  relational | logical-and '&&' relational
      ##               ::=  relational { '&&' relational }
      ##
      def parse_logical_and_expr
         expr = parse_relational_expr()
         while (op = token()) == '&&'
            scan()
            expr2 = parse_relational_expr()
            expr = LogicalExpression.new(op, expr, expr2)
         end
         return expr
      end


      ##
      ## BNF:
      ##  logical-or   ::=  logical-and | logical-or '||' logical-and
      ##               ::=  logical-and { '||' logical-and }
      ##
      def parse_logical_or_expr
         expr = parse_logical_and_expr()
         while (op = token()) == '||'
            scan()
            expr2 = parse_logical_and_expr()
            expr = LogicalExpression.new(op, expr, expr2)
         end
         return expr
      end


      ##
      ## BNF:
      ##  conditional  ::=  logical-or | logical-or '?' expression ':' conditional
      ##               ::=  logical-or [ '?' expression ':' conditional ]
      ##
      def parse_conditional_expr
         expr = parse_logical_or_expr()
         if token() == '?'
            scan()
            expr2 = parse_expression()
            syntax_error("':' expected ('?' requires ':').") unless token() == ':'
            scan()
            expr3 = parse_conditional_expr()
            expr = ConditionalExpression.new(expr, expr2, expr3)
         end
         return expr
      end


      ##
      ## BNF:
      ##  assign-op    ::=  '=' | '+=' | '-=' | '*=' | '/=' | '%=' | '.+='
      ##  assignment   ::=  conditional | assign-op assignment
      ##
      def parse_assignment_expr
         expr = parse_conditional_expr()
         op = token()
         if op == '=' || op == '+=' || op == '-=' || op == '*=' || op == '/=' || op == '%=' || op == '.+='
            unless lhs?(expr)
               semantic_error("invalid assignment.")
            end
            scan()
            expr2 = parse_assignment_expr()
            expr = AssignmentExpression.new(op, expr, expr2)
         end
         return expr
      end

      def lhs?(expr)
         case expr.token
         when :variable, '[]', '[:]'
            return true
         when '.'
            return expr.is_a?(PropertyExpression)
         else
            return false
         end
      end
      

      ##
      ## BNF:
      ##  expression   ::=  assignment
      ##
      def parse_expression
         return parse_assignment_expr()
      end


      ##
      ##  print-stmt   ::=  'print' '(' arguments ')' ';'
      ##  
      def parse_print_stmt()
         Kwartz::assert unless token() == :print
         tkn = scan()
         syntax_error("print-statement requires '('.") unless tkn == '('
         scan()
         arguments = parse_arguments()
         syntax_error("print-statement requires ')'.") unless token() == ')'
         tkn = scan()
         syntax_error("print-statement requires ';'.") unless tkn == ';'
         scan()
         return PrintStatement.new(arguments)
      end
      
      
      ##  
      ##  expr-stmt    ::=  expression ';'
      ##  
      def parse_expr_stmt()
         expr = parse_expression()
         syntax_error("expression-statement requires ';'.") unless token() == ';'
         scan()
         return ExprStatement.new(expr)
      end
      
      
      ##  
      ##  elseif-part  ::=  'elseif' '(' expression ')' statement elseif-part | e
      ##  
      ##  
      ##  if-stmt      ::=  'if' '(' expression ')' statement
      ##                  | 'if' '(' expression ')' statement elseif-part
      ##                  | 'if' '(' expression ')' statement elseif-part 'else' statement
      ##               ::=  'if' '(' expression ')' statement
      ##                    { 'elseif' '(' expression ')' statement }
      ##                    [ 'else' statement ]
      ##
      def parse_if_stmt()
         Kwartz::assert unless token() == :if || token() == :elseif
         tkn = scan()
         syntax_error("if-statement requires '('.") unless tkn == '('
         scan()
         cond_expr = parse_expression()
         syntax_error("if-statement requires ')'.") unless token() == ')'
         scan()
         then_body = parse_statement()
         if token() == :elseif
            scan()
            tkn = scan()
            syntax_error("elseif-statement requires ')'.") unless tkn == '('
            scan()
            else_body = parse_if_stmt()
         elsif token() == :else
            scan()
            else_body = parse_statement()
         else
            else_body = nil
         end
         return IfStatement.new(cond_expr, then_body, else_body)
      end

      
      ##
      ##  foreach-stmt ::=  'foreach' '(' variable 'in' expression ')' statement
      ##  
      def parse_foreach_stmt()
         Kwartz::assert unless token() == :foreach
         tkn = scan()
         syntax_error("foreach-statement requires '('.") unless tkn == '('
         scan()
         loopvar_expr = parse_expression()
         unless loopvar_expr.token() == :variable
            raise syntax_error("foreach-statement requires loop-variable but got '#{tkn}'.")
         end
         syntax_error("foreach-statement requires 'in' but got '#{tkn}'.") unless token() == :in
         scan()
         list_expr = parse_expression()
         syntax_error("foreach-statement requires ')'.") unless token() == ')'
         scan()
         body_stmt = parse_statement()
         return ForeachStatement.new(loopvar_expr, list_expr, body_stmt)
      end
      
      
      ##  
      ##  while-stmt   ::=  'while' '(' expression ')' statement
      ##
      def parse_while_stmt()
         Kwartz::assert unless token() == :while
         tkn = scan()
         syntax_error("while-statement requires '('") unless tkn == '('
         scan()
         cond_expr = parse_expression()
         syntax_error("while-statement requires ')'") unless token() == ')'
         scan()
         body_stmt = parse_statement()
         return WhileStatement.new(cond_expr, body_stmt)
      end
      

      ##
      ##  @stag,  @cont,  @etag,  @element(name)
      ##
      def parse_expand_stmt()
         Kwartz::assert unless token() == '@'
         type = value()
         stmt = nil
         case type
         when 'stag', 'cont', 'etag'
            name = nil
         when 'element'
            tkn = scan()
            syntax_error("@element() requires '('.") unless tkn == '('
            tkn = scan()
            syntax_error("@element() requires an element name.") unless tkn == :name
            name = value()
            tkn = scan()
            syntax_error("@element() requires ')'.") unless tkn == ')'
         else
            syntax_error("'@' should be '@stag', '@cont', '@etag', or '@element(name)'.")
         end
         tkn = scan()
         syntax_error("@#{type} requires ';'.") unless tkn == ';'
         scan()
         return ExpandStatement.new(type.intern, name)
      end

      
      ##  
      ##
      def parse_stmt_list()
         list = []
         while stmt = parse_statement()
            list << stmt unless stmt == ';'
         end
         return list
      end
      
      
      ##  
      ##  stmt-list    ::=  statement | stmt-list statement
      ##               ::=  statement { statement }
      ##  block-stmt   ::=  '{' '}' | '{' stmt-list '}'
      ##
      def parse_block_stmt()
         Kwartz::assert unless token() == '{'
         scan()
         stmt_list = parse_stmt_list()
         syntax_error("block-statement requires '}'.") unless token() == '}'
         scan()
         return BlockStatement.new(stmt_list)
      end


      ##
      ##  statement    ::=  print-stmt | if-stmt | foreach-stmt | while-stmt 
      ##                  | expr-stmt | block-stmt | expand-stmt | ';'
      ##
      def parse_statement()
         case token()
         when '}'
            return nil
         when '{'
            return parse_block_stmt()
         when :print
            return parse_print_stmt()
         when :if
            return parse_if_stmt()
         when :foreach, :for
            return parse_foreach_stmt()
         when :while
            return parse_while_stmt()
         when :element
            return parse_element_stmt()
         when '@', :expand
            return parse_expand_stmt()
         when ';'
            scan()
            return ';'
         when nil
            return
         when :name
            return parse_expr_stmt()
         else
            #return parse_expr_stmt()
            syntax_error("statement expected but got '#{token()}'")
         end
      end


      ## ------------------------------------------------------------
      
      ##
      ## plogic ::= { element_decl }
      ##
      def parse_plogic
         elem_decl_list = []
         while token() == '#'
            elem_decl = parse_element_decl()
            elem_decl_list << elem_decl
         end
         syntax_error("plogic is not ended.") unless token() == nil
         return elem_decl_list
      end
      
      ##
      ## element-decl  ::= '#' name '{' sub-decl-list '}'
      ## sub-decl-list ::= sub-decl | sub-decl-list sub-decl | e
      ## sub-decl      ::= value-decl | attr-decl | append-decl | remove-decl | tagname-decl | plogic-decl
      ##
      def parse_element_decl()
         Kwartz::assert unless token() == '#'
         tkn = scan()
         syntax_error("'#': element declaration requires an element name but got '#{token()}'") unless token() == :name
         marking = value()
         tkn = scan()
         syntax_error("'#': element declaration requires '{' but got '#{token()}'") unless token() == '{'
         scan()
         hash = parse_sub_decl_list()
         syntax_error("'#': element declaration requires '}' but got '#{token()}'") unless token() == '}'
         scan()
         return ElementDeclaration.create_from_hash(marking, hash)
      end
      
      def parse_sub_decl_list()
         hash = {}
         while true
            key, obj = parse_sub_decl()
            break unless key
            hash[key] = obj
         end
         return hash
      end
      
      def parse_sub_decl()
         obj = nil
         case key = token()
         when :value
            obj = parse_value_decl()
         when :attr
            obj = parse_attr_decl()
         when :append
            obj = parse_append_decl()
         when :remove
            obj = parse_remove_decl()
         when :tagname
            obj = parse_tagname_decl()
         when :plogic
            obj = parse_plogic_decl()
         else
            key = nil
            obj = nil
         end
         return key, obj
      end
      
      ##
      ##  value_dec  ::= 'value:' [ expression ] ';'
      ##
      def parse_value_decl()
         Kwartz::assert unless token() == :value
         tkn = scan()
         if tkn == ';'
            scan()
            return nil
         end
         expr = parse_expression()
         syntax_error("value-declaration requires ';'.") unless token() == ';'
         scan()
         return expr
      end
      
      ##
      ##  attr_decl ::= 'attr:' [ string expression { ',' string expression } ] ';'
      ##
      def parse_attr_decl()
         Kwartz::assert unless token() == :attr
         attrs = {}
         tkn = scan()
         if tkn == ';'
            scan()
            return attrs
         end
         while true
            aname_expr = parse_expression()
            syntax_error("attr-declaration requires attribute names as string.") unless aname_expr.token == :string
            aname = aname_expr.value
            avalue_expr = parse_expression()
            attrs[aname] = avalue_expr
            break if token() != ','
            scan()
         end
         syntax_error("attr-declaration requires ';'.") unless token() == ';'
         scan()
         return attrs
      end
      
      ##
      ## append_decl ::= 'append:' [ expression ] ';'
      ##
      def parse_append_decl()
         Kwartz::assert unless token() == :append
         list = []
         tkn = scan()
         if tkn == ';'
            scan()
            return nil
         end
         while true
            expr = parse_expression()
            list << expr
            break if token() != ','
            scan()
         end
         syntax_error("append-declaration requires ';'.") unless token() == ';'
         scan()
         return list
      end

      ##
      ## remove_decl ::= 'remove:' { string } ';'
      ##
      def parse_remove_decl()
         list = []
         Kwartz::assert unless token() == :remove
         while (tkn = scan()) == :string
            list << value()
         end
         syntax_error("append-declaration requires ';'.") unless token() == ';'
         scan()
         return list
      end
      
      ##
      ## tagname_decl ::= 'tagname:' [ expression ] ';'
      ##
      def parse_tagname_decl()
         Kwartz::assert unless token() == :tagname
         tkn = scan()
         if tkn == ';'
            scan()
            return nil
         end
         expr = parse_expression()
         syntax_error("tagname-declaration requires ';'.") unless token() == ';'
         scan()
         return expr
      end
      
      ##
      ## plogic_decl ::= 'plogic:' block-stmt
      ##
      def parse_plogic_decl()
         Kwartz::assert unless token() == :plogic
         tkn = scan()
         syntax_error("plogic-declaration requires '{'.") unless tkn == '{'
         block_stmt = parse_block_stmt()
         return block_stmt
      end
      
      
      ##
      ##
      ##

      def parse_program()
         stmt_list = parse_stmt_list()
         syntax_error("EOF expected but '#{token()}'.") unless token() == nil
         #return stmt_list
         return BlockStatement.new(stmt_list)
      end

      def parse()
         return parse_program()
      end

      def _scan_all()
         s = ''
         s << @scanner.token.to_s << "\n"
         while tkn = @scanner.scan()
            s << tkn.to_s << "\n"
         end
         return s
      end

   end
end


if __FILE__ == $0
   #--
   input = ARGF.read()
   parser = Kwartz::Parser.new(input)
   #--
   #decl_list = parser.parse_plogic()
   #decl_list.each do |elem_decl|
   #   print elem_decl._inspect()
   #end
   #--
   #expr = parser.parse_expression()
   #print expr._inspect()
   #--
   stmt_list = parser.parse_stmt_list()
   stmt_list.each do |stmt|
      print stmt._inspect()
   end
end
