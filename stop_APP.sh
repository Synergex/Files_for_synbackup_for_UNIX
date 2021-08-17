function log {
  LOGDT=`date "+%d/%m/%Y %H:%M:%S"`
  echo "$LOGDT  $1">>"$FILELOG"
}

SCRIPT_PATH="`dirname $0`"
SCRIPT_PATH="`readlink -f ""$SCRIPT_PATH""`"
SCRIPT_NAME="`basename $0`"
SCRIPT_NAME="${SCRIPT_NAME%%.*}"
FILELOG="$SCRIPT_PATH/$SCRIPT_NAME.log"

# Specify the location of the Synergy installation
SYNLOC="/usr2/test1033d_32/synergyde"

STS=0
isroot=`id | grep root`
if [ $? -ne 0 ]; then
  log "You must be logged in as root to run this script!"
  STS=-1
else
  if [ -f $SYNLOC/setsde ] ; then
    # Note: remember to un-comment the setting of SYNBACKUP in setsde
    #       or it will not work!
    . $SYNLOC/setsde
    if [ "$SYNBACKUP" = "1" ] ; then
      # Set synbackup to pending and wait 10 seconds to allow updates to finish
      log "synbackup -b"
      $DBLDIR/bin/synbackup -b >>"$FILELOG"
      sleep 10
      # Now turn on synbackup to disallow updates (Freeze)
      log "synbackup -s"
      $DBLDIR/bin/synbackup -s >>"$FILELOG"
      STS=$?
    else
      log "SYNBACKUP is not set. Freeze of updates not enabled."
      STS=-1
    fi
  else
    log "setsde not found in $SYNLOC"
    STS=-1
  fi
fi
exit $STS
