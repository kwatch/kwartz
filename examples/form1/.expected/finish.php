<html>
 <body>
  Registration has finished with the following data:<br>
  <br>
  Name:
   <?php echo htmlspecialchars($name); ?><br>
  Gender:
<?php if ($gender == "M") { ?>
   Man
<?php } else { ?>
   Woman
<?php } ?>
 </body>
</html>
