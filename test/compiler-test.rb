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
require 'kwartz/translator/erb'
require 'kwartz/translator/php'
require 'kwartz/translator/jstl'
require 'kwartz/translator/velocity'


class CompilerTest < Test::Unit::TestCase
   def setup
      @flag_suspend = false
   end


   def _test(pdata_str, plogic_str, expected, properties={}, lang=nil)
      if !lang
         s = caller().first
         s =~ /in `(.*)'/          #'
         testmethod = $1
         if testmethod =~ /_(eruby|php|jstl11|jstl10|velocity)$/
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



   ## -------------------- attrs
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
	attrs: "summary" title;
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
        attrs: "bgcolor" color;
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
   def test_compile4_eruby	# attrs
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

   def test_compile4_php	# attrs
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

   def test_compile4_jstl11	# attrs
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
  <td><c:out value="${user['name']}" escapeXml="false"/></td>
  <td><c:out value="${user['email']}" escapeXml="false"/></td>
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
	attrs: "value" user.name;
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
	//append: flag ? ' checked="checked"' : '';
	append: C(flag);
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
checkbox:  <input type="checkbox" size="30" name="chkbox" id="chkbox"<c:out value="${flag ? ' checked="checked"' : ''}" escapeXml="false"/> />
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



   ## -------------------- newline
   @@pdata7 = <<'END'
<tr kw:d="mark:list">
  <td kw:d="value:item">foo</td>
</tr>
END
   @@pdata7.gsub!(/\n/, "\r\n")
   @@plogic7 = <<'END'
#list {
   plogic: {
      foreach (item in list) {
         @stag;
         @cont;
         @etag;
      }
   }
}
END

   def test_compile7_eruby	# newline
      expected = <<END
<% for item in list do %>\r
<tr>\r
  <td><%= item %></td>\r
</tr>\r
<% end %>\r
END
      _test(@@pdata7, @@plogic7, expected)
   end

   def test_compile7_php	# newline
      expected = <<END
<?php foreach ($list as $item) { ?>\r
<tr>\r
  <td><?php echo $item; ?></td>\r
</tr>\r
<?php } ?>\r
END
      _test(@@pdata7, @@plogic7, expected)
   end

   def test_compile7_jstl11	# newline
      expected = <<END
<c:forEach var="item" items="${list}">\r
<tr>\r
  <td><c:out value="${item}" escapeXml="false"/></td>\r
</tr>\r
</c:forEach>\r
END
      _test(@@pdata7, @@plogic7, expected)
   end

   def test_compile7_jstl10	# newline
      expected = <<END
<c:forEach var="item" items="${list}">\r
<tr>\r
  <td><c:out value="${item}" escapeXml="false"/></td>\r
</tr>\r
</c:forEach>\r
END
      _test(@@pdata7, @@plogic7, expected)
   end



   ## -------------------- #DOCUMENT

   @@pdata8 = <<'END'
<tr kw:d="mark:list">
  <td kw:d="value:item">foo</td>
</tr>
END
   @@plogic8 = <<'END'
#DOCUMENT {
   begin: {
      print("<!-- document -->\n");
      list = context['list'];
   }
   end : {
      print('<!-- /document -->', "\n");
   }
   global: context, args;
}
#list {
   plogic: {
      foreach (item in list) {
         @stag;
         @cont;
         @etag;
      }
   }
}
END

   def test_compile8_eruby	#DOCUMENT
      expected = <<END
<!-- document -->
<% list = context["list"] %>
<% for item in list do %>
<tr>
  <td><%= item %></td>
</tr>
<% end %>
<!-- /document -->
END
      _test(@@pdata8, @@plogic8, expected)
   end

   def test_compile8_php	#DOCUMENT
      expected = <<END
<!-- document -->
<?php $list = $context["list"]; ?>
<?php foreach ($list as $item) { ?>
<tr>
  <td><?php echo $item; ?></td>
</tr>
<?php } ?>
<!-- /document -->
END
      _test(@@pdata8, @@plogic8, expected)
   end

   def test_compile8_jstl11	#DOCUMENT
      expected = <<END
<!-- document -->
<c:set var="list" value="${context['list']}"/>
<c:forEach var="item" items="${list}">
<tr>
  <td><c:out value="${item}" escapeXml="false"/></td>
</tr>
</c:forEach>
<!-- /document -->
END
      _test(@@pdata8, @@plogic8, expected)
   end

   def test_compile8_jstl10	#DOCUMENT
      expected = <<END
<!-- document -->
<c:set var="list" value="${context['list']}"/>
<c:forEach var="item" items="${list}">
<tr>
  <td><c:out value="${item}" escapeXml="false"/></td>
</tr>
</c:forEach>
<!-- /document -->
END
      _test(@@pdata8, @@plogic8, expected)
   end



   ## -------------------- require:

   @@pdata9 = <<'END'
<tr kw:d="mark:list">
  <td kw:d="mark:item">foo</td>
</tr>
END
   @@plogic9 = <<'END'
#DOCUMENT {
   require: 'test-plogic9a.plogic', 'test-plogic9b';
}
#item {
   value: item['user'];
}
END

   def test_compile9_eruby	# require:
      plogic9a = <<'END'
#list {
   plogic: {
      foreach (item in list) {
         @stag;
         @cont;
         @etag;
      }
   }
}
END
      plogic9b = <<'END'
#item {
   value: item.val;
}
END
      File.open('test-plogic9a.plogic', 'w') { |f| f.write(plogic9a) }
      File.open('test-plogic9b.plogic', 'w') { |f| f.write(plogic9b) }
      expected = <<END
<% for item in list do %>
<tr>
  <td><%= item["user"] %></td>
</tr>
<% end %>
END
      _test(@@pdata9, @@plogic9, expected)
      File.unlink('test-plogic9a.plogic')
      File.unlink('test-plogic9b.plogic')
   end



   ## -------------------- Kwartz::Config::EMPTY_TAGS

   @@pdata10 = <<'END'
<meta http-equiv="Content-Type" content="text/html; charset=UTF8" id="mark:meta">
<form>
 <label for="username">User Name:</label>
 <input type="text" name="username" id="username">
</form>
<img id="mark:image">
END
   @@plogic10 = <<'END'
#username {
        attrs: "value" username, "size" 60;
}

#image {
    attrs: "src" image.url, "alt" image.desc;
    plogic: {
	foreach (image in image_list) {
	    @stag;
	    @cont;
	    @etag;
	}
    }
}
END

   def test_compile10_eruby	# Kwartz::Config::EMPTY_TAGS
      expected = <<END
<meta http-equiv="Content-Type" content="text/html; charset=UTF8">
<form>
 <label for="username">User Name:</label>
 <input type="text" name="username" id="username" value="<%= username %>" size="60">
</form>
<% for image in image_list do %>
<img src="<%= image.url %>" alt="<%= image.desc %>">
<% end %>
END
      _test(@@pdata10, @@plogic10, expected)
   end



   ## -------------------- Rawcode

   @@pdata11 = <<'END'
<dl id="mark:list">
 <dt id="value:key">key</dt><dd id="value:value">value</dd>
</dl>
END

   def test_compile11_eruby	# rawcode
      plogic = <<'END'
#list {
    plogic: {
      @stag;
      <% ENV.each { |key, value| %>
        @cont;
      <% } %>
      @etag;
    }
}
END
      expected = <<'END'
<dl>
<% ENV.each { |key, value| %>
 <dt><%= key %></dt><dd><%= value %></dd>
<% } %>
</dl>
END
      _test(@@pdata11, plogic, expected)
   end

   def test_compile11_php	# rawcode
      plogic = <<'END'
#list {
    plogic: {
      @stag;
      <?php foreach (ENV as $key => $value) { ?>
        @cont;
      <?php } ?>
      @etag;
    }
}
END
      expected = <<'END'
<dl>
<?php foreach (ENV as $key => $value) { ?>
 <dt><?php echo $key; ?></dt><dd><?php echo $value; ?></dd>
<?php } ?>
</dl>
END
      _test(@@pdata11, plogic, expected)
   end

   def test_compile11_jstl11	# rawcode
      plogic = <<'END'
#list {
    plogic: {
      @stag;
      <% for (Iterator it = hash.getKeys().iterator(); it.hasNext(); ) { %>
      <%   Object key = it.next(); %>
      <%   Object value = hash.get(key); %>
        @cont;
      <% } %>
      @etag;
    }
}
END
      expected = <<'END'
<dl>
<% for (Iterator it = hash.getKeys().iterator(); it.hasNext(); ) { %>
<%   Object key = it.next(); %>
<%   Object value = hash.get(key); %>
 <dt><c:out value="${key}" escapeXml="false"/></dt><dd><c:out value="${value}" escapeXml="false"/></dd>
<% } %>
</dl>
END
      _test(@@pdata11, plogic, expected)
   end


   ## -------------------- rename local var

   @@pdata12 = <<'END'
<table>
  <tr id="mark:items" class="@{klass}@">
    <td id="mark:item">foo</td>
  </tr>
</table>
END
   @@plogic12 = <<'END'
#items {
  plogic: {
    i = 0;
    foreach (item in list) {
      i += 1;
      klass = i % 2 == 0 ? 'even' : 'odd';
      @stag;
      @cont;
      @etag;
    }
  }
}
#item {
  value: item[klass];
}
END

   def test_compile12_eruby	# rename local var
      expected = <<'END'
<table>
<% _i = 0 %>
<% for _item in list do %>
<%   _i += 1 %>
<%   _klass = _i % 2 == 0 ? "even" : "odd" %>
  <tr class="<%= _klass %>">
    <td><%= _item[_klass] %></td>
  </tr>
<% end %>
</table>
END
      _test(@@pdata12, @@plogic12, expected, { :localvar_prefix => '_' })
   end

   def test_compile12_php	# rename local var
      expected = <<'END'
<table>
<?php $_i = 0; ?>
<?php foreach ($list as $_item) { ?>
<?php   $_i += 1; ?>
<?php   $_klass = $_i % 2 == 0 ? "even" : "odd"; ?>
  <tr class="<?php echo $_klass; ?>">
    <td><?php echo $_item[$_klass]; ?></td>
  </tr>
<?php } ?>
</table>
END
      _test(@@pdata12, @@plogic12, expected, { :localvar_prefix => '_' })
   end

   def test_compile12_jstl11	# rename local var
      expected = <<'END'
<table>
<c:set var="_i" value="0"/>
<c:forEach var="_item" items="${list}">
  <c:set var="_i" value="${_i + 1}"/>
  <c:set var="_klass" value="${_i % 2 eq 0 ? 'even' : 'odd'}"/>
  <tr class="<c:out value="${_klass}" escapeXml="false"/>">
    <td><c:out value="${_item[_klass]}" escapeXml="false"/></td>
  </tr>
</c:forEach>
</table>
END
      _test(@@pdata12, @@plogic12, expected, { :localvar_prefix => '_' })
   end

   def test_compile12_jstl10	# rename local var
      expected = <<'END'
<table>
<c:set var="_i" value="0"/>
<c:forEach var="_item" items="${list}">
  <c:set var="_i" value="${_i + 1}"/>
  <c:choose><c:when test="${_i % 2 eq 0}">
    <c:set var="_klass" value="even"/>
  </c:when><c:otherwise>
    <c:set var="_klass" value="odd"/>
  </c:otherwise></c:choose>
  <tr class="<c:out value="${_klass}" escapeXml="false"/>">
    <td><c:out value="${_item[_klass]}" escapeXml="false"/></td>
  </tr>
</c:forEach>
</table>
END
      _test(@@pdata12, @@plogic12, expected, { :localvar_prefix => '_' })
   end

   def test_compile12_velocity	# rename local var
      expected = <<'END'
<table>
#set($_i = 0)
#foreach($_item in $list)
  #set($_i = $_i + 1)
  #if($_i % 2 == 0)
    #set($_klass = "even")
  #else
    #set($_klass = "odd")
  #end
  <tr class="$!{_klass}">
    <td>$!{_item[$_klass]}</td>
  </tr>
#end
</table>
END
      _test(@@pdata12, @@plogic12, expected, { :localvar_prefix => '_' })
   end



   ## -------------------- rename global var

   @@pdata13 = <<'END'
Hello @{user[name]}@!
<table>
  <tr id="mark:items" class="@{klass}@">
    <td id="mark:item">foo</td>
  </tr>
</table>
END
   @@plogic13 = <<'END'
#items {
  plogic: {
    i = 0;
    foreach (item in list) {
      i += 1;
      klass = i % 2 == 0 ? 'even' : 'odd';
      @stag;
      @cont;
      @etag;
    }
  }
}
#item {
  value: item[klass];
}
END

   def test_compile13_eruby	# rename global var
      expected = <<'END'
Hello <%= @user[@name] %>!
<table>
<% i = 0 %>
<% for item in @list do %>
<%   i += 1 %>
<%   klass = i % 2 == 0 ? "even" : "odd" %>
  <tr class="<%= klass %>">
    <td><%= item[klass] %></td>
  </tr>
<% end %>
</table>
END
      _test(@@pdata13, @@plogic13, expected, { :globalvar_prefix => '@' })
   end

   def test_compile13_php	# rename global var
      expected = <<'END'
Hello <?php echo $_user[$_name]; ?>!
<table>
<?php $i = 0; ?>
<?php foreach ($_list as $item) { ?>
<?php   $i += 1; ?>
<?php   $klass = $i % 2 == 0 ? "even" : "odd"; ?>
  <tr class="<?php echo $klass; ?>">
    <td><?php echo $item[$klass]; ?></td>
  </tr>
<?php } ?>
</table>
END
      _test(@@pdata13, @@plogic13, expected, { :globalvar_prefix => "_" })
   end

   def test_compile13_jstl11	# rename global var
      expected = <<'END'
Hello <c:out value="${_user[_name]}" escapeXml="false"/>!
<table>
<c:set var="i" value="0"/>
<c:forEach var="item" items="${_list}">
  <c:set var="i" value="${i + 1}"/>
  <c:set var="klass" value="${i % 2 eq 0 ? 'even' : 'odd'}"/>
  <tr class="<c:out value="${klass}" escapeXml="false"/>">
    <td><c:out value="${item[klass]}" escapeXml="false"/></td>
  </tr>
</c:forEach>
</table>
END
      _test(@@pdata13, @@plogic13, expected, { :globalvar_prefix => '_' })
   end

   def test_compile13_jstl10	# rename global var
      expected = <<'END'
Hello <c:out value="${_user[_name]}" escapeXml="false"/>!
<table>
<c:set var="i" value="0"/>
<c:forEach var="item" items="${_list}">
  <c:set var="i" value="${i + 1}"/>
  <c:choose><c:when test="${i % 2 eq 0}">
    <c:set var="klass" value="even"/>
  </c:when><c:otherwise>
    <c:set var="klass" value="odd"/>
  </c:otherwise></c:choose>
  <tr class="<c:out value="${klass}" escapeXml="false"/>">
    <td><c:out value="${item[klass]}" escapeXml="false"/></td>
  </tr>
</c:forEach>
</table>
END
      _test(@@pdata13, @@plogic13, expected, { :globalvar_prefix => '_' })
   end

   def test_compile13_velocity	# rename global var
      $test_compile13_velocity = true
      expected = <<'END'
Hello $!{_user[$_name]}!
<table>
#set($i = 0)
#foreach($item in $_list)
  #set($i = $i + 1)
  #if($i % 2 == 0)
    #set($klass = "even")
  #else
    #set($klass = "odd")
  #end
  <tr class="$!{klass}">
    <td>$!{item[$klass]}</td>
  </tr>
#end
</table>
END
      _test(@@pdata13, @@plogic13, expected, { :globalvar_prefix => '_' })
   end


end


## ========================================

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
