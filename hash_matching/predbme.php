<?php
require_once(dirname(__FILE__)."/../bin/config.php");
require_once(WWW_DIR ."/lib/framework/db.php");
require_once(WWW_DIR ."/lib/util.php");


//This script is adapted from nZEDb predb.php script

$db = new DB();
		$newnames = 0;
		$arr = array("http://predb.me/?cats=movies-sd&rss=1", "http://predb.me/?cats=movies-hd&rss=1", "http://predb.me/?cats=movies-discs&rss=1", "http://predb.me/?cats=tv-sd&rss=1", "http://predb.me/?cats=tv-hd&rss=1", "http://predb.me/?cats=tv-discs&rss=1", "http://predb.me/?cats=music-audio&rss=1", "http://predb.me/?cats=music-video&rss=1", "http://predb.me/?cats=music-discs&rss=1", "http://predb.me/?cats=games-pc&rss=1", "http://predb.me/?cats=games-xbox&rss=1", "http://predb.me/?cats=games-playstation&rss=1", "http://predb.me/?cats=games-nintendo&rss=1", "http://predb.me/?cats=apps-windows&rss=1", "http://predb.me/?cats=apps-linux&rss=1", "http://predb.me/?cats=apps-mac&rss=1", "http://predb.me/?cats=apps-mobile&rss=1", "http://predb.me/?cats=books-ebooks&rss=1", "http://predb.me/?cats=books-audio-books&rss=1", "http://predb.me/?cats=xxx-videos&rss=1", "http://predb.me/?cats=xxx-images&rss=1", "http://predb.me/?cats=dox&rss=1", "http://predb.me/?cats=unknown&rss=1");

        echo "Requesting pre info from predb.me ...\n";

		foreach ($arr as &$value)
		{
			$releases = @simplexml_load_file($value);
			if ($releases !== false)
			{
				foreach ($releases->channel->item as $release)
				{
					$oldname = $db->queryOneRow(sprintf("SELECT title FROM prehash WHERE title = %s", $db->escapeString($release->title)));
					if ($oldname["title"] == $release->title)
						continue;
					else
					{
						$db->query(sprintf("INSERT IGNORE INTO prehash (title, predate, adddate, source, hash) VALUES (%s, now(), now(), %s, %s)", $db->escapeString($release->title), $db->escapeString("predbme"), $db->escapeString(md5($release->title))));
						$newnames++;
					}
				}
			}
		}
		return $newnames;



?>