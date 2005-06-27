<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO8859-1">
    <title>Kwartz - a template system for Ruby, PHP and Java (brief overview)</title>
  </head>

  <body style="background-color:#FFFFFF">

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
      <a href="<?php echo $next_url; ?>"><strong>Next &gt;</strong></a>
<?php   } else { ?>
<strong>Next &gt;</strong><?php } ?>
      &nbsp;
<?php   if ($last_url) { ?>
      <a href="<?php echo $last_url; ?>">Last &gt;&gt;|</a>
<?php   } else { ?>
Last &gt;&gt;|<?php } ?>
    </div>
<?php } ?>

    <div>
<?php if ($page == 0) { ?>
<?php   $i = 0; ?>
<?php   foreach ($thumb_list as $thumb) { ?>
<?php     $i += 1; ?>
<?php     $link_url = $thumb['link_url']; ?>
<?php     $image_url = $thumb['image_url']; ?>
      <a href="<?php echo $link_url; ?>"><!--
    --><img width="200" height="150" src="<?php echo $image_url; ?>"></a>
<?php     if ($i % 3 == 0) { ?>
      <br>
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
            <img src="<?php echo $image_url; ?>" alt="presentaion image">
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
      <a href="<?php echo $next_url; ?>"><strong>Next &gt;</strong></a>
<?php   } else { ?>
<strong>Next &gt;</strong><?php } ?>
      &nbsp;
<?php   if ($last_url) { ?>
      <a href="<?php echo $last_url; ?>">Last &gt;&gt;|</a>
<?php   } else { ?>
Last &gt;&gt;|<?php } ?>
    </div>
<?php } ?>

  </body>
</html>
