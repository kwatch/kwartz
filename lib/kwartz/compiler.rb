###
### copyright(c) 2005 kuwata-lab all rights reserved
###
### $Id$
###

require 'kwartz/exception'
require 'kwartz/converter'
require 'kwartz/parser'
require 'kwartz/expander'
require 'kwartz/translator'


module Kwartz

   ## ex.
   ##  ## create comiler
   ##  properties = { :escape => true}
   ##  compiler = Kwartz::Compiler.new(properties)
   ##  ## convert presentation data
   ##  pdata_str = ARGF.read()
   ##  pdata_filename = ARGF.filename
   ##  block_stmt, element_list = compiler.convert(pdata_str, pdata_filename)
   ##  ## parse presentation logic
   ##  plogic_filename = 'xxx.plogic'
   ##  plogic_str = File.open(filename) { |f| f.read() }
   ##  decl_list = compiler.parse_plogic(plogic_str, plogic_filename)
   ##  ## merge element and element-declaration
   ##  element_table = compiler.merge(element_list, decl_list)
   ##  ## expand '@element(foo)', '@stag', '@cont', and '@etag'
   ##  compiler.expand(block_stmt, element_table)
   ##  ## translate into a target language code
   ##  lang='eruby'
   ##  code = translate(block_stmt, lang)
   ##
   class Compiler
      def initialize(properties={})
         @properties = properties
      end
      attr_reader :properties


      ## ex.
      ##   block_stmt, element_list = compiler.convert(ARGF.read(), ARGF.filename)
      def convert(pdata_str, filename=nil)
         @properties[:filename] = filename if filename
         converter = Kwartz::Converter.new(@properties)
         block_stmt = converter.convert(pdata_str)
         elem_list = converter.element_list
         @properties.delete(:filename) if filename
         return block_stmt, elem_list
      end


      ## ex.
      ##  filename = 'xxx.plogic'
      ##  plogic_str = File.open(filename) { |f| f.read() }
      ##  decl_list = compiler.parse_plogic(plogic_str, filename)
      def parse_plogic(plogic_str, filename=nil)
         @properties[:filename] = filename if filename
         parser = Kwartz::Parser.new(plogic_str, @properties)
         decl_list = parser.parse_plogic()
         @properties.delete(:filename) if filename
         return decl_list
      end


      ## ex.
      ##  str = ARGF.read()
      ##  filename = ARGF.filename
      ##  block_stmt = compiler.parse_program(str, filename)
      def parse_program(program_str, filename=nil)
         @properties[:filename] = filename if filename
         parser = Kwartz::Parser.new(program_str, @properties)
         block_stmt = parser.parse_program()
         @properties.delete(:filename) if filename
         return block_stmt
      end


      ## ex.
      ##  element_table = compiler.merge(element_list, decl_list)
      def merge(element_list, decl_list=[])
         return Kwartz::Element.merge(element_list, decl_list)
      end
      
      
      ##
      def handle_doc_decl(block_stmt, doc_decl)
         begin_block = doc_decl.part[:begin]
         end_block   = doc_decl.part[:end]
         block_stmt.statements.unshift(begin_block) if begin_block
         block_stmt.statements.push(end_block)      if end_block
         return block_stmt
      end


      ## ex.
      ##  compiler.expand(block_stmt, element_table)
      def expand(stmt, element_table={})
         expander = Kwartz::Expander.new(element_table, @properties)
         expander.expand(stmt)
         return stmt
      end


      ## ex.
      ##   lang='eruby'
      ##   code = compiler.translate(block_stmt, lang)
      def translate(node, lang)
         translator = Kwartz::Translator.create(lang, @properties)
         code = translator.translate(node)
         return code
      end


      ## facade method
      def compile(pdata_str='', plogic_str='', lang=Kwartz::Config::LANG, pdata_filename=nil, plogic_filename=nil)
         ## convert
         block_stmt, elem_list = convert(pdata_str, pdata_filename)
         ## parse plogic
         decl_list = parse_plogic(plogic_str, plogic_filename)
         ## merge
         element_table = merge(elem_list, decl_list)
         ## handle 'begin:' and 'end:'
         doc_decl = decl_list.find { |decl| decl.name == 'DOCUMENT' }
         handle_doc_decl(block_stmt, doc_decl) if doc_decl
         ## expand
         expand(block_stmt, element_table)
         ## translate
         code = translate(block_stmt, lang)
         return code
      end


      ## facade method
      def analyze(pdata_str='', plogic_str='', name='scope', pdata_filename=nil, plogic_filename=nil)
         ## convert
         block_stmt, elem_list = convert(pdata_str, pdata_filename)
         ## parse plogic
         decl_list = parse_plogic(plogic_str, plogic_filename)
         ## merge
         element_table = merge(elem_list, decl_list)
         ## handle 'begin:' and 'end:'
         doc_decl = decl_list.find { |decl| decl.name == 'DOCUMENT' }
         handle_doc_decl(block_stmt, doc_decl) if doc_decl
         ## expand
         expand(block_stmt, element_table)
         ## analye
         analyzer = Analyzer.create(name, properties)
         analyzer.analyze(block_stmt)
         return analyzer.result()
      end

   end
end


if __FILE__ == $0

   require 'kwartz/translator/eruby'
   require 'kwartz/translator/php'
   require 'kwartz/translator/jstl'

   plogic_filename = nil
   plogic_str = ''
   lang = 'eruby'
   flag_escape = false
   while ARGV[0] && ARGV[0][0] == ?-
      opt = ARGV.shift
      case opt
      when '-p'
         plogic_filename = ARGV.shift
         plogic_str = File.open(plogic_filename) { |f| f.read() }
      when '-l'
         lang = ARGV.shift
      when '-e'
         flag_escape = true
      end
   end

   pdata_str = ARGF.read()
   pdata_filename = ARGF.filename()
   properties = {}
   properties[:escape] = true if flag_escape
   compiler = Kwartz::Compiler.new(properties)
   code = compiler.compile(lang, pdata_str, plogic_str, pdata_filename, plogic_filename)
   print code

end
