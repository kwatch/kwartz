<!doctype html public "-//W3C//DTD HTML 4.01 Transitional//EN">
<html lang="en">
  <head>
    <title>MyGroupware: Stock Quoting</title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
    <link rel="stylesheet" type="text/css" href="design.css">
  </head>
  <body>

    <table border="0">
      <tr>

        <!-- menu part -->
        <td width="100" valign="top" class="menulist">
          <b>Menu:</b>
          <div>
<?php foreach ($menulist as $menu) { ?>
    <ul>
      <li><a href="<?php echo $menu['url']; ?>"><?php echo $menu['label']; ?></a></li>
    </ul>
<?php } ?>
          </div>
        </td>

        <!-- content part -->
        <td width="400" valign="top" class="contents">
          <h3>Stock Quoting</h3>
          <div>
    <div>
      <table>
        <thead>
          <tr>
            <th>Symbol</th><th>Company</th><th>Price</th><th>Change</th>
          </tr>
        </thead>
        <tbody>
<?php foreach ($stocks as $stock) { ?>
          <tr>
            <td><?php echo $stock['symbol']; ?></td>
            <td><?php echo $stock['company']; ?></td>
            <td align="right"><?php echo $stock['price']; ?></td>
<?php   $rate = $stock['rate']; ?>
<?php   $style = ""; ?>
<?php   if ($rate < 0) { ?>
<?php     $rate = -$rate; ?>
<?php     $style = " style=\"color:red\""; ?>
<?php   } ?>
            <td align="right"<?php echo $style; ?>><?php echo $rate; ?>%</td>
          </tr>
<?php } ?>
        </tbody>
      </table>
    </div>
          </div>
        </td>

      </tr>

      <!-- footer part -->
      <tr>
        <td colspan="2" class="copyright">
          copyright&copy; 2004-2005 kuwata-lab.com All Rights Reserverd
        </td>
      </tr>
    </table>

  </body>
</html>
