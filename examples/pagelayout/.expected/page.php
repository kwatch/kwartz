<!doctype html public "-//W3C//DTD HTML 4.01 Transitional//EN">
<html lang="en">
  <head>
    <title><?php echo $title; ?></title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
    <link rel="stylesheet" type="text/css" href="design.css">
  </head>
  <body>

    <table border="0">
      <tr>
        
        <!-- menu part -->
        <td width="100" valign="top">
          <div class="menu">
    <ul>
<?php foreach ($menu_list as $item) { ?>
      <li><a href="<?php echo $item['url']; ?>"><?php echo $item['name']; ?></a></li>
<?php } ?>
    </ul>
          </div>
        </td>
        
        <!-- article part -->
        <td width="400" valign="top">
          <div class="article">
    <div>
      <h2>What is Kwartz?</h2>
      <p>Kwartz is a template system, which realized the
         concept <strong>`Separation of Presentation Logic
         and Presentation Data'(SoPL/PD)</strong>.
      </p>
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
