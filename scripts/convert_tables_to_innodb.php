<?php
require(dirname(__FILE__)."/../bin/config.php");
require(WWW_DIR."/lib/framework/cache.php");
require_once(WWW_DIR."/lib/framework/db.php");

$sql = "SHOW tables";
$db = new DB();

$tables = $db->query($sql);
foreach($tables as $row)
    {
	$tbl = $row['Tables_in_newznab'];
	printf("Converting $tbl\n");
        $sql = "ALTER TABLE $tbl ENGINE=INNODB ROW_FORMAT=DYNAMIC";
        $db->query($sql);
    }


?>
