###
### parser.rb
###
### $Id$
###

require 'kwartz/exception'
require 'kwartz/scanner'
require 'kwartz/node'

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

      def check_token(tkn, msg)
         syntax_error(msg) unless tkn == token()
      end

      def check_token2(tkn, msg)
         check_token(tkn, msg)
         scan()
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
         arglist = []
         return arglist if token() == ')'
         expr = parse_expression()
         arglist << expr
         while token() == ','
            scan()
            expr = parse_expression()
            arglist << expr
         end
         return arglist
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
            if tkn == '('
               scan()
               arglist = parse_arguments()
               check_token(')', "missing ')' of '#{name}()' (current token='#{tkn}').")
               scan()
               scan()
               return FunctionExpression.new(name, arglist)
            else
               return VariableExpression.new(name)
            end
         elsif tkn == '('
            scan()
            expr = parse_expression()
            check_token(')', "')' expected ('(' is not closed by ')').")
            scan()
            scan()
            return expr
         else
            Kwartz::assert(false, "tkn == #{tkn}")
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
            scan()
            return NumericExpression.new(value())
         when :string
            scan()
            return StringExpression.new(value())
         when :true, :false
            scan()
            return BooleanExpression.new(value())
         when :null
            scan()
            return NullExpression.new(value())
         when :empty
            syntax_error("'empty' is allowed only in right-side of '==' or '!='.")
         end
         Kwartz::assert(false, "tkn = #{token}")
      end


      ##
      ## BNF:
      ##  factor       ::=  literal | item | item '[' expression ']' | item '[:' name ']' | item '.' property
      ##
      def parse_factor_expr
         tkn = token()
         case tkn
         when :name, '('
            expr = parse_item_expr()
            if token() == '['
               scan()
               expr2 = parse_expression()
               check_token(']', "']' expected ('[' is not closed by ']').")
               scan()
               return BinaryExpression.new('[]', expr, expr2)
            elsif token() == '[:'
               scan()
               word = value()
               check_token(:name, "'#{tkn}': '[:' requires a word following.")
               scan()
               check_token(']', "'[:' is not closed by ']'.")
               scan()
               return BinaryExpression.new('[:]', expr, StringExpression.new(word))
            elsif token() == '.'
               scan()
               prop_name = value()
               check_token(:name, "'#{tkn}': '.' requires a property name following.")
               scan()
               if token() == '('
                  scan()
                  arglist = parse_arguments()
                  check_token(')', "')' expected (property '#{prop_name}()' is not closed by ')').")
                  scan()
               else
                  arglist = nil
               end
               return PropertyExpression.new(expr, prop_name, arglist)
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
      ##  term         ::=  factor | term * factor | term '/' factor | term '%' factor
      ##               ::=  factor { ('*' | '/' | '%') factor }
      ##
      def parse_term_expr
         expr = parse_factor_expr()
         while (tkn = token()) == '*' || tkn == '/' || tkn == '%'
            scan()
            expr2 = parse_factor_expr()
            expr = BinaryExpression.new(tkn, expr, expr2)
         end
         return expr
      end


      ##
      ## BNF:
      ##  unary        ::=  term | '+' term | '-' term | '!' term
      ##               ::=  [ '+' | '-' | '!' ] term
      ##
      def parse_unary_expr
         if (tkn = token()) == '+' || tkn == '-' || tkn == '!'
            scan()
            expr2 = parse_term_expr()
            op = tkn == '!' ? tkn : tkn + '.'
            expr = UnaryExpression.new(op, expr2)
         else
            expr = parse_term_expr()
         end
         return expr
      end


      ##
      ## BNF:
      ##  arith        ::=  unary | arith '+' term | arith '-' term | arith '.+' term
      ##               ::=  unary { ('+' | '-' | '.+') term }
      ##
      def parse_arith_expr
         expr = parse_unary_expr()
         while (tkn = token()) == '+' || tkn == '-' || tkn == '.+'
            scan()
            expr2 = parse_term_expr()
            expr = BinaryExpression.new(tkn, expr, expr2)
         end
         return expr
      end


      ##
      ## BNF:
      ##  compare-op   ::=  '==' |  '!=' |  '>' |  '>=' |  '<' |  '<='
      ##  compare      ::=  arith | arith compare-op arith | arith '==' 'empty' | arith '!=' 'empty'
      ##               ::=  arith [ compare-op arith ] | arith ('==' | '!=') 'empty'
      ##
      def parse_compare_expr
         expr = parse_arith_expr()
         while (op = token()) == '==' || op == '!=' || op == '>' || op == '>=' || op == '<' || op == '<='
            scan()
            if token() == :empty
               if op == '=='
                  scan()
                  expr = UnaryExpression.new(:empty, expr)
               elsif op == '!='
                  scan()
                  expr = UnaryExpression.new(:notempty, expr)
               else
                  syntax_error("'empty' is allowed only at the right-side of '==' or '!='.")
               end
            else
               expr2 = parse_arith_expr()
               expr = BinaryExpression.new(op, expr, expr2)
            end
         end
         return expr
      end


      ##
      ## BNF:
      ##  logical-and  ::=  compare | logical-and '&&' compare
      ##               ::=  compare { '&&' compare }
      ##
      def parse_logical_and_expr
         expr = parse_compare_expr()
         while (op = token()) == '&&'
            scan()
            expr2 = parse_compare_expr()
            expr = BinaryExpression.new(op, expr, expr2)
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
            expr = BinaryExpression.new(op, expr, expr2)
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
            check_token(':', "':' expected ('?' requires ':').")
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
         while (op = token()) == '=' || op == '+=' || op == '-=' || op == '*=' || op == '/=' || op == '%=' || op == '.+='
            scan()
            expr2 = parse_assignment_expr()
            expr = BinaryExpression.new(op, expr, expr2)
         end
         return expr
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
         Kwartz::assert(token() == :print)
         tkn = scan()
         check_token('(', "print-statement requires '('.") unless tkn != '('
         scan()
         arglist = parse_arguments()
         check_token(')', "print-statement requires ')'.") unless token() != ')'
         tkn = scan()
         check_token(';', "print-statement requires ';'.") unless tkn != ';'
         scan()
         return PrintStatement.new(arglist)
      end
      
      
      ##  
      ##  expr-stmt    ::=  expression ';'
      ##  
      def parse_expr_stmt()
         expr = parse_expression()
         check_token(';', "expression-statement requires ';'.") unless token() != ';'
         scan()
         return ExpressionStatement.new(expr)
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
         Kwartz::assert(token() == :if || token() == :elseif)
         tkn = scan()
         check_token('(', "if-statement requires '('.") unless tkn == '('
         scan()
         cond_expr = parse_expression()
         check_token(')', "if-statement requires ')'.") unless tkn == ')'
         scan()
         then_body = parse_statement()
         if token() == :elseif
            scan()
            tkn = scan()
            check_token('(', "elseif-statement requires ')'.") unless tkn == '('
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
         Kwartz::assert(token() == 'foreach')
         tkn = scan()
         check_token('(', "foreach-statement requires '('.") unless tkn == '('
         tkn = scan()
         check_token(:variable, "foreach-statement requires loop-variable but got '#{tkn}'.") unless tkn == :variable
         loopvar_name = value()
         tkn = scan()
         check_token(:in, "foreach-statement requires 'in' but got '#{tkn}'.") unless tkn == :in
         scan()
         list_expr = parse_expression()
         check_token(')', "foreach-statement requires ')'.") unless tkn == ')'
         scan()
         body_stmt = parse_statement()
         return ForeachStatement(loopvar_name, list_expr, body_stmt)
      end
      
      
      ##  
      ##  while-stmt   ::=  'while' '(' expression ')' statement
      ##
      def parse_while_stmt()
         Kwartz::assert(token() == :while)
         tkn = scan()
         check_token('(', "while-statement requires '('") unless tkn == '('
         scan()
         cond_expr = parse_expression()
         tkn = scan()
         check_token(')', "while-statement requires ')'") unless tkn == ')'
         scan()
         body_stmt = parse_statement()
         return WhileStatement.new(cond_expr, body_stmt)
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
         Kwartz::assert(token() == '{')
         scan()
         stmt_list = parse_stmt_list()
         check_token('}', "block-statement requires '}'.") unless token() != '}'
         scan()
         return BlockStatement(stmt_list)
      end

      
      ##
      ##  statement    ::=  print-stmt | expr-stmt | if-stmt | foreach-stmt | while-stmt | block-stmt | ';'
      ##
      def parse_statement()
         case token()
         when '{'
            return parse_block_stmt()
         when :print
            return parse_print_stmt()
         when :if
            return parse_if_stmt()
         when :foreach
            return parse_foreach_stmt()
         when :while
            return parse_while_stmt()
         when :element
            return parse_element_stmt()
         when :expand
            return parse_expand_stmt()
         when ';'
            scan()
            return ';'
         else
            return parse_expr_stmt()
         end
      end
      


      ##

      def parse_program()
         block = parse_block_statement()
         token_check(nil, "EOF expected but '#{token()}'.")
         return block
      end

      def parse()
         #return parse_program()
         s
         while tkn = @scanner.scan()

         end
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
