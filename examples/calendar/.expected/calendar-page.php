<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
  <head>
    <title>Calendar&nbs; <?php echo $year; ?></title>
    <style type="text/css">
      <!--
        .title     {font-size:x-large; font-weight:bold;}
        .holiday   {color:#FF0000;}
        td         {text-align:center;}
        -->
    </style>
  </head>
  <body>

    <div align="center">
      <a href="<?php echo $prev_link; ?>">&lt;&lt;</a>
      &nbsp;
      <span class="title">
        Calendar&nbsp; <?php echo $year; ?>
      </span>
      &nbsp;
      <a href="<?php echo $next_link; ?>">&gt;&gt;</a>
    </div>
    <br>

    <div align="center">
      <table border="0" summary="">
<?php $calendar_ctr = 0; ?>
<?php foreach ($calendar_list as $calendar) { ?>
<?php   $calendar_ctr += 1; ?>
<?php   if ($calendar_ctr % $column == 1) { ?>
        <tr>
<?php   } ?>
          <td valign="top">
<?php echo $calendar; ?>          </td>
<?php   if ($calendar_ctr % $column == 0) { ?>
        </tr>
<?php   } ?>
<?php } ?>
<?php if ($calendar_ctr % $column != 0) { ?>
<?php   $calendar = ""; ?>
<?php   while ($calendar_ctr % $column != 0) { ?>
          <td valign="top">
<?php echo $calendar; ?>          </td>
<?php     $calendar_ctr += 1; ?>
<?php   } ?>
        </tr>
<?php } ?>
      </table>
    </div>
    
  </body>
</html>
