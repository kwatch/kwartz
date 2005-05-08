#!/usr/bin/ruby

###
### unit test for Defun
###
### $Id$
###

$: << 'lib'
$: << '../lib'
$: << 'test'

require 'test/unit'
require 'test/unit/ui/console/testrunner'
require 'assert-diff.rb'

require 'kwartz/defun.rb'
require 'kwartz/compiler.rb'
require 'kwartz/translator/eruby'
require 'kwartz/translator/php'


include Kwartz

##
## translator test
##
class DefunTest < Test::Unit::TestCase

   def setup
      @flag_suspend = false
   end

   
   
   @@pdata1 = <<END
Hello @{user}@!
<ul id="list">
  <dt id="value:word">..word..</dt>
  <dd id="value:desc">...description...</dd>
</ul>
END

   @@plogic1 = <<END
#list {
  plogic: {
    @stag;    // start tag
    foreach (item in item_list) {
      word = item[:word];
      desc = item[:desc];
      @cont;  // content
    }
    @etag;    // end tag
  }
}
END

   @@expected1_eruby = <<'END'
module Foo
  def self.view_foo(__args)
    user = __args[:user]
    item_list = __args[:item_list]
    return _view_foo( user,  item_list )
  end
  def self._view_foo( user,  item_list )
    _erbout = ''; _erbout << "Hello "; _erbout <<(( user ).to_s); _erbout << "!\n"
    _erbout << "<ul id=\"list\">\n"
     for item in item_list do 
       word = item[:word] 
       desc = item[:desc] 
    _erbout << "  <dt>"; _erbout <<(( word ).to_s); _erbout << "</dt>\n"
    _erbout << "  <dd>"; _erbout <<(( desc ).to_s); _erbout << "</dd>\n"
     end 
    _erbout << "</ul>\n"
    _erbout
  end
end
END

   @@expected1_php = <<'END'
<?php
class Foo
    function view_foo($__args) {
        $user = $__args['user']
        $item_list = $__args['item_list']
        return _view_foo($user, $item_list)
    }
    function _view_foo($user, $item_list) {
        ob_start();
?>Hello <?php echo $user; ?>!
<ul id="list">
<?php foreach ($item_list as $item) { ?>
<?php   $word = $item['word']; ?>
<?php   $desc = $item['desc']; ?>
  <dt><?php echo $word; ?></dt>
  <dd><?php echo $desc; ?></dd>
<?php } ?>
</ul>
<?php
        $__s = ob_get_contents();
        ob_end_clean();
        return $__s;
    }
}
?>
END
   @@expected1_php.gsub!(/\n\z/, '')

   @@context1 = {
      :class     => "Foo",
      :function  => "view_foo",
      :arguments => " user,  item_list ",
   }

   def _test(expected, context, lang, pdata=@@pdata1, plogic=@@plogic1)
      compiler = Compiler.new
      code = compiler.compile(pdata, plogic, lang)
      defun = Defun.create(lang)
      func_code = defun.generate(code, context)
      assert_equal_with_diff(expected, func_code)
   end


   ## ----------------------------------------


   def test_defun_eruby1	# with class(module)
      lang     = "eruby"
      expected = @@expected1_eruby.dup
      context  = @@context1.dup
      _test(expected, context, lang)
   end


   def test_defun_php1		# with class(module)
      lang = "php"
      expected = @@expected1_php.dup
      context = @@context1.dup
      _test(expected, context, lang)
   end


   def test_defun_eruby2	# without class(module)
      lang = "eruby"
      expected = @@expected1_eruby.dup
      expected.gsub!(/^module.*\n/, '')
      expected.gsub!(/^end.*\n/, '')
      expected.gsub!(/self\./, '')
      context = @@context1.dup
      context.delete(:class)
      _test(expected, context, lang)
   end


   def test_defun_php2		# without class(module)
      lang = "php"
      expected = @@expected1_php.dup
      context = @@context1.dup
      _test(expected, context, lang)
   end


end



##
## main
##
if $0 == __FILE__
    Test::Unit::UI::Console::TestRunner.run(DefunTest)
end
