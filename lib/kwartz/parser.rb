###
### copyright(c) 2005 kuwata-lab all rights reserved
###
### $Id$
### $Release$
###

require 'kwartz/exception'
require 'kwartz/scanner'
require 'kwartz/node'
require 'kwartz/element'
require 'kwartz/util/orderedhash'

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
         t = scan()
         syntax_error("foreach-statement requires loop-variable but got '#{t}'.") unless t == :name
         varname = value()
         loopvar_expr = VariableExpression.new(varname)
         t = scan()
         syntax_error("foreach-statement requires 'in' but got '#{t}'.") unless t == :in || t == '='
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
            t = scan()
            syntax_error("@element() requires '('.") unless t == '('
            t = scan()
            syntax_error("@element() requires an element name.") unless t == :name
            name = value()
            t = scan()
            syntax_error("@element() requires ')'.") unless t == ')'
         else
            syntax_error("'@' should be '@stag', '@cont', '@etag', or '@element(name)'.")
         end
         t = scan()
         syntax_error("@#{type} requires ';'.") unless t == ';'
         scan()
         return ExpandStatement.new(type.intern, name)
      end


      ##
      ## rawcode-stmt ::= '<%' strings "\n" | '<?' strings "\n"
      ##
      def parse_rawcode_stmt()
         Kwartz::assert unless token() == :rawcode
         rawcode = value()
         scan()
         return RawcodeStatement.new(rawcode)
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
         when :rawcode
            return parse_rawcode_stmt()
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
      ## EBNF:
      ##   presentation-logic ::= { ( element-decl | document-decl ) }
      ##
      def parse_plogic
         elem_decl_list = []
         while token() == '#'
            t = scan()
            syntax_error("'#': element declaration requires an element name.") unless t == :name
            if value() == 'DOCUMENT'
               elem_decl = parse_document_decl()
            else
               elem_decl = parse_element_decl()
            end
            elem_decl_list << elem_decl
         end
         syntax_error("plogic is not ended, or '#' not found.") unless token() == nil
         return elem_decl_list
      end

      ##
      ## EBNF:
      ##   element-decl  ::=  '#' name '{' { elem-part } '}'
      ##
      def parse_element_decl()
         return _parse_element_decl('element') { parse_elem_part() }
      end

      ##
      ## EBNF:
      ##   document-decl  ::=  '#' 'DOCUMENT' '{' { doc-part } '}'
      ##
      def parse_document_decl()
         return _parse_element_decl('document') { parse_doc_part() }
      end

      def _parse_element_decl(decl_name)
         Kwartz::assert("token()=#{token()}") unless token() == :name
         marking = value()
         t = scan()
         syntax_error("'#': #{decl_name} declaration requires '{'.") unless t == '{'
         scan()
         hash = {}
         while token() == :name
            key, obj = yield()		# parse_elem_part() or parse_doc_part()
            break unless key
            hash[key] = obj
         end
         syntax_error("'#': #{decl_name} declaration requires '}'.") unless token() == '}'
         scan()
         #return ElementDeclaration.create_from_hash(marking, hash)
         return Declaration.new(marking, hash)
      end
      private :_parse_element_decl


      ##
      ## EBNF:
      ##   elem-part     ::=  value-part | attr-part | remove-part | append-part | tagname-part | plogic-part
      ##
      def parse_elem_part()
         Kwartz::assert("token()=#{token()}") unless token() == :name
         obj = nil
         case key = value()
         when 'value'     ;   obj = parse_value_part()
         when 'attr'      ;   obj = parse_attr_part()
         when 'append'    ;   obj = parse_append_part()
         when 'remove'    ;   obj = parse_remove_part()
         when 'tagname'   ;   obj = parse_tagname_part()
         when 'plogic'    ;   obj = parse_plogic_part()
         else
            syntax_error("'#{value()}': invalid part-name.")
         end
         return key.intern, obj
      end


      ##
      ## EBNF:
      ##   doc-part      ::= begin-part | end-part | global-part | local-part | vartype-part
      ##
      def parse_doc_part()
         Kwartz::assert("token()=#{token()}") unless token() == :name
         key = value()
         case key
         when 'begin'           ;   obj = parse_begin_part()
         when 'end'             ;   obj = parse_end_part()
         when 'global'          ;   obj = parse_global_part()
         when 'local'           ;   obj = parse_local_part()
         when 'require'         ;   obj = parse_require_part()
         when 'vartype'         ;   obj = parse_vartype_part()
         when 'global_vartype'  ;   obj = parse_globalvartype_part()
         when 'local_vartype'   ;   obj = parse_localvartype_part()
         else
            syntax_error("'#{value()}': invalid part-name.")
         end
         return key.intern, obj
      end


      ##
      ## EBNF:
      ##   value-part    ::=  'value' ':' [ expression ] ';'
      ##
      def parse_value_part()
         Kwartz::assert unless value() == 'value'
         expr = _parse_part_expr('value')
         return expr
      end

      def _parse_part_expr(part_name)
         Kwartz::assert unless value() == part_name
         scan()
         syntax_error("'#{part_name}' requires ':'.") unless token() == ':'
         t = scan()
         if t == ';'
            scan()
            return nil
         end
         expr = parse_expression()
         syntax_error("#{part_name}-part requires ';'.") unless token() == ';'
         scan()
         return expr
      end
      private :_parse_part_expr


      ##
      ## EBNF:
      ##   attr-part     ::=  'attr' ':' [ string '=>' expression { ',' string '=>' expression } ] ';'
      ##
      def parse_attr_part()
         Kwartz::assert unless value() == 'attr'
         hash = _parse_part_hash('attr')
         return hash
      end

      def _parse_part_hash(part_name)
         Kwartz::assert unless value() == part_name
         scan()
         syntax_error("'#{part_name}' requires ':'.") unless token() == ':'
         scan()
         attrs = Kwartz::Util::OrderedHash.new
         while token() != ';'
            aname_expr = parse_expression()
            syntax_error("attr-declaration requires attribute names as string.") unless aname_expr.token == :string
            aname = aname_expr.value
            avalue_expr = parse_expression()
            attrs[aname] = avalue_expr
            break if token() != ','
            scan()
         end
         syntax_error("#{part_name}-part requires ';'.") unless token() == ';'
         scan()
         return attrs
      end
      private :_parse_part_hash


      ##
      ## EBNF:
      ##   remove-part   ::=  'remove' ':' [ string { ',' string } ] ';'
      ##
      def parse_remove_part()
         list = _parse_part_strs('remove')
         return list
      end

      def _parse_part_strs(part_name)
         Kwartz::assert unless value() == part_name
         scan()
         syntax_error("'#{part_name}' requires ':'.") unless token() == ':'
         list = []
         while (t = scan()) != ';'         # or t == :string
            syntax_error("#{part_name}-part requires a string.") unless token() == :string
            str = value()
            list << str
            t = scan()
            break if t != ','
         end
         syntax_error("#{part_name}-part requires ';'.") unless token() == ';'
         scan()
         return list
      end
      private :_parse_part_strs


      ##
      ## EBNF:
      ##   append-part   ::=  'append' ':' [ expression { ',' expression } ] ';'
      ##
      def parse_append_part()
         list = _parse_part_exprs('append')
         return list
      end

      def _parse_part_exprs(part_name)
         Kwartz::assert unless value() == part_name
         scan()
         syntax_error("'#{part_name}' requires ':'.") unless token() == ':'
         list = []
         while (t = scan()) != ';'
            expr = parse_expression()
            list << expr
            break if token() != ','
         end
         syntax_error("#{part_name}-part requires ';'.") unless token() == ';'
         scan()
         return list
      end
      private :_parse_part_expr


      ##
      ## EBNF:
      ##   tagname-part  ::=  'tagname' ':' [ expression ] ';'
      ##
      def parse_tagname_part()
         expr = _parse_part_expr('tagname')
         return expr
      end


      ##
      ## EBNF:
      ##   plogic-part   ::=  'plogic' ':' block-stmt
      ##
      def parse_plogic_part()
         block_stmt = _parse_part_blockstmt('plogic')
         return block_stmt
      end

      def _parse_part_blockstmt(part_name)
         Kwartz::assert unless value() == part_name
         t = scan()
         syntax_error("#{part_name}-declaration requires ':'.") unless t == ':'
         t = scan()
         syntax_error("#{part_name}-declaration requires '{'.") unless t == '{'
         block_stmt = parse_block_stmt()
         return block_stmt
      end
      private :_parse_part_blockstmt


      ##
      ## EBNF:
      ##   begin-part    ::= 'begin' ':' block-stmt
      ##
      def parse_begin_part()
         block_stmt = _parse_part_blockstmt('begin')
         return block_stmt
      end


      ##
      ## EBNF:
      ##   end-part      ::= 'end' ':' block-stmt
      ##
      def parse_end_part()
         block_stmt = _parse_part_blockstmt('end')
         return block_stmt
      end


      ##
      ## EBNF:
      ##   global-part   ::= 'global' ':' [ name { ',' name } ] ';'
      ##
      def parse_global_part()
         list = _parse_part_names('global')
         return list
      end


      ##
      ## EBNF:
      ##   local-part    ::= 'local' ':'  [ name { ',' name } ] ';'
      ##
      def parse_local_part()
         list = _parse_part_names('local')
         return list
      end

      def _parse_part_names(key)
         Kwartz::assert unless token() == :name && value() == key
         t = scan()
         syntax_error("#{key}-part requires ':'.") unless t == ':'
         list = []
         t = scan()
         #while t != ';'
         while t == :name
            name = value()
            list << name
            t = scan()
            break if t != ','
            t = scan()
         end
         syntax_error("#{key}-part requires ';'.") unless t == ';'
         scan()
         return list
      end
      private :_parse_part_names


      ##
      ## EBNF:
      ##   require-part    ::= 'require' ':'  [ filename-str { ',' filename-str } ] ';'
      ##   filename-str    ::= '"' filename '"'
      ##
      def parse_require_part()
         #Kwartz::assert unless token() == :name && value() == 'require'
         Kwartz::assert unless value() == 'require'
         list = _parse_part_strs('require')
         return list
      end


      ##
      ## EBNF:
      ##  vartype-part  ::= 'vartype' ':' '{' { type varname ';' } '}'
      ##
      def parse_vartype_part()
         hash = _parse_part_vartype('vartype')
         return hash
      end

      def parse_gvartype_part()
         hash = _parse_part_vartype('global_vartype')
         return hash
      end

      def parse_lvartype_part()
         hash = _parse_part_vartype('local_vartype')
         return hash
      end

      def _parse_part_vartype(part_name)
         Kwartz::assert unless token() == :name && value() == part_name
         t = scan()
         syntax_error("#{part_name}-declaration requires ':'.") unless t == ':'
         t = scan()
         syntax_error("#{part_name}-declaration requires '{'.") unless t == '{'
         hash = Kwartz::Util::OrderedHash.new
         scan()
         while token() != '}'
            varname, vartype = _parse_vartype(part_name)
            hash[varname] = vartype
         end
         syntax_error("#{part_name}-declaration is not closed by '}'.") unless token() == '}'
         scan()
         return hash
      end
      private :_parse_part_vartype

      def _parse_vartype(part_name)
         Kwartz::assert unless token() != '}'
         list = []
         t = token()
         while t != ';' && t != '}' && t != nil		# Ohhhh...
            list << (t.is_a?(String) ? t : value())
            t = scan()
         end
         syntax_error("#{part_name}-part requires ';'.") unless token() == ';'
         scan()
         varname = list.pop()
         vartype = list.join(' ')
         return varname, vartype
      end
      private :_parse_vartype


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
   decl = parser.parse_document_decl()
   print decl._inspect
   #--
   #decl_list = parser.parse_plogic()
   #decl_list.each do |elem_decl|
   #   print elem_decl._inspect()
   #end
   #--
   #expr = parser.parse_expression()
   #print expr._inspect()
   #--
   #stmt_list = parser.parse_stmt_list()
   #stmt_list.each do |stmt|
   #   print stmt._inspect()
   #end
end
