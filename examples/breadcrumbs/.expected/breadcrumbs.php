<html>
  <body>

    <div id="breadcrumbs">
<?php foreach ($breadcrumbs as $crumb) { ?>
      <a href="<?php echo $crumb['path']; ?>"><?php echo $crumb['name']; ?></a>
      &gt;
<?php } ?>
      <?php echo $title; ?>
    </div>

  </body>
</html>
