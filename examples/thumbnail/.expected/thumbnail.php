<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO8859-1">
    <title>Kwartz - a template system for Ruby, PHP and Java (brief overview)</title>
    <style type="text/css">
      <!--
	body   {background-color:#FFFFFF;}
	-->
    </style>
  </head>
  
  <body>
    
<?php if ($page > 0) { ?>
    <div align="center">
<?php   if ($first_url) { ?>
      <a href="<?php echo $first_url; ?>">|&lt;&lt; First</a>
<?php   } else { ?>
|&lt;&lt; First<?php } ?>
      &nbsp;
<?php   if ($prev_url) { ?>
      <a href="<?php echo $prev_url; ?>">&lt; Prev</a>
<?php   } else { ?>
&lt; Prev<?php } ?>
      &nbsp;
<?php   if ($index_url) { ?>
      <a href="<?php echo $index_url; ?>">Index</a>
<?php   } else { ?>
Index<?php } ?>
      &nbsp;
<?php   if ($next_url) { ?>
      <a href="<?php echo $next_url; ?>"><b>Next &gt;</b></a>
<?php   } else { ?>
<b>Next &gt;</b><?php } ?>
      &nbsp;
<?php   if ($last_url) { ?>
      <a href="<?php echo $last_url; ?>">Last &gt;&gt;|</a>
<?php   } else { ?>
Last &gt;&gt;|<?php } ?>
    </div>
<?php } ?>

<?php if ($page == 0) { ?>
<?php   $i = 0; ?>
<?php   foreach ($thumb_list as $thumb) { ?>
<?php     $i += 1; ?>
<?php     $link_url = $thumb['link_url']; ?>
<?php     $image_url = $thumb['image_url']; ?>
      <a href="<?php echo $link_url; ?>"><img src="<?php echo $image_url; ?>"
	width="200" height="150" /></a>
<?php     if ($i % 3 == 0) { ?>
      <br />
<?php     } ?>
<?php   } ?>
<?php } ?>
    </div>
      
<?php if ($page != 0) { ?>
    <div id="main_image" align="center">
      <br>
      <table border="1">
	<tr>
	  <td>
	    <img src="<?php echo $image_url; ?>" alt="presentaion image" />
	  </td>
	</tr>
      </table>
      <br>
    </div>
<?php } ?>
    
<?php if ($page > 0) { ?>
    <div align="center">
<?php   if ($first_url) { ?>
      <a href="<?php echo $first_url; ?>">|&lt;&lt; First</a>
<?php   } else { ?>
|&lt;&lt; First<?php } ?>
      &nbsp;
<?php   if ($prev_url) { ?>
      <a href="<?php echo $prev_url; ?>">&lt; Prev</a>
<?php   } else { ?>
&lt; Prev<?php } ?>
      &nbsp;
<?php   if ($index_url) { ?>
      <a href="<?php echo $index_url; ?>">Index</a>
<?php   } else { ?>
Index<?php } ?>
      &nbsp;
<?php   if ($next_url) { ?>
      <a href="<?php echo $next_url; ?>"><b>Next &gt;</b></a>
<?php   } else { ?>
<b>Next &gt;</b><?php } ?>
      &nbsp;
<?php   if ($last_url) { ?>
      <a href="<?php echo $last_url; ?>">Last &gt;&gt;|</a>
<?php   } else { ?>
Last &gt;&gt;|<?php } ?>
    </div>
<?php } ?>

    <!--
    <div id="counter" align="right">
      <img src="/cgi-bin/Count.cgi?df=kwartz.kwarz-overview.index&dd=A&ft=0&tr=T&trgb=000000&prgb=CCCCCC&md=7"
        alt="counter image file">
    </div>
      -->
    
  </body>
</html>
