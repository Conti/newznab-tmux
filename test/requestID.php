<?php
require_once(dirname(__FILE__)."/../bin/config.php");
require_once(WWW_DIR. "lib/framework/db.php");
require_once(WWW_DIR. "lib/category.php");
require_once(WWW_DIR. "lib/groups.php");
require_once("functions.php");
require_once("ColorCLI.php");
require_once("consoletools.php");
require_once("namefixer.php");

//This script is adapted from nZEDB requestID.php

$c = new ColorCLI;
if (!isset($argv[1]) || ( $argv[1] != "all" && $argv[1] != "full" && !is_numeric($argv[1]))){
	exit($c->error("\nThis script tries to match an MD5 of the releases.name or releases.searchname to predb.md5 doing local lookup only.\n"
			. "php requestid.php 1000 true		...: to limit to 1000 sorted by newest postdate and show renaming.\n"
			. "php requestid.php full true		...: to run on full database and show renaming.\n"
			. "php requestid.php all true		...: to run on all hashed releases(including previously renamed) and show renaiming."
			. "In addition an optional final argument is time, in minutes, to check releases that have previously been checked.\n"));
}

$db = new DB();
$functions = new Functions();
$n = "\n";
$category = new Category();
$groups = new Groups();
$consoletools = new ConsoleTools();
$namefixer = new Namefixer();
$timestart = TIME();
$counter = 0;

if (isset($argv[2]) && is_numeric($argv[2])) {
	$time = ' OR r.postdate > NOW() - INTERVAL ' . $argv[2] . ' MINUTE)';
} else if (isset($argv[3]) && is_numeric($argv[3])) {
	$time = ' OR r.postdate > NOW() - INTERVAL ' . $argv[3] . ' MINUTE)';
} else {
	$time = ')';
}

