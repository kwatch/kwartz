###
### copyright(c) 2005 kuwata-lab all rights reserved
###
### $Id$
### $Release$
###

require 'kwartz/utility'
require 'kwartz/node'
require 'kwartz/element'

module Kwartz

   class ExpantionError < BaseError
      def initialize(msg)
         super(msg)
      end
   end

   class Expander
   
      def initialize(element_table, properties={})
         @element_table = element_table
         @properties = properties
      end
      
      def expand(stmt, elem=nil)
         case stmt.token
         when :expand
            if    stmt.type == :stag
               return elem.stag_stmt
            elsif stmt.type == :cont
               cont_st = elem.cont_stmt
               st = expand(cont_st, elem)
               return st || cont_st
               #Kwartz::assert unless cont_st.token == :block
               #st = expand(cont_st, elem)
               #Kwartz::assert unless st == nil
               #return const_st
            elsif stmt.type == :etag
               return elem.etag_stmt
            elsif stmt.type == :element
               elem2 = @element_table[stmt.name]
               unless elem2
                  raise ExpantionError.new("'@element(#{stmt.name})': element not found.")
               end
               stmt2 = expand(elem2.plogic, elem2)
               Kwartz::assert(stmt2._inspect) unless stmt2 == nil
               return elem2.plogic
            else
               Kwartz::assert
            end
         when :print
            return nil
         when :expr
            return nil
         when :if
            st = expand(stmt.then_stmt, elem)
            stmt.then_stmt = st if st
            if stmt.else_stmt
               st = expand(stmt.else_stmt, elem)
               stmt.else_stmt = st if st
            end
            return nil
         when :foreach, :while
            st = expand(stmt.body_stmt, elem)
            stmt.body_stmt = st if st
            return nil
         when :block
            list = stmt.statements
            list.each_with_index do |st, i|
               st2 = expand(st, elem)
               list[i] = st2 if st2
            end
            return nil
         end
         Kwartz::assert("stmt.token == #{stmt.token}")
      end
   end

end

if __FILE__ == $0

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

   require 'kwartz/converter'
   require 'kwartz/parser'
   require 'kwartz/element'

   ## convert
   converter = Kwartz::Converter.new(pdata_str, properties)
   block_stmt = converter.convert()
   elem_list = converter.element_list
   ## parse plogic
   parser = Kwartz::Parser.new(plogic_str, properties)
   elem_decl_list = parser.parse_plogic()
   ## merge
   element_table = Kwartz::Element.merge(elem_list, elem_decl_list)
   ## expand
   expander = Kwartz::Expander.new(element_table, properties)
   expander.expand(block_stmt)
   ##
   print block_stmt._inspect

end
