<html>
  <body>

    <table>
      <thead>
	<th>Name</th><th>E-Mail</th>
      </thead>
      <tbody>
<?php $i = 0; ?>
<?php foreach ($user_list as $user) { ?>
<?php   $i += 1; ?>
<?php   $name = $user["name"]; ?>
<?php   $email = $user["email"]; ?>
<?php   if ($i % 2 == 0) { ?>
	<tr bgcolor="#CCCCFF">
	  <td><?php echo $name; ?></td>
	  <td><a href="mailto:<?php echo $email; ?>"><?php echo $email; ?></a></td>
	</tr>
<?php   } else { ?>
	<tr bgcolor="#FFCCCC">
	  <td><?php echo $name; ?></td>
	  <td><a href="mailto:<?php echo $email; ?>"><?php echo $email; ?></a></td>
	</tr>
<?php   } ?>
<?php } ?>
      </tbody>
    </table>
    
  </body>
</html>
