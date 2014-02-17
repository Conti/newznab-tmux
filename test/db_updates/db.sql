ALTER TABLE  `predb`
  ADD `md5` VARCHAR( 32 ) NULL,
  ADD INDEX (`md5`);
ALTER TABLE  `releases`
  ADD `dehashstatus` TINYINT( 1 ) NOT NULL DEFAULT  '0' AFTER  `haspreview`,
  ADD `nfostatus` TINYINT NOT NULL DEFAULT 0 after `dehashstatus`,
  ADD `reqidstatus` TINYINT(1) NOT NULL DEFAULT '0' AFTER `nfostatus`,
  ADD `bitwise` SMALLINT UNSIGNED NOT NULL DEFAULT 0 AFTER `reqidstatus`,
  ADD INDEX `ix_releases_nfostatus` (`nfostatus` ASC) USING HASH,
  ADD INDEX `ix_releases_reqidstatus` (`reqidstatus` ASC) USING HASH,
  ADD INDEX `ix_releases_bitwise` (`bitwise`),
  ADD INDEX `ix_releases_passwordstatus` (`passwordstatus`),
  ADD INDEX `ix_releases_dehashstatus` (`dehashstatus`),
  ADD INDEX `ix_releases_haspreview` (`haspreview` ASC) USING HASH,
  ADD INDEX `ix_releases_postdate_name` (`postdate`, `name`),
  ADD INDEX `ix_releases_status` (`ID`, `nfostatus`, `bitwise`, `passwordstatus`, `dehashstatus`, `reqidstatus`, `musicinfoID`, `consoleinfoID`, `bookinfoID`, `haspreview`, `categoryID`, `imdbID`, `rageID`, `groupID`);

DROP TABLE IF EXISTS tmux;
CREATE TABLE tmux (
	ID int(10) unsigned NOT NULL AUTO_INCREMENT,
	setting varchar(64) COLLATE utf8_unicode_ci NOT NULL,
	value varchar(19000) COLLATE utf8_unicode_ci DEFAULT NULL,
	updateddate timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY (ID),
	UNIQUE KEY setting (setting)
) ENGINE=INNODB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

INSERT INTO tmux (setting, value) values ('defrag_cache','900'),
	('monitor_update','30'),
	('tmux_session','newznab'),
	('niceness','19'),
    ('max_load','0')
    ('max_load_releases','0')
	('binaries','0'),
    ('binaries_threaded','0'),
	('backfill','0'),
    ('backfill_threaded','0'),
	('import','0'),
	('nzbs','/path/to/nzbs'),
	('running','0'),
	('sequential','0'),
    ('binaries_seq_timer','0'),
    ('backfill_seq_timer','0'),
	('nfos','0'),
    ('games','0'),
    ('movies','0'),
    ('music','0'),
    ('ebook','0'),
    ('tvrage','0'),
    ('others','0'),
    ('unwanted','0'),
    ('kill_updates','0'),
    ('keep_killed','0'),
	('post','0'),
	('releases','0'),
	('releases_threaded','0'),
	('fix_names','0'),
	('seq_timer','30'),
	('binaries_sleep','30'),
    ('binaries_max_releases','0'),
    ('binaries_max_bins','0'),
    ('binaries_max_rows','0'),
    ('fixreleases','0'),
    ('fixreleases_timer','40'),
	('back_timer','30'),
	('import_timer','30'),
	('rel_timer','30'),
	('post_timer','30'),
	('import_bulk','0'),
	('backfill_qty','100000'),
	('postprocess_kill','0'),
	('removecrap_timer','40'),
	('removecrap','0'),
    ('uppre','0'),
    ('uppre_timer','40'),
    ('predb','0'),
    ('predb_timer','900'),
    ('spotnab','0'),
    ('spotnab_timer','900'),
    ('sphinx','0'),
    ('sphinx_timer','3600'),
    ('delete_parts','0'),
    ('delete_timer','0'),
    ('fetch_movie','0'),
    ('movie_timer','43200'),
	('tv_timer','43200'),
	('htop','0'),
	('nmon','0'),
	('bwmng','0'),
	('mytop','0'),
	('console','0'),
	('vnstat','0'),
	('vnstat_args',NULL),
	('tcptrack','0'),
	('tcptrack_args','-i eth0 port 443'),
	('backfill_groups','4'),
	('post_kill_timer','300'),
	('monitor_path', NULL),
	('write_logs','0'),
	('powerline','0'),
	('dehash', '0'),
    ('reqid','0'),
    ('reqid_timer','0'),
	('dehash_timer','30'),
	('backfill_days', '1'),
	('colors_start', '1'),
	('colors_end', '250'),
	('colors_exc', '4, 8, 9, 11, 15, 16, 17, 18, 19, 46, 47, 48, 49, 50, 51, 52, 53, 59, 60'),
	('monitor_path_a', NULL),
	('monitor_path_b', NULL),
	('colors', '0'),
	('showquery', '0'),
    ('misc_only','0'),
    ('tmux_patch', '0');

DELIMITER $$
CREATE TRIGGER check_insert BEFORE INSERT ON releases FOR EACH ROW BEGIN IF NEW.searchname REGEXP '[a-fA-F0-9]{32}' OR NEW.name REGEXP '[a-fA-F0-9]{32}' THEN SET NEW.bitwise = ((NEW.bitwise & ~512)|512);ELSEIF NEW.name REGEXP '^\\[[[:digit:]]+\\]' THEN SET NEW.bitwise = ((NEW.bitwise & ~1024)|1024); END IF; END; $$
CREATE TRIGGER check_update BEFORE UPDATE ON releases FOR EACH ROW BEGIN IF NEW.searchname REGEXP '[a-fA-F0-9]{32}' OR NEW.name REGEXP '[a-fA-F0-9]{32}' THEN SET NEW.bitwise = ((NEW.bitwise & ~512)|512);ELSEIF NEW.name REGEXP '^\\[[[:digit:]]+\\]' THEN SET NEW.bitwise = ((NEW.bitwise & ~1024)|1024); END IF; END; $$
DELIMITER ;

UPDATE releases set bitwise = 0;
UPDATE releases SET bitwise = ((bitwise & ~512)|512) WHERE searchname REGEXP '[a-fA-F0-9]{32}' OR name REGEXP '[a-fA-F0-9]{32}';
UPDATE releases SET bitwise = ((bitwise & ~1024)|1024) WHERE name REGEXP '^\\[[[:digit:]]+\\]';





