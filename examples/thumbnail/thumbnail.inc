<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=EUC-JP">
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
  <?php if ($page > $first) { ?>
      <a href="<?php echo $first_url; ?>">|&lt;&lt; First</a>
  <?php } else { ?>
|&lt;&lt; First<?php } ?>
      &nbsp;
  <?php if ($page > $first) { ?>
      <a  href="<?php echo $prev_url; ?>">&lt; Prev</a>
  <?php } else { ?>
&lt; Prev<?php } ?>
      &nbsp;
      <a  href="<?php echo $list_url; ?>">List</a>
      &nbsp;
  <?php if ($page < $last) { ?>
      <a  href="<?php echo $next_url; ?>"><b>Next &gt;</b></a>
  <?php } else { ?>
<b>Next &gt;</b><?php } ?>
      &nbsp;
  <?php if ($page < $last) { ?>
      <a  href="<?php echo $last_url; ?>">Last &gt;&gt;|</a>
  <?php } else { ?>
Last &gt;&gt;|<?php } ?>
    </div>
<?php } ?>

<?php if ($page == 0) { ?>
  <?php $item_ctr = 0; ?>
  <?php foreach ($list as $item) { ?>
    <?php $item_ctr += 1; ?>
    <?php $icon_goto_url = $item['goto_url']; ?>
    <?php $icon_image_url = $item['image_url']; ?>
      <a href="<?php echo $icon_goto_url; ?>"><img width="200" height="150" src="<?php echo $icon_image_url; ?>"/></a>
    <?php if ($item_ctr % 3 == 0) { ?>
      <br/>
    <?php } ?>
  <?php } ?>
<?php } ?>

<?php if ($page != 0) { ?>
    <div id="main_image" align="center">
      <br>
      <table border="1">
	<tr>
	  <td>
	    <img src="<?php echo $image_url; ?>" alt="presentaion image"/>
	  </td>
	</tr>
      </table>
      <br>
    </div>
<?php } ?>
    
<?php if ($page > 0) { ?>
    <div align="center">
  <?php if ($page > $first) { ?>
      <a href="<?php echo $first_url; ?>">|&lt;&lt; First</a>
  <?php } else { ?>
|&lt;&lt; First<?php } ?>
      &nbsp;
  <?php if ($page > $first) { ?>
      <a  href="<?php echo $prev_url; ?>">&lt; Prev</a>
  <?php } else { ?>
&lt; Prev<?php } ?>
      &nbsp;
      <a  href="<?php echo $list_url; ?>">List</a>
      &nbsp;
  <?php if ($page < $last) { ?>
      <a  href="<?php echo $next_url; ?>"><b>Next &gt;</b></a>
  <?php } else { ?>
<b>Next &gt;</b><?php } ?>
      &nbsp;
  <?php if ($page < $last) { ?>
      <a  href="<?php echo $last_url; ?>">Last &gt;&gt;|</a>
  <?php } else { ?>
Last &gt;&gt;|<?php } ?>
    </div>
<?php } ?>
    
<?php if ($page == 1) { ?>
    <div id="counter" align="right">
      <img src="/cgi-bin/Count.cgi?df=kwartz.kwarz-overview.index&dd=A&ft=0&tr=T&trgb=000000&prgb=CCCCCC&md=7"
        alt="counter image file">
    </div>
<?php } ?>
    
  </body>
</html>