//runs on every release
if (isset($argv[1]) && $argv[1] === "all") {
	$res = $db->queryDirect("SELECT r.ID, r.searchname, r.categoryID, g.name AS groupname FROM releases r LEFT JOIN groups g ON r.groupID = g.ID WHERE nzbstatus = 1 AND isrequestid = 1");
//runs on all releases not already renamed
} else if (isset($argv[1]) && $argv[1] === "full") {
	$res = $db->queryDirect("SELECT r.ID, r.searchname, r.categoryID, g.name AS groupname FROM releases r LEFT JOIN groups g ON r.groupID = g.ID WHERE nzbstatus = 1 AND (isrenamed = 0 AND isrequestid = 1 " . $time . " AND reqidstatus in (0, -1)");
//runs on all releases not already renamed limited by user
} else if (isset($argv[1]) && is_numeric($argv[1])) {
	$res = $db->queryDirect("SELECT r.ID, r.searchname, r.categoryID, g.name AS groupname FROM releases r LEFT JOIN groups g ON r.groupID = g.ID WHERE nzbstatus = 1 AND (isrenamed = 0 AND isrequestid = 1 " . $time . " AND reqidstatus in (0, -1) ORDER BY postdate DESC LIMIT " . $argv[1]);
}

        $total = $res->rowCount();
        if ($total > 0)
        {
          	$precount = $db->queryOneRow("SELECT COUNT(*) AS count FROM prehash WHERE requestID > 0");
	echo $c->header("\nComparing ".number_format($total).' releases against '.number_format($precount['count'])." Local requestID's.");
	sleep(2);

            foreach ($res as $row)
            {
               if (!preg_match('/^\[\d+\]/', $row["searchname"]) && !preg_match('/^\[ \d+ \]/', $row["searchname"]))
		            {
			        $db->query(sprintf("UPDATE releases SET reqidstatus = -2 WHERE reqidstatus != 1 AND ID = %d", $row["ID"]));
			        continue;
		            }

                $requestIDtmp = explode(']', substr($row["searchname"], 1));
                $bFound = false;
                $newTitle = '';

                if (count($requestIDtmp) >= 1)
                {
	                $requestID = (int) trim($requestIDtmp[0]);
			        if ($requestID != 0 and $requestID != '')
                    {
		                // Do a local lookup
		                $newTitle = localLookup($requestID, $row["groupname"], $row["searchname"]);
		                if (is_array($newTitle) && $newTitle['title'] != ''){
			                $bFound = true;
                        }
	                }
                }

                if ($bFound === true)
                {
                    $title = $newTitle['title'];
			        $preid = $newTitle['ID'];
	                $groupname = $functions->getByNameByID($row["groupname"]);
	                $determinedcat = $category->determineCategory($groupname, $title );
			        $run = $db->queryDirect(sprintf('UPDATE releases SET rageID = NULL, seriesfull = NULL, season = NULL, episode = NULL, tvtitle = NULL, tvairdate = NULL, imdbID = NULL, musicinfoID = NULL, consoleinfoID = NULL, bookinfoID = NULL, "
								. "anidbID = NULL, preID = %d, reqidstatus = 1, isrenamed = 1, iscategorized = 1, searchname = %s, categoryID = %d WHERE ID = %d', $preid, $db->escapeString($title), $determinedcat, $row['ID']));
                    if ($row['searchname'] !== $newTitle)
                    {
                    $counter++;
	                if (isset($argv[2]) && $argv[2] === 'true')
			            {
				            $newcatname = $functions->getNameByID($determinedcat);
				            $oldcatname = $functions->getNameByID($row['categoryID']);

				            echo 	$c->headerOver($n.$n.'New name:  ').$c->primary($title).
						            $c->headerOver('Old name:  ').$c->primary($row["searchname"]).
						            $c->headerOver('New cat:   ').$c->primary($newcatname).
						            $c->headerOver('Old cat:   ').$c->primary($oldcatname).
						            $c->headerOver('Group:     ').$c->primary($row["groupname"]).
						            $c->headerOver('Method:    ').$c->primary('requestID local').
						            $c->headerOver('ReleaseID: ').$c->primary($row["ID"]);
			            }
			        else
			        {
				        if ($counter % 100 == 0)
				    {
					    echo ".";
				    }
			        }
		        }
                }
                else
                {
	                $db->exec("UPDATE releases SET reqidstatus = -3 WHERE reqidstatus != 1 AND ID = " . $row["ID"]);
	                echo '.';
                }
                }
            if ($total > 0) {
        echo $c->header("\nRenamed " . number_format($counter) . " releases in " . $consoletools->convertTime(TIME() - $timestart) . ".");
    } else {
        echo $c->info("\nNothing to do.");
    }
} else {
    echo $c->info("No work to process\n");
}


    function localLookup($requestID, $groupName, $oldname)
    {
	    $db = new DB();
	    $groups = new Groups();
        $functions = new Functions();
	    $groupID = $functions->getIDByName($groupName);
	    $run = $db->queryOneRow(sprintf("SELECT ID, title FROM prehash WHERE requestID = %d AND groupID = %d", $requestID, $groupID));
        if (isset($run["title"]) && preg_match('/s\d+/i', $run["title"]) && !preg_match('/s\d+e\d+/i', $run["title"])) {
        return false;
    }
	    if (isset($run["title"]))
		   return array('title' => $run['title'], 'ID' => $run['ID']);
	    if (preg_match('/\[#?a\.b\.teevee\]/', $oldname))
		    $groupID = $functions->getIDByName('alt.binaries.teevee');
	    else if (preg_match('/\[#?a\.b\.moovee\]/', $oldname))
		    $groupID = $functions->getIDByName('alt.binaries.moovee');
	    else if (preg_match('/\[#?a\.b\.erotica\]/', $oldname))
		    $groupID = $functions->getIDByName('alt.binaries.erotica');
	    else if (preg_match('/\[#?a\.b\.foreign\]/', $oldname))
		    $groupID = $functions->getIDByName('alt.binaries.mom');
        else if ($groupName == 'alt.binaries.etc')
		    $groupID = $functions->getIDByName('alt.binaries.teevee');
            //groups below are added for testing purposes
        else if (preg_match('/\[#?a\.b\.mom\]/', $oldname))
		    $groupID = $functions->getIDByName('alt.binaries.mom');
        else if ($groupName == 'alt.binaries.mom')
		    $groupID = $functions->getIDByName('alt.binaries.mom');
        else if ($groupName == 'alt.binaries.town.xxx')
		    $groupID = $functions->getIDByName('alt.binaries.erotica');
        else if (preg_match('/\[#?a\.b\.town\.xxx\]/', $oldname))
		    $groupID = $functions->getIDByName('alt.binaries.erotica');
        else if ($groupName == 'alt.binaries.tvseries')
		    $groupID = $functions->getIDByName('alt.binaries.teevee');
        else if (preg_match('/\[#?a\.b\.tvseries\]/', $oldname))
		    $groupID = $functions->getIDByName('alt.binaries.teevee');
        else if ($groupName == 'alt.binaries.x264')
		    $groupID = $functions->getIDByName('alt.binaries.teevee');
        else if (preg_match('/\[#?a\.b\.x264\]/', $oldname))
		    $groupID = $functions->getIDByName('alt.binaries.teevee');
        else if ($groupName == 'alt.binaries.town')
		    $groupID = $functions->getIDByName('alt.binaries.teevee');
        else if (preg_match('/\[#?a\.b\.town\]/', $oldname))
		    $groupID = $functions->getIDByName('alt.binaries.teevee');



	    $run = $db->queryOneRow(sprintf("SELECT ID, title FROM prehash WHERE requestID = %d AND groupID = %d", $requestID, $groupID));
	    if (isset($run['title']))
		    return array('title' => $run['title'], 'ID' => $run['ID']);
        }




?>
