#!/usr/bin/env bash
SOURCE="${BASH_SOURCE[0]}"
DIR="$( dirname "$SOURCE" )"
while [ -h "$SOURCE" ]
do
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
    DIR="$( cd -P "$( dirname "$SOURCE"  )" && pwd )"
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

source defaults.sh

for vars in RUNNING TVRAGE OTHERS UNWANTED KEEP_KILLED SEQUENTIAL BINARIES BINARIES_THREADS BACKFILL BACKFILL_THREADS KEVIN_SAFER KEVIN_BACKFILL_PARTS KEVIN_THREADED IMPORT NZB_THREADS IMPORT_TRUE MISC_ONLY RELEASES FIXRELEASES PREDBHASH REQID REMOVECRAP UPPRE PREDB SPOTNAB TV_SCHEDULE SPHINX DELETE_PARTS FIX_POSIX USE_HTOP USE_BWMNG USE_MYTOP USE_ATOP USE_NMON USE_IOTOP USE_VNSTAT USE_TCPTRACK USE_TOP USE_IFTOP USE_CONSOLE POWERLINE RAMDISK CHOWN_TRUE WRITE_LOGS
do
	#echo $vars=\"${!vars}\"
	if [[ ${!vars} != "true" && ${!vars} != "false" ]]; then
		clear
		echo -e "\033[38;5;160m $vars=\"${!vars}\" is not valid. Please edit defaults.sh and correct it. Aborting\033[0m.\n"; exit 1
	fi
done

if ! [[ $NICENESS -le 19 && $NICENESS -ge -20 ]]; then
        clear
	echo -e "\033[38;5;160mNICENESS=$NICENESS is not valid. Please edit defaults.sh and correct it. Aborting\033[0m.\n"; exit 1
fi

for vars in MAX_LOAD MAX_LOAD_RELEASES MONITOR_UPDATE KILL_UPDATES BINARIES_SEQ_TIMER BINARIES_SLEEP BINARIES_MAX_RELEASES BINARIES_MAX_BINS BINARIES_MAX_ROWS BACKFILL_SLEEP BACKFILL_MAX_RELEASES BACKFILL_MAX_BINS BACKFILL_MAX_ROWS MAXDAYS KEVIN_PARTS NZBCOUNT IMPORT_SLEEP IMPORT_MAX_RELEASES IMPORT_MAX_ROWS RELEASES_SLEEP FIXRELEASES_TIMER PREDBHASH_TIMER REQID_TIMER REMOVECRAP_TIMER UPPRE_TIMER PREDB_TIMER SPOTNAB_TIMER TVRAGE_TIMER SPHINX_TIMER DELETE_TIMER
do
	if ! [[ ${!vars} =~ ^[0-9]+([.][0-9]+)?$ ]]; then
                clear
		echo -e "\033[38;5;160m$vars=\"${!vars}\" is not valid. Please edit defaults.sh and correct it. Aborting\033[0m.\n"; exit 1
	fi
done


for vars in NEWZPATH NEWZNAB_PATH TESTING_PATH ADMIN_PATH RAMDISK_PATH
do
	if [ ! -d ${!vars} ]; then
                clear
		echo -e "\033[38;5;160m$vars=\"${!vars}\" is not valid. Please edit defaults.sh and correct it. Aborting\033[0m.\n"; exit 1
	fi
done

for vars in KEVIN_DATE
do
        if ! [[ ${!vars} =~ ^2[0-1][0-9][0-9]-[0-1][0-9]-[0-3][0-9] ]]; then
                clear
                echo -e "\033[38;5;160m$vars=\"${!vars}\" is not valid. Please edit defaults.sh and correct it. Aborting\033[0m.\n"; exit 1
        fi
done

for vars in USER_DEF_ONE USER_DEF_TWO USER_DEF_THREE USER_DEF_FOUR USER_DEF_FIVE
do
	if [[ ${!vars} ]]; then
	        if [[ ! -f $DIR/user_scripts/${!vars} ]]; then
        	        clear
                	echo -e "\033[38;5;160m$vars=\"${!vars}\" is not valid. Please edit defaults.sh and correct it. Aborting\033[0m.\n"; exit 1
		fi
        fi
done

if [[ $IMPORT == "true" ]]; then
	for vars in NZBS
	do
		if [[ ! -d ${!vars} ]]; then
        		clear
        	        echo -e "\033[38;5;160m$vars=\"${!vars}\" is not valid. Please edit defaults.sh and correct it. Aborting\033[0m.\n"; exit 1
        	fi
	done
fi

for vars in SED
do
        if [ ! -f ${!vars} ]; then
                clear
                echo -e "\033[38;5;160m$vars=\"${!vars}\" is not valid. Please edit defaults.sh and correct it. Aborting\033[0m.\n"; exit 1
        fi
done

if [[ $NEWZDASH_URL ]]; then
	cd /tmp
	wget -nv --no-check-certificate $NEWZDASH_URL > /dev/null 2>&1 &
	pid=$!
	wait $!
	script_exit_value=$?
	if [ "${script_exit_value}" -ne "0" ] ; then
		echo -e "\033[38;5;160mNEWZDASH_URL=\"$NEWZDASH_URL\" is not valid. Please edit defaults.sh and correct it. Aborting\033[0m.\n"; exit 1
	fi
fi
