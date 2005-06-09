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
        <tr bgcolor="<?php echo $color; ?>">
          <td><?php echo $user["name"]; ?></td>
          <td><a href="mailto:<?php echo $user["email"]; ?>"><?php echo $user["email"]; ?></a></td>
        </tr>
<?php } ?>
      </tbody>
    </table>
    
  </body>
</html>
