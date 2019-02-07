#!/bin/bash
#
#-------------------------------
SCRIPT_PATH=~/Desktop/twitter/src
if [ $HOSTNAME == "omega.met.tamu.edu" ] ; then
  MATLAB=/usr/local/bin/matlab
fi
#MATLAB=/Applications/MATLAB_R2015b.app/bin//matlab
#MATLAB=/usr/local/bin/matlab
$MATLAB -nodisplay -nodesktop -r "cd('${SCRIPT_PATH}');gettweets; quit"
