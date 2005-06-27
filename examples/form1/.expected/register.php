<html>
 <head>
  <style type="text/css">
   <!--
     .label {
        /* font-weight:bold; */
        background-color:#CCFFCC;
        text-align:right;
     }
    -->
  </style>
 </head>
 <body>
  <form action="register.rbx" method="POST">

<?php if ($error_list != NULL) { ?>
<?php   foreach ($error_list as $error) { ?>
    <font color="#FF0000">
     <?php echo htmlspecialchars($error); ?><br>
    </font>
<?php   } ?>
<?php } else { ?>
    Enter your personal information:
<?php } ?>

   <table border="0" cellspacing="1" cellpadding="5">

    <tr>
     <td class="label">Name:</td>
     <td>
      <input type="text" name="name" size="20" id="name" value="<?php echo htmlspecialchars($name); ?>" />
     </td>
    </tr>

    <tr>
     <td class="label">Gender:</td>
     <td>
      <input type="radio" name="gender" value="M"<?php echo $gender == "M" ? " checked=\"checked\"" : ""; ?> />Man
      &nbsp;
      <input type="radio" name="gender" value="W"<?php echo $gender == "M" ? " checked=\"checked\"" : ""; ?> />Woman
     </td>
    </tr>

    <tr>
     <td colspan="2" align="center">
      <input type="submit" value=" Register ">
      <input type="reset"  value="reset">
     </td>
    </tr>

   </table>
  </form>
 </body>
</html>
