###
### copyright(c) 2005 kuwata-lab all rights reserved
###
### $Id$
###

require 'kwartz/exception'
require 'kwartz/node'
require 'kwartz/visitor'
require 'kwartz/utility'
require 'kwartz/util/orderedhash'


module Kwartz

   class AnalyzeError < BaseError
      def initialize(message)
         super(message)
      end
   end

   class Analyzer
      include Visitor

      def initialize(properties={})
         @properties = properties
      end

      def analyze(node, depth=0)
         #raize Kwartz::NotImplementedError.new("#{self.class.name}#analyze(): not implemented.")
         return node.accept(self, depth)
      end

      def analyze_expression(expr, depth=0)
         # raize Kwartz::NotImplementedError.new("#{self.class.name}#analyze_expression(): not implemented.")
         return expr.accept(self, depth)
      end

      def analyze_statement(stmt, depth=0)
         #raize Kwartz::NotImplementedError.new("#{self.class.name}#analyze_statement(): not implemented.")
         return stmt.accept(self, depth)
      end

      def visit_expand_statement(stmt, depth=0)
         raise AnalyzeError.new("analyzer cannot accept expand-statement.")
      end

      def result()
         raize Kwartz::NotImplementedError.new("#{self.class.name}#result() is not implemented.")
      end


      @@subclasses = {}
      def self.register(name, klass)
         @@subclasses[name] = klass
      end

      def self.create(name, property={})
         klass = @@subclasses[name]
         unless klass
            raise AnalyzeError.new("'#{name}': no such analyzer.")
         end
         return klass.new(property)
      end

   end


   class ScopeAnalyzer < Analyzer

      def self.name
         return "scope"
      end

      Analyzer.register("scope", self)

      def initialize(properties={})
         super(properties)
         @local_vars  = Kwartz::Util::OrderedHash.new
         @global_vars = Kwartz::Util::OrderedHash.new
         @warnings = []
      end
      attr_reader :local_vars, :global_vars, :warnings

      protected

      def add_local(var_expr)
         @local_vars[var_expr.name] = var_expr
      end

      def add_global(var_expr)
         @global_vars[var_expr.name] = var_expr
      end

      def local?(var_expr)
         return @local_vars.key?(var_expr.name)
      end

      def global?(var_expr)
         return @global_vars.key?(var_expr.name)
      end

      def registered?(var_expr)
         return @local_vars.key?(var_expr.name) || @global_vars.key?(var_expr.name)
      end

      def add_warning(cause, name)
         entry = @warnings.find { |warn| warn[0] == cause && warn[1] == name }
         @warnings << [ cause, name ] unless entry
      end

      public

      @@warning_messages = {
         :unsupported_func => "unsupported function '%s' is used.",
         :gvar_assign      => "assignment into a global variable '%s'.",
         :gvar_loopvar     => "using a global variable '%s' as loopvar in foreach-statement.",
      }

      def result
         s = ''
         s << 'Global variable(s): ' << @global_vars.keys.join(' ') << "\n"
         s << 'Local  variable(s): ' << @local_vars.keys.join(' ')  << "\n"
         @warnings.each do |warn|
            cause = warn[0];  name = warn[1]
            message = @@warning_messages[cause]
            Kwartz::assert("cause = #{cause}") unless message != nil
            s << "Warning: #{message % name}\n"
         end
         return s
      end

      ## --------------------

      def visit_binary_expression(expr, depth=0)
         analyze_expression(expr.left, depth+1)    # left first
         analyze_expression(expr.right, depth+1)
      end
      
      alias :visit_arithmetic_expression :visit_binary_expression
      alias :visit_relational_expression :visit_binary_expression
      alias :visit_logical_expression    :visit_binary_expression
      alias :visit_index_expression      :visit_binary_expression
      
      def visit_assignment_expression(expr, depth=0)
         if expr.token == '='
            analyze_expression(expr.right, depth+1)  # right first
            if expr.left.is_a?(VariableExpression)
               var_expr = expr.left
               if global?(var_expr)
                  #@warnings << "assignment into a global variable '#{var_expr.name}'."
                  add_warning(:gvar_assign, var_expr.name)
               elsif !local?(var_expr)
                  add_local(var_expr)
               end
            else
               analyze_expression(expr.left, depth+1)
            end
         else
            analyze_expression(expr.right, depth+1)   # right first
            analyze_expression(expr.left, depth+1)
            if expr.left.is_a?(VariableExpression) && global?(expr.left)
               #@warnings << "assignment into a global variable '#{expr.left.name}'."
               add_warning(:gvar_assign, expr.left.name)
            end
         end
      end
      
      
      @@func_names = {
         'list_new'    => true,
         'list_length' => true,
         'list_empty'  => true,
         'hash_new'    => true,
         'hash_keys'   => true,
         'hash_empty'  => true,
         'str_length'  => true,
         'str_trim'    => true,
         'str_tolower' => true,
         'str_toupper' => true,
         'str_index'   => true,
         'str_empty'   => true,
         'E'           => true,
         'X'           => true,
      }

      def visit_funtion_expression(expr, depth=0)
         funcname = expr.funcname
         if !@@func_names[funcname]
            #@warnings << [funcname, "unsupported function '#{funcname}' is used."]
            add_warning(:unsupported_func, funcname)
         end
         super(expr, depth)
      end

      def visit_variable_expression(var_expr, depth=0)
         add_global(var_expr) unless registered?(var_expr)
      end

      def visit_literal_expression(expr, depth=0)
         # nothing
      end
      alias :visit_numeric_expression :visit_literal_expression
      alias :visit_string_expression :visit_literal_expression
      alias :visit_boolean_expression :visit_literal_expression
      alias :visit_null_expression :visit_literal_expression

      def visit_foreach_statement(stmt, depth=0)
         analyze_expression(stmt.list_expr())
         var_expr = stmt.loopvar_expr
         if global?(var_expr)
            # @warnings << "using a global variable '#{var_expr.name}' as loopvar in foreach-statement."
            add_warning(:gvar_loopvar, var_expr.name)
         elsif !local?(var_expr)
            add_local(var_expr)
         end
         analyze_statement(stmt.body_stmt())
      end

   end

end


if __FILE__ == $0
   require 'kwartz/compiler'

   plogic_filename = nil
   plogic_str = ''
   flag_escape = false
   while ARGV[0] && ARGV[0][0] == ?-
      opt = ARGV.shift
      case opt
      when '-p'
         plogic_filename = ARGV.shift
         plogic_str = File.open(plogic_filename) { |f| f.read() }
      when '-e'
         flag_escape = true
      end
   end

   pdata_str = ARGF.read()
   pdata_filename = ARGF.filename()
   properties = {}
   properties[:escape] = true if flag_escape
   compiler = Kwartz::Compiler.new(properties)

   ## convert
   block_stmt, element_list = compiler.convert(pdata_str, pdata_filename)
   ## parse presentation logic
   elem_decl_list = compiler.parse_plogic(plogic_str, plogic_filename)
   ## merge
   element_table = compiler.merge(element_list, elem_decl_list)
   ## expand
   compiler.expand(block_stmt, element_table)
   #print block_stmt._inspect
   ## analyze
   analyzer = Kwartz::Analyzer.create('scope', properties)
   analyzer.analyze(block_stmt)
   print analyzer.result

end
