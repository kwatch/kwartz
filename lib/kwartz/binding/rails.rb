###
### $Rev$
### $Release$
### $Copyright$
###

require 'kwartz/converter'
#require 'kwartz/translator'
require 'kwartz/binding/erb'



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
  ##  <input type="text" size="10" maxsize="20" title="text_field 'user', 'name'">
  ##   => <%= text_field 'user', 'name', 'size'=>10, 'maxsize'=>20 %>
  ##  <input type="text" name="user[name]" title="text_field :size=10">
  ##   => <%= text_field "user", "name", :size=>10 %>
  ##  <input type="text" id="user_name" size="10" title="text_field">
  ##   => <%= text_field "user", "name", 'size'=>10 %>
  ##
  ##  ## link_to, link_to_remote, button_to
  ##  <a href="#" title="link_to :action=>'list'">Show list</a>
  ##   => <%= link_to "Show list", 'action'=>'show', 'id'=>@user.id %>
  ##  <a href="#" title="link_to label, :action=>'list'">Show list</a>
  ##   => <%= link_to label, 'action'=>'show', 'id'=>@user.id %>
  ##
  ##  ## form_tag
  ##  <form action="show" title="form_tag"> ... </form>
  ##   => <%= form_tag 'action'=>"show" %> ... </form>
  ##
  ##  ## submit_tag
  ##  <input type="submit" value="OK" title="submit_tag">
  ##   => <%= submit_tag "OK" %>
  ##
  ##  ## text_area
  ##  <textarea cols="30" rows="3" id="user_desc" title="text_area"></textarea>
  ##   => <%= text_area "user", "desc", 'cols'=>30, 'rows'=>3 %>
  ##  <textarea cols="30" rows="3" name="user[desc]" title="text_area"></textarea>
  ##   => <%= text_area "user", "desc", 'cols'=>30, 'rows'=>3 %>
  ##
  ##  ## hidden_field
  ##  <input type="hidden" id="user_id" title="hidden_field">
  ##   => <%= hidden_field "user", "id" %>
  ##  <input type="hidden" name="user[id]" title="hidden_field">
  ##   => <%= hidden_field "user", "id" %>
  ##
  ##  ## check_box
  ##  <input type="checkbox" id="user_chk1" title="check_box">
  ##   => <%= check_box "user", "chk1" %>
  ##  <input type="checkbox" name="user[chk2]" title="check_box">
  ##   => <%= check_box "user", "chk2" %>
  ##
  ##  ## radio_button
  ##  <input type="radio" id="user_radio" value="val1" title="radio_button">
  ##   => <%= radio_button "user", "radio", "val1" %>
  ##  <input type="radio" name="user[radio]" value="val2" title="radio_button">
  ##   => <%= radio_button "user", "radio", "val2" %>
  ##
  class RailsHandler < ErbHandler


    ##
    ## handle directives for rails.
    ##
    ## everytime return true whenever directive name is unknown.
    ##
    def handle(directive_name, directive_arg, directive_str, stag_info, etag_info, cont_stmts, attr_info, append_exprs, stmt_list)
      ret = super
      return ret if ret
      
      d_name = directive_name
      d_arg  = directive_arg
      d_str  = directive_str

      case directive_name

      when :text_field, :password_field, :file_field
        add_directive_object_and_method(d_arg, attr_info)
        #if (v = attr_info['value']) && v[0] == ?@
        #  add_directive_expr_option(d_arg, 'value', v)
        #end
        add_directive_integer_option(d_arg, 'size', attr_info['size'])
        add_directive_integer_option(d_arg, 'maxsize', attr_info['maxsize'])
        print_directive(d_name, d_arg, stag_info, etag_info, cont_stmts, attr_info, stmt_list)

      when :link_to, :link_to_remote, :button_to
        add_directive_content_as_arg(d_arg, cont_stmts)
        print_directive(d_name, d_arg, stag_info, etag_info, cont_stmts, attr_info, stmt_list)

      when :form_tag
        add_directive_attr_as_option(d_arg, attr_info, 'action')
        print_directive(d_name, d_arg, stag_info, etag_info, cont_stmts, attr_info, stmt_list, false)

      when :text_area
        add_directive_object_and_method(d_arg, attr_info)
        add_directive_integer_option(d_arg, 'cols', attr_info['cols'])
        add_directive_integer_option(d_arg, 'rows', attr_info['rows'])
        print_directive(d_name, d_arg, stag_info, etag_info, cont_stmts, attr_info, stmt_list)

      when :submit_tag
        add_directive_attr_as_arg(d_arg, attr_info, 'value')
        print_directive(d_name, d_arg, stag_info, etag_info, cont_stmts, attr_info, stmt_list)

      when :hidden_field
        add_directive_object_and_method(d_arg, attr_info)
        print_directive(d_name, d_arg, stag_info, etag_info, cont_stmts, attr_info, stmt_list)

      when :check_box
        add_directive_object_and_method(d_arg, attr_info)
        print_directive(d_name, d_arg, stag_info, etag_info, cont_stmts, attr_info, stmt_list)

      when :radio_button
        add_directive_object_and_method_and_value(d_arg, attr_info)
        print_directive(d_name, d_arg, stag_info, etag_info, cont_stmts, attr_info, stmt_list)
        
      else
        print_directive(d_name, d_arg, stag_info, etag_info, cont_stmts, attr_info, stmt_list)

      end #case
      return true      # everytime return true
      
    end


    protected


    def add_directive_object_and_method(d_arg, attr_info)
      if d_arg.empty? || d_arg[0] == ?: || d_arg[0] == ?{
        if (/\A(\w+)\[(.+)\]\z/ =~ attr_info['name']) || (/\A([a-zA-z0-9]+)_(.+)\z/ =~ attr_info['id'])
          object = $1 ;  method = $2
          d_arg[0,0] = "#{object.dump}, #{method.dump}#{d_arg.empty? ? '' : ', '}"
        end
      end
    end


    def add_directive_object_and_method_and_value(d_arg, attr_info)
      if d_arg.empty? || d_arg[0] == ?: || d_arg[0] == ?{
        object = method = ''
        if (/\A(\w+)\[(.+)\]\z/ =~ attr_info['name']) || (/\A([a-zA-z0-9]+)_(.+)\z/ =~ attr_info['id'])
          object = $1 ;  method = $2
        end
        value = attr_info['value']
        d_arg[0,0] = "#{object.dump}, #{method.dump}, #{value.dump}#{d_arg.empty? ? '' : ', '}"
      end
    end


    def add_directive_attr_as_arg(d_arg, attr_info, attr_name)
      if (v = attr_info[attr_name]) && !v.empty?
        if d_arg.empty? || d_arg[0] == ?: || d_arg[0] == ?{
          d_arg[0,0] = "#{v.dump}#{d_arg.empty? ? '' : ', '}"
        end
      end
    end


    def add_directive_attr_as_option(d_arg, attr_info, attr_name)
      if (s = attr_info[attr_name]) && !d_arg.index(attr_name)
        d_arg << ", " unless d_arg.empty?
        d_arg << "'#{attr_name}'=>#{s.dump}"
      end
    end

    
    def add_directive_content_as_arg(d_arg, cont_stmts)
      if d_arg.empty? || d_arg[0] == ?: || d_arg[0] == ?{
        print_stmt = cont_stmts[0]
        label = print_stmt.args[0]
        d_arg[0,0] = "#{label.dump}#{d_arg.empty? ? '' : ', '}" if label
      end
    end


    def add_directive_integer_option(directive_arg, attr_name, attr_value)
      if attr_value && attr_value =~ /\A\d+\z/
        directive_arg << ', ' unless directive_arg.empty?
        directive_arg << "'#{attr_name}'=>#{attr_value.to_i}"
      end
    end


    def add_directive_expr_option(directive_arg, attr_name, attr_value)
      if attr_value
        directive_arg << ', ' unless directive_arg.empty?
        directive_arg << "'#{attr_name}'=>#{attr_value}"
      end
    end


    def add_directive_str_option(directive_arg, attr_name, attr_value)
      if attr_value
        directive_arg << ', ' unless directive_arg.empty?
        directive_arg << "'#{attr_name}'=>#{attr_value.to_s.dump}"
      end
    end


    def print_directive(d_name, d_arg, stag_info, etag_info, cont_stmts, attr_info, stmt_list, replace_elem=true)
      head_space = stag_info.head_space
      tail_space = (etag_info || stag_info).tail_space
      args = []
      args << head_space if head_space
      args << NativeExpression.new("#{d_name} #{d_arg}")
      args << tail_space if tail_space
      stmt_list << PrintStatement.new(args)
      unless replace_elem
        stmt_list.concat(cont_stmts)
        stmt_list << PrintStatement.new([etag_info.tag_text])
      end
    end


  end #class



  ##
  ## translator for rails
  ##
  class RailsTranslator < ErbTranslator

    # nothing

  end



end #module
