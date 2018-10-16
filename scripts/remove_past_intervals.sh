#!/bin/bash
# Program:
#       Remove all pgs' past_intervals for a specified OSD, please use with
#       caution as there is no turning back.

function usage() {
  echo -e "Usage:\n\t $0 [OPTION] <osdid>\t numerical osd id, such as 0,1,2..."
  echo -e "Options\n  -h, --help\t show this help"
  echo -e "  -n, --dry-run\t perform a trial run with no changes made"
  exit $1
}

test $# -eq 0 && usage 1
for opt in $@; do
  case $opt in
    "-n" | "--dry-run")
      DRY_RUN="--dry-run"
      ;;
    "-h" | "--help")
      usage 0
      ;;
    *[!0-9]* | '')
      usage 1
      ;;
    *)
      OSD_NUM=$opt
      ;;
  esac
done

OSD_PATH=/var/lib/ceph/osd/ceph-$OSD_NUM
if [ ! -e $OSD_PATH ]; then
  echo "Error: osd.$OSD_NUM does not exist."
  exit 1
fi

TOOL=`which ceph-objectstore-tool`

echo "start to remove all past_intervals for osd.$OSD_NUM"
PGS=`$TOOL --data-path $OSD_PATH --skip-journal-replay --op list-pgs`
test $? -ne 0 && exit 1

for pg in $PGS; do
  echo "removing osd.$OSD_NUM $pg's past_intervals"
  $TOOL --data-path $OSD_PATH --skip-journal-replay --pgid $pg --op rm-past-intervals $DRY_RUN
  echo
done
