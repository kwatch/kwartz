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
<?php   $color = $i % 2 == 0 ? "#CCCCFF" : "#FFCCCC"; ?>
<?php   $name = $user["name"]; ?>
<?php   $email = $user["email"]; ?>
        <tr bgcolor="<?php echo $color; ?>">
          <td><?php echo $name; ?></td>
          <td><a href="mailto:<?php echo $email; ?>"><?php echo $email; ?></a></td>
        </tr>
<?php } ?>
      </tbody>
    </table>
    
  </body>
</html>
