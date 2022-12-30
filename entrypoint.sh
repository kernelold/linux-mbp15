#!/bin/bash
#set -x 
USER=builder
rjobs=$(grep processor  /proc/cpuinfo  | tail -1 | awk '{print $3}' )
if [ "$rjobs" -eq 0 ] ; then
   rjobs=8
fi
#echo "=== CPUINFO ==="
#cat /proc/cpuinfo
#echo "==============="
jobs=$((rjobs + 3 ))
#echo "Make with $jobs jobs"
export MAKEFLAGS="$MAKEFLAGS -j${jobs}"
su $USER -c ' '"$*"' ' 
