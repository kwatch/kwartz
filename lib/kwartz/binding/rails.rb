###
### $Rev$
### $Release$
### $Copyright$
###

require 'kwartz/converter'
#require 'kwartz/translator'
require 'kwartz/binding/eruby'



module Kwartz



  ##
  ## directive handler for Rails
  ##
  ## ex.
  ##  converter = Converter.new(pdata, decls, :handler=>RailsDirectiveHandler.new)
  ##
  ## directive examples.
  ##
  ##  ## text_field, password_field
  ##  <input type="text" size="10" maxsize="20" kw:d="text_field 'user', 'name'">
  ##   => <%= text_field 'user', 'name', :size=>10, :maxsize=>20 %>
  ##  <input type="text" name="user[name]" kw:d="text_field :size=>10">
  ##   => <%= text_field "user", "name", :size=>10 %>
  ##  <input type="text" id="user_name" size="10" kw:d="text_field">
  ##   => <%= text_field "user", "name", :size=>10 %>
  ##
  ##  ## link_to, link_to_remote
  ##  <a href="#" kw:d="link_to :action=>'list'">Show list</a>
  ##   => <%= link_to 'Show list', :action=>'list' %>
  ##
  ##  ## start_link_tag, start_remote_link_tag
  ##  <a href="#" kw:d="start_link_tag :action=>'list'">Show list</a>
  ##   => <%= start_link_tag 'action'=>'list' %>Show list</a>
  ##
  ##  ## mail_to
  ##  <a href="mail:www@example.com" kw:d="mail_to">admin</a>
  ##   => <%= mail_to "www@example.com", "admin" %>
  ##
  ##  ## form_tag
  ##  <form action="show" kw:d="form_tag :id=>2"> ... </form>
  ##   => <%= form_tag :action=>"show", :id=>2 %> ... </form>
  ##
  ##  ## submit_tag
  ##  <input type="submit" value="OK" kw:d="submit_tag">
  ##   => <%= submit_tag "OK" %>
  ##
  ##  ## text_area
  ##  <textarea cols="30" rows="3" id="user_desc" kw:d="text_area"></textarea>
  ##   => <%= text_area "user", "desc", :cols=>30, :rows=>3 %>
  ##  <textarea cols="30" rows="3" name="user[desc]" kw:d="text_area"></textarea>
  ##   => <%= text_area "user", "desc", :cols=>30, :rows=>3 %>
  ##
  ##  ## hidden_field
  ##  <input type="hidden" id="user_id" kw:d="hidden_field">
  ##   => <%= hidden_field "user", "id" %>
  ##  <input type="hidden" name="user[id]" kw:d="hidden_field">
  ##   => <%= hidden_field "user", "id" %>
  ##
  ##  ## check_box
  ##  <input type="checkbox" id="user_chk1" kw:d="check_box">
  ##   => <%= check_box "user", "chk1" %>
  ##  <input type="checkbox" name="user[chk2]" kw:d="check_box">
  ##   => <%= check_box "user", "chk2" %>
  ##
  ##  ## radio_button
  ##  <input type="radio" id="user_radio" value="val1" kw:d="radio_button">
  ##   => <%= radio_button "user", "radio", "val1" %>
  ##  <input type="radio" name="user[radio]" value="val2" kw:d="radio_button">
  ##   => <%= radio_button "user", "radio", "val2" %>
  ##
  ##  ## select, collection_select, country_select, time_zone_select, date_select, datetime_select
  ##  <select name="user[birth]" kw:d="date_select :start_year=>1970">
  ##    <option value="2000">2000</option>
  ##  </select>
  ##   => <% date_select "user", "birth", :start_year=>1970 %>
  ##
  ##  ## image_tag, link_image_to, link_to_image
  ##  <img src="foo.gif" alt="text" width="20" heigth="10" kw:d="image_tag :size=>'30x40'">
  ##   => <%= image_tag "foo.gif", :alt=>"text", :size=>'30x40' %>
  ##

  class RailsHandler < ErubyHandler


    ##
    ## handle directives for rails.
    ##
    ## everytime return true whenever directive name is unknown.
    ##
    def handle(stmt_list, handler_arg)
      ret = super
      return ret if ret

      arg = handler_arg
      d_name = arg.directive_name
      d_arg  = arg.directive_arg
      d_str  = arg.directive_str
      attr_info = arg.attr_info

      ## parse 'name="user[name]"' or 'id="user_name"'
      case d_name.to_s
      when /(_|\A)radio_button\z/
        add_directive_object_and_method_and_value(d_arg, attr_info)
      when /_field\z/, /_area\z/, /_box\z/, /(_|\A)select\z/, 'input'
        add_directive_object_and_method(d_arg, attr_info)
      end

      ## replace whole element, or only start tag
      replace_elem = d_name.to_s !~ /\Astart_/

      case d_name

      when :text_field, :password_field, :hidden_field
        #add_directive_object_and_method(d_arg, attr_info)
        add_directive_integer_option(d_arg, 'size', attr_info['size'])
        add_directive_integer_option(d_arg, 'maxsize', attr_info['maxsize'])

      when :file_field
        #add_directive_object_and_method(d_arg, attr_info)
        add_directive_integer_option(d_arg, 'size', attr_info['size'])

      when :link_to, :link_to_remote, :link_to_unless_current
        add_directive_content_as_arg(d_arg, arg.cont_stmts)

      when :anchor, :anchor_remote
        replace_elem = false

      when :mail_to
        add_directive_content_as_arg(d_arg, arg.cont_stmts)
        add_directive_attr_as_arg(d_arg, attr_info, 'href')
        d_arg.sub!(/\A\'mailto:/, "'")

      when :form_tag, :start_form_tag
        add_directive_attr_as_option(d_arg, attr_info, 'action')
        replace_elem = false

      when :text_area
        #add_directive_object_and_method(d_arg, attr_info)
        add_directive_integer_option(d_arg, 'cols', attr_info['cols'])
        add_directive_integer_option(d_arg, 'rows', attr_info['rows'])

      when :submit_tag
        add_directive_attr_as_arg(d_arg, attr_info, 'value')

      when :submit_to_remote
        add_directive_attr_as_arg(d_arg, attr_info, 'value')
        add_directive_attr_as_arg(d_arg, attr_info, 'name')

      when :radio_button
        #add_directive_object_and_method_and_value(d_arg, attr_info)

      when :check_box
        #add_directive_object_and_method(d_arg, attr_info)

      when :select, :collection_select, :country_select, :time_zone_select, :date_select, :datetime_select
        #add_directive_object_and_method(d_arg, attr_info)

      when :image_tag, :link_image_to, :link_to_image
        add_directive_attr_as_arg(d_arg, attr_info, 'src')
        add_directive_str_option(d_arg, 'alt', attr_info['alt'])

      else

      end #case

      ##
      print_directive(stmt_list, arg, replace_elem)

      return true      # everytime return true

    end


    protected


    def quote(str)
      return "'#{str.gsub(/['\\]/, '\\\\\&')}'"
    end


    def add_directive_object_and_method(d_arg, attr_info)
      if (/\A(\w+)\[(\w+)\]\z/ =~ attr_info['name']) || (/\A([a-zA-A0-9]+)_(\w+)\z/ =~ attr_info['id'])
        object = $1 ;  method = $2
        d_arg[0,0] = "#{quote(object)}, #{quote(method)}#{d_arg.empty? ? '' : ', '}"
      end
    end


    def add_directive_object_and_method_and_value(d_arg, attr_info)
      object = method = ''
      if (/\A(\w+)\[(\w+)\]\z/ =~ attr_info['name']) || (/\A([a-zA-z0-9]+)_(\w+?)_[a-zA-z0-9]+\z/ =~ attr_info['id'])
        object = $1 ;  method = $2
      end
      value = attr_info['value']
      d_arg[0,0] = "#{quote(object)}, #{quote(method)}, #{quote(value)}#{d_arg.empty? ? '' : ', '}"
    end


    def add_directive_attr_as_arg(d_arg, attr_info, attr_name)
      if (v = attr_info[attr_name]) && !v.empty?
        d_arg[0,0] = "#{quote(v)}#{d_arg.empty? ? '' : ', '}"
      end
    end


    def add_directive_attr_as_option(d_arg, attr_info, attr_name)
      if (s = attr_info[attr_name]) && !d_arg.index(attr_name)
        d_arg << ", " unless d_arg.empty?
        d_arg << "'#{attr_name}'=>#{quote(s)}"
      end
    end


    def add_directive_content_as_arg(d_arg, cont_stmts)
      if d_arg.empty? || d_arg[0] == ?: || d_arg[0] == ?{
        print_stmt = cont_stmts[0]
        label = print_stmt.args[0]
        d_arg[0,0] = "#{quote(label)}#{d_arg.empty? ? '' : ', '}" if label
      end
    end


    def add_directive_integer_option(directive_arg, attr_name, attr_value)
      if attr_value && attr_value =~ /\A\d+\z/
        directive_arg << ', ' unless directive_arg.empty?
        directive_arg << ":#{attr_name}=>#{attr_value.to_i}"
      end
    end


    def add_directive_expr_option(directive_arg, attr_name, attr_value)
      if attr_value
        directive_arg << ', ' unless directive_arg.empty?
        directive_arg << ":#{attr_name}=>#{attr_value}"
      end
    end


    def add_directive_str_option(directive_arg, attr_name, attr_value)
      if attr_value
        directive_arg << ', ' unless directive_arg.empty?
        directive_arg << ":#{attr_name}=>#{quote(attr_value.to_s)}"
      end
    end


    def print_directive(stmt_list, handler_arg, replace_elem=true)
      arg = handler_arg
      head_space = arg.stag_info.head_space
      tail_space = (arg.etag_info || arg.stag_info).tail_space
      pargs = []
      pargs << head_space if head_space
      pargs << NativeExpression.new("#{arg.directive_name} #{arg.directive_arg}")
      pargs << tail_space if tail_space
      stmt_list << PrintStatement.new(pargs)
      unless replace_elem
        stmt_list.concat(arg.cont_stmts)
        stmt_list << PrintStatement.new([arg.etag_info.tag_text])
      end
    end


  end #class
  Handler.register_class('rails', RailsHandler)



  ##
  ## translator for rails
  ##
  class RailsTranslator < BaseTranslator


    RAILS_EMBED_PATTERNS = [
      '<% ',    ' -%>',       # statement (chop newline)
      '<%= ',   ' %>',        # expression
      '<%=h ',  ' %>',        # escaped expression
    ]


    def initialize(properties={})
      super(RAILS_EMBED_PATTERNS, properties)
    end


  end
  Translator.register_class('rails', RailsTranslator)



end #module
