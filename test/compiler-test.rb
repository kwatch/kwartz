#!/usr/bin/ruby

###
### unit test for Compiler
###
### $Id$
###

$: << 'lib'
$: << '../lib'
$: << 'test'

require 'test/unit'
require 'test/unit/ui/console/testrunner'
require 'assert-diff.rb'
require 'kwartz/compiler'
require 'kwartz/translator/eruby'
require 'kwartz/translator/php'
require 'kwartz/translator/jstl'


class CompilerTest < Test::Unit::TestCase
   def setup
      @flag_suspend = false
   end


   def _test(pdata_str, plogic_str, expected, properties={}, lang=nil)
      if !lang
         s = caller().first
         s =~ /in `(.*)'/          #'
         testmethod = $1
         if testmethod =~ /_(eruby|php|jstl11|jstl10)$/
            lang = $1
         else
            raise "invalid testmethod name (='#{testmethod}')"
         end
      end
      return if @flag_suspend
      compiler = Kwartz::Compiler.new(properties)
      actual = compiler.compile(pdata_str, plogic_str, lang)
      assert_equal_with_diff(expected, actual)
   end



   ## -------------------- marking

   @@pdata1 = <<'END'
<table>
 <tr id="mark:user_list">
  <td id="value:user.name">foo</td>
 </tr>
</table>
END
   @@plogic1 = <<'END'
#user_list {
	plogic: {
	  foreach(user in user_list) {
	    @stag;
	    @cont;
	    @etag;
	  }
	}
}
END
   def test_compile1_eruby	# marking
      expected = <<'END'
<table>
<% for user in user_list do %>
 <tr>
  <td><%= user.name %></td>
 </tr>
<% end %>
</table>
END
      _test(@@pdata1, @@plogic1, expected)
   end

   def test_compile1_php	# marking
      expected = <<'END'
<table>
<?php foreach ($user_list as $user) { ?>
 <tr>
  <td><?php echo $user->name; ?></td>
 </tr>
<?php } ?>
</table>
END
      _test(@@pdata1, @@plogic1, expected)
   end

   def test_compile1_jstl11	# marking
      expected = <<'END'
<table>
<c:forEach var="user" items="${user_list}">
 <tr>
  <td><c:out value="${user.name}" escapeXml="false"/></td>
 </tr>
</c:forEach>
</table>
END
      _test(@@pdata1, @@plogic1, expected)
      _test(@@pdata1, @@plogic1, expected, {}, 'jstl10')
   end



   ## -------------------- nested marking
   @@pdata2 = <<'END'
<table>
 <tr id="mark:user_list">
  <td id="mark:user">foo</td>
 </tr>
</table>
END
   @@plogic2 = <<'END'
#user {
	value: user[:name];
}
#user_list {
	plogic: {
	  foreach(user in user_list) {
	    @stag;
	    @cont;
	    @etag;
	  }
	}
}
END
   def test_compile2_eruby	# nested marking
      expected = <<'END'
<table>
<% for user in user_list do %>
 <tr>
  <td><%= user[:name] %></td>
 </tr>
<% end %>
</table>
END
      _test(@@pdata2, @@plogic2, expected)
   end

   def test_compile2_php	# nested marking
      expected = <<'END'
<table>
<?php foreach ($user_list as $user) { ?>
 <tr>
  <td><?php echo $user['name']; ?></td>
 </tr>
<?php } ?>
</table>
END
      _test(@@pdata2, @@plogic2, expected)
   end

   def test_compile2_jstl11	# nested marking
      expected = <<'END'
<table>
<c:forEach var="user" items="${user_list}">
 <tr>
  <td><c:out value="${user['name']}" escapeXml="false"/></td>
 </tr>
</c:forEach>
</table>
END
      _test(@@pdata2, @@plogic2, expected)
      _test(@@pdata2, @@plogic2, expected, {}, 'jstl10')
   end



   ## -------------------- remove: "id";
   @@pdata3 = <<'END'
<table>
 <tr id="user_list">
  <td id="user">foo</td>
 </tr>
</table>
END
   @@plogic3 = <<'END'
#user {
	value: user.name;
	remove: "id";
}
#user_list {
	remove: "id";
	plogic: {
	  foreach(user in user_list) {
	    @stag;
	    @cont;
	    @etag;
	  }
	}
}
END
   def test_compile3_eruby	# remove: "id";
      expected = <<'END'
<table>
<% for user in user_list do %>
 <tr>
  <td><%= user.name %></td>
 </tr>
<% end %>
</table>
END
      _test(@@pdata3, @@plogic3, expected)
   end

   def test_compile3_php	# remove: "id";
      expected = <<'END'
<table>
<?php foreach ($user_list as $user) { ?>
 <tr>
  <td><?php echo $user->name; ?></td>
 </tr>
<?php } ?>
</table>
END
      _test(@@pdata3, @@plogic3, expected)
   end

   def test_compile3_jstl11	# remove: "id";
      expected = <<'END'
<table>
<c:forEach var="user" items="${user_list}">
 <tr>
  <td><c:out value="${user.name}" escapeXml="false"/></td>
 </tr>
</c:forEach>
</table>
END
      _test(@@pdata3, @@plogic3, expected)
      _test(@@pdata3, @@plogic3, expected, {}, 'jstl10')
   end



   ## -------------------- attr
   @@pdata4 = <<'END'
<table id="table">
 <tr id="user_list">
  <td id="name">foo</td>
  <td id="email">foo@email</td>
 </tr>
</table>
END
   @@plogic4 = <<'END'
#table {
	attr: "summary" title;
}
#name {
	remove: "id";
	value: user['name'];
}
#email {
	remove: "id";
	value: user['email'];
}
#user_list {
	remove: "id";
        attr: "bgcolor" color;
	plogic: {
          i = 0;
	  foreach(user in user_list) {
            i += 1;
            if (i % 2 == 0) color = '#FFCCCC';
            else            color = '#CCCCFF';
	    @stag;
	    @cont;
	    @etag;
	  }
	}
}
END
   def test_compile4_eruby
      expected = <<'END'
<table id="table" summary="<%= title %>">
<% i = 0 %>
<% for user in user_list do %>
<%   i += 1 %>
<%   if i % 2 == 0 then %>
<%     color = "#FFCCCC" %>
<%   else %>
<%     color = "#CCCCFF" %>
<%   end %>
 <tr bgcolor="<%= color %>">
  <td><%= user["name"] %></td>
  <td><%= user["email"] %></td>
 </tr>
<% end %>
</table>
END
      _test(@@pdata4, @@plogic4, expected)
   end

   def test_compile4_php
      expected = <<'END'
<table id="table" summary="<?php echo $title; ?>">
<?php $i = 0; ?>
<?php foreach ($user_list as $user) { ?>
<?php   $i += 1; ?>
<?php   if ($i % 2 == 0) { ?>
<?php     $color = "#FFCCCC"; ?>
<?php   } else { ?>
<?php     $color = "#CCCCFF"; ?>
<?php   } ?>
 <tr bgcolor="<?php echo $color; ?>">
  <td><?php echo $user["name"]; ?></td>
  <td><?php echo $user["email"]; ?></td>
 </tr>
<?php } ?>
</table>
END
      _test(@@pdata4, @@plogic4, expected)
   end

   def test_compile4_jstl11
      expected = <<'END'
<table id="table" summary="<c:out value="${title}" escapeXml="false"/>">
<c:set var="i" value="0"/>
<c:forEach var="user" items="${user_list}">
  <c:set var="i" value="${i + 1}"/>
  <c:choose><c:when test="${i % 2 eq 0}">
    <c:set var="color" value="#FFCCCC"/>
  </c:when><c:otherwise>
    <c:set var="color" value="#CCCCFF"/>
  </c:otherwise></c:choose>
 <tr bgcolor="<c:out value="${color}" escapeXml="false"/>">
  <td><c:out value="${user["name"]}" escapeXml="false"/></td>
  <td><c:out value="${user["email"]}" escapeXml="false"/></td>
 </tr>
</c:forEach>
</table>
END
      _test(@@pdata4, @@plogic4, expected)
      _test(@@pdata4, @@plogic4, expected, {}, 'jstl10')
   end



   ## -------------------- empty tag
   @@pdata5 = <<'END'
<input type="text" size="30" name="username" id="username" />
END
   @@plogic5 = <<'END'
#username {
	attr: "value" user.name;
}
END

   def test_compile5_eruby	# empty tag
      expected = <<'END'
<input type="text" size="30" name="username" id="username" value="<%= user.name %>" />
END
      _test(@@pdata5, @@plogic5, expected)
   end

   def test_compile5_php	# empty tag
      expected = <<'END'
<input type="text" size="30" name="username" id="username" value="<?php echo $user->name; ?>" />
END
      _test(@@pdata5, @@plogic5, expected)
   end

   def test_compile5_jstl11	# empty tag
      expected = <<'END'
<input type="text" size="30" name="username" id="username" value="<c:out value="${user.name}" escapeXml="false"/>" />
END
      _test(@@pdata5, @@plogic5, expected)
      _test(@@pdata5, @@plogic5, expected, {}, 'jstl10')
   end



   ## -------------------- empty tag and append
   @@pdata6 = <<'END'
checkbox:  <input type="checkbox" size="30" name="chkbox" id="chkbox" checked="checked"/>
END
   @@plogic6 = <<'END'
#chkbox {
	remove: "checked";
	append: flag ? ' checked="checked"' : '';
}
END

   def test_compile6_eruby	# empty tag and append
      expected = <<'END'
checkbox:  <input type="checkbox" size="30" name="chkbox" id="chkbox"<%= flag ? " checked=\"checked\"" : "" %> />
END
      _test(@@pdata6, @@plogic6, expected)
   end

   def test_compile6_php	# empty tag and append
      expected = <<'END'
checkbox:  <input type="checkbox" size="30" name="chkbox" id="chkbox"<?php echo $flag ? " checked=\"checked\"" : ""; ?> />
END
      _test(@@pdata6, @@plogic6, expected)
   end

   def test_compile6_jstl11	# empty tag and append
      expected = <<'END'
checkbox:  <input type="checkbox" size="30" name="chkbox" id="chkbox"<c:out value="${flag ? " checked=\"checked\"" : ""}" escapeXml="false"/> />
END
      _test(@@pdata6, @@plogic6, expected)
   end

   def test_compile6_jstl10	# empty tag and append
      expected = <<'END'
checkbox:<c:choose><c:when test="${flag}">
  <input type="checkbox" size="30" name="chkbox" id="chkbox" checked="checked" />
</c:when><c:otherwise>
  <input type="checkbox" size="30" name="chkbox" id="chkbox" />
</c:otherwise></c:choose>
END
      _test(@@pdata6, @@plogic6, expected)
   end


end


class SpanTest < Test::Unit::TestCase

   def _test(pdata, plogic, expected, properties={})
      compiler = Kwartz::Compiler.new(properties)
      actual = compiler.compile(pdata, plogic, 'eruby')
      assert_equal_with_diff(expected, actual)
   end
   
   ## ----------------------------------------
   def test_span1
      pdata = <<'END'
  <div id="foreach:item:list">
    <span id="value:item">foo</span>
  </div>
END
      expected = <<'END'
<% for item in list do %>
  <div>
    <%= item %>
  </div>
<% end %>
END
      _test(pdata, '', expected)
   end

   
   ## ----------------------------------------
   def test_span2
      pdata = <<'END'
  <span id="foreach:item:list">
    <div id="value:item">foo</div>
  </span>
END
      expected = <<'END'
<% for item in list do %>
    <div><%= item %></div>
<% end %>
END
      _test(pdata, '', expected)
   end


   ## ----------------------------------------
   def test_span3
      pdata = <<'END'
  <div id="mark:list">
    <span id="mark:item">foo</span>
  </div>
END
      plogic = <<'END'
#list {
	plogic: {
	    @stag;
	    foreach (item in list) {
		@cont;
	    }
	    @etag;
	}
}

#item {
	value: item;
}
END
      expected = <<'END'
  <div>
<% for item in list do %>
    <%= item %>
<% end %>
  </div>
END
      _test(pdata, plogic, expected)
   end

   
   ## ----------------------------------------
   def test_span4
      pdata = <<'END'
  <span id="mark:list">
    <div id="mark:item">foo</div>
  </span>
END
      plogic = <<'END'
#list {
	plogic: {
	    foreach (item in list) {
		@stag;
		@cont;
		@etag;
	    }
	}
}

#item {
	value: item;
}
END
      expected = <<'END'
<% for item in list do %>
    <div><%= item %></div>
<% end %>
END
      _test(pdata, plogic, expected)
   end



   ## ----------------------------------------
   def test_span4	# empty tag, set stmt
      pdata = <<'END'
  <span id="set:item=list">
    <div id="mark:item">foo</div>
    <span id="set:a=b"/>
  </span>
END
      plogic = ''
      expected = <<'END'
<% item = list %>
    <div>foo</div>
<% a = b %>
END
      _test(pdata, plogic, expected)
   end


   ## ----------------------------------------
   def test_span5	# undelete span tag if other attr is exist
      pdata = <<'END'
  <span id="loop:item=list" class="list">
    <span id="item">foo</span>
  </span>
END
      plogic = ''
      expected = <<'END'
  <span class="list">
<% for item in list do %>
    <span id="item">foo</span>
<% end %>
  </span>
END
      _test(pdata, plogic, expected)
   end


   ## ----------------------------------------
   def test_span6	# uppercase span tag
      pdata = <<'END'
  <SPAN id="loop:item=list">
    <SPAN id="value:item">foo</SPAN>
  </SPAN>
END
      plogic = ''
      expected = <<'END'
  <SPAN>
<% for item in list do %>
    <SPAN><%= item %></SPAN>
<% end %>
  </SPAN>
END
      _test(pdata, plogic, expected)
   end

   
end


if $0 == __FILE__
    Test::Unit::UI::Console::TestRunner.run(CompilerTest)
    Test::Unit::UI::Console::TestRunner.run(SpanTest)
end
