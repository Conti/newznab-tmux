DROP TABLE IF EXISTS prehash;
CREATE TABLE prehash (
	ID INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
	title VARCHAR(255) NOT NULL DEFAULT '',
	nfo VARCHAR(255) NULL,
	size VARCHAR(50) NULL,
	category VARCHAR(255) NULL,
	predate DATETIME DEFAULT NULL,
	adddate DATETIME DEFAULT NULL,
	source VARCHAR(50) NOT NULL DEFAULT '',
	md5 VARCHAR(255) NOT NULL DEFAULT '0',
	requestID INT(10) UNSIGNED NOT NULL DEFAULT '0',
	groupID INT(10) UNSIGNED NOT NULL DEFAULT '0',
	PRIMARY KEY (ID)
) ENGINE=MYISAM DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci AUTO_INCREMENT=1 ;

CREATE INDEX ix_prehash_title ON prehash(title);
CREATE INDEX ix_prehash_nfo ON prehash(nfo);
CREATE INDEX ix_prehash_predate ON prehash(predate);
CREATE INDEX ix_prehash_adddate ON prehash(adddate);
CREATE INDEX ix_prehash_source ON prehash(source);
CREATE INDEX ix_prehash_requestid on prehash(requestID, groupID);
CREATE UNIQUE INDEX ix_prehash_md5 ON prehash(md5);