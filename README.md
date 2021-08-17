# Files_for_synbackup_for_UNIX<br />
**Created Date:** 3/14/2018<br />
**Last Updated:** 3/14/2018<br />
**Description:** See README.md for complete details. This contains the files corresponding to KB #2357 which are used as an example of using the synbackup utility.<br />
**Platforms:** Unix<br />
**Products:** Synergy DBL; Synergy DBMS<br />
**Minimum Version:** 10.1.1<br />
**Author:** Galen Carpenter
<hr>

**Additional Information:**
			Using synbackup on Unix or Linux

When backing up Synergy databases, problems can arise if a file is in the
process of being updated when a backup occurs, which may result in a corrupted
file.  To help solve this problem, you can use the Synergy/DE synbackup utility
to freeze the updating of the files, allowing them to be backed up without
corruption.  After the backup is completed, the synbackup utility can thaw
the I/O and allow updates to the files again.  This freeze/thaw process is
called quiesce.

This CodeExchange entry contains several script files to help you automate the
use of synbackup on UNIX.  These files should work with a variety of backup
applications.

	stop_APP.sh and start_APP.sh.  The *_APP scripts do the actual freezing
	and thawing of the Synergy I/O by calling the synbackup utility.
	The *_APP.sh scripts need to be modified to specify the location of
	the setsde script in your Synergy distribution directory.  They
	generate log files (stop_APP.log and start_APP.log) that show the time
	they were run and the output from the synbackup command.

	synbackup (or K30synbackup and S30synbackup for AIX).  These scripts
	execute the synbackup -c command to create the shared memory that
	informs all Synergy programs that I/O is enabled or disabled.  Look at
	the script(s) to verify that DBLDIR is set correctly and the path for
	synbackup is correct.  If you have multiple installations of Synergy on
	the machine, see "If you have multiple installations of Synergy" below.
	The synbackup (or S30synbackup) script should be run automatically
	every time the system starts up.  (K30synbackup is run on shutdown to
	do synbackup -d.)  See "Running the synbackup script at startup" below
	for instructions on the various platforms.

The other script file you need to be concerned with is setsde, which is
included in your Synergy distribution.  To initialize the use of the synbackup
utility, uncomment the setting of the SYNBACKUP environment variable in setsde.
(SYNBACKUP must be set before the synbackup -c command is run.)

How it works:

When the system is booted, the synbackup (or S30synbackup on AIX) script is
run to set the SYNBACKUP environment variable "on" and run the synbackup -c
command, which creates the shared memory.

When a backup is requested, the backup software calls stop_APP.sh, which runs
synbackup -b and then sleeps 10 seconds (to allow the program time to finish
up what it is doing).  Then stop_APP calls synbackup -s to freeze the I/O.

When the backup finished, the backup software calls start_APP.sh to run
synbackup -x to unfreeze the I/O.

If you have multiple installations of Synergy:

When the SYNBACKUP environment variable is set, the runtime looks for the file
DBLDIR:synbackup.cfg, which is created by the synbackup -c command.  If there
are multiple installations of Synergy on the system, each will have DBLDIR set
to its own installation area.  To have all of the installations use the same
shared memory, you need to create a symbolic link to synbackup.cfg in the
DBLDIR directory of each additional installation location.  For example:
"ln -s /usr2/test_1033_32/synergyde/dbl/synbackup.cfg /usr2/test_1033d_32/synergyde/dbl/synbackup.cfg".
Be sure to enable the SYNBACKUP environment variable in the setsde script for
each synergy installation area.

Running the synbackup script at startup:

	Ubuntu: Copy the synbackup script file to /etc/initd and make sure it
	is owned by root with permissions of 777.  Then do
	"/usr/lib/insserv/insserv synbackup" to have the system create the
	appropriate links to the /etc/rc.d/rcN.d files.

	Redhat: Copy the synbackup script file to /etc/initd and make sure it
	is owned by root with permissions of 777.  Then do
	"chkconfig --add synbackup" (that is, dash dash add) and
	"chkconfig --level 2345 synbackup on" (that is, dash dash level).
	The chkconfig command may be located in /sbin.

	AIX: Copy the K30synbackup and S30synbackup scripts to the
	/etc/rc.d/rc2.d directory and modify them for the location of your
	Synergy installation.  The S30synbackup script is for startup and the
	K30synbackup script is for shutdown.  Both have the same contents.  Be
	sure they are owned by root/system with file permissions of 640.

Backup software specific instructions:

These three commonly used backup applications can be modified to work with the
stop_APP.sh and start_APP.sh scripts.

	Semantec NetBackup:
	NetBackup looks for two files, bpstart_notify and bpend_notify, in the
	/usr/openv/netbackup/bin directory.  If it finds them, it executes
	bpstart_notify before the backup starts and bpend_notify after the
	backup has completed.  The CodeExchange zip file includes versions of
	these scripts that we downloaded from
	https://vox.veritas.com/t5/NetBackup/Pre-Post-script-commands-for-backup/td-p/762844.
	The bpstart_notify script calls stop_APP.sh and the bpend_notify scipt
	calls start_APP.sh.  Set APP_SCRIPT_LOCATION in the bp*_notify scripts
	to point to the location of start_APP.sh and stop_APP.sh.  (Because
	synbackup must be run as root, the *_APP scripts are started directly
	by the bash command rather than going through another account.)
	DOLOGGING is set to 1 in the scripts and should be turned off once you
	are done testing and everything is running successfully.  We recommend
	you read through these scripts to see what else they do.

	Veeam Backup & Replication:
	In the "Processing Settings", on the "Scripts" tab for
	"Guest Processing", the location and name of the Pre-freeze and
	Post-thaw scripts need to be filled in with the location of the
	stop_APP.sh and start_APP.sh scripts, respectively.

	Microlite's BackupEdge:
	In the "Backup Domain" under "Advanced Properties" there is a place to
	specify a "Start/Stop Script".  The default is
	/usr/lib/edge/bin/edge.bscript, which is run before and after the
	backup is performed as well as before and after verification of the
	backup.  Microlite does not recommend modifying this script.  At the
	start of a backup, edge.bscript runs the /etc/edge.start script and at
	the conclusion of a successful backup and verify, it runs the
	/etc/edge.passed script.  If the backup or verify fails, the
	/etc/edge.failed script is run.  These three scripts are user
	modifiable.  You can modify /etc/edge.start to run the stop_APP.sh
	script, and then modify /etc/edge.passed and /etc/edge.failed to run
	the start_APP.sh script.  (New releases of BackupEdge replace these
	three scripts and rename the existing files by appending 00 to the
	name, so you won't lose your changes.)

If you are using other backup software you may still be able to use the *_APP
scripts.  Most backup software has a way to specify freezing and thawing of I/O.
Search your backup software's documentation for "quiesce" or "freeze" or "thaw"
to find out how it is specified.  Then configure it to call the stop_APP.sh
script to freeze the file writes and the start_APP.sh script to thaw the file
writes.

(This information is included in KB article 2357.)
