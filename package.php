<<?php ?>?xml version="1.0" encoding="ISO-8859-1"?>
<?php

    //if (! extension_loaded('syck')) {
    //    dl('syck.so') die('cannot load syck extension.');
    //}

    require_once 'Kook/YamlParser.php';
    require_once 'Kook/FileUtil.php';

    //$ydoc = syck_load(file_get_contents('package.yaml'));
    $parser = new KookPlainYamlParser(file_get_contents('package.yaml'));
    $ydoc = $parser->parse();
    $maintainers = $ydoc['maintainers'];
    $releases    = $ydoc['releases'];
    $documents   = $ydoc['documents'];
    $list = array();
    foreach ($documents as $doc) {
        $list2 = kook_glob($doc);
	foreach ($list2 as $item) {
	    if (is_file($item)) $list[] = $item;
	}
    }
    $documents = $list;
 ?>
<package version="1.0">
  <name>Kwartz</name>
  <summary>web template system which doesn't break HTML design at all</summary>
  <description>Kwartz is a web template system which realized the concept
  "Independence of Presentation Logic" (IoPL). It means that presentation
  logics such as iteration or conditional branch are not mixed into HTML
  template.
  It is just like CSS. CSS separates page design from HTML file.
  Kwartz separates presentation logics from HTML file.
  </description>
  <maintainers>
<?php foreach ($maintainers as $maintainer) { ?>
    <maintainer>
      <user><?php echo $maintainer['user']; ?></user>
      <name><?php echo $maintainer['name']; ?></name>
      <email><?php echo $maintainer['email']; ?></email>
      <role><?php echo $maintainer['role']; ?></role>
    </maintainer>
<?php } ?>
  </maintainers>
  <release>
<?php $last_release = $releases[0]; ?>
<?php $date = $last_release['date'] || localtime(); ?>
<?php if (! $last_release['date']) $last_release['date'] = localtime(); ?>
    <version><?php echo $last_release['version']; ?></version>
    <date><?php echo strftime("%Y-%m-%d", $last_release['date']); ?></date>
    <license>LGPL 2.1</license>
    <state><?php echo $last_release['state']; ?></state>
    <notes>public beta</notes>
    <filelist>
<?php // ==================== ?>
<?php $filenames = glob('bin/*'); ?>
<?php foreach ($filenames as $filename) { ?>
<?php   $digest = md5(file_get_contents($filename)); ?>
      <file role="script" baseinstalldir="../" name="<?php echo $filename; ?>"
            md5sum="<?php echo $digest; ?>">
        <replace from="/usr/local/bin" to="PHP_BINDIR" type="php-const"/>
        <replace from="@data_dir@" to="data_dir" type="pear-config"/>
        <replace from="@doc_dir@" to="doc_dir" type="pear-config"/>
        <replace from="@php_dir@" to="php_dir" type="pear-config"/>
      </file>
<?php } ?>
<?php // ==================== ?>
<?php
    $filenames_table = array(
        'php' => kook_glob('Kwartz/**/*.php'),
	'doc' => $documents,
        'test' => glob('test/*.{php,yaml,inc}', GLOB_BRACE),
    );
    foreach ($filenames_table as $role => $filenames) {
        foreach ($filenames as $filename) {
            #$basename = basename($filename);
            $digest = md5(file_get_contents($filename));
?>
      <file role="<?php echo $role; ?>" baseinstalldir="/" name="<?php echo $filename; ?>"
	    md5sum="<?php echo $digest; ?>"/>
<?php
       }
    }
?>
<?php // ==================== ?>
    </filelist>
  </release>
  <changelog>
<?php foreach ($releases as $release) { ?>
    <release>
      <version><?php echo $release['version']; ?></version>
      <date><?php echo strftime("%Y-%m-%d", $release['date']); ?></date>
      <state><?php echo $release['state']; ?></state>
      <notes><?php echo $release['notes']; ?>
      </notes>
    </release>
<?php } ?>
  </changelog>
</package>
