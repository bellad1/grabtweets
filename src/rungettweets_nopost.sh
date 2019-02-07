#!/bin/bash
#-------------------------------
#
#
#-------------------------------
# Copyright and contact information
#  Copyright:
#   Name          (initials)   year    contact-information
#   Adam Bell     AB           2018    bellad1@tamu.edu
#
#-------------------------------
# Revision History
#  2018.07.20 AB Wrote
#  2018.07.27 AB Added gnuplot for output
#-------------------------------
# This program is free software: you can redistribute it and/or modify
# it under the terms of the Apache Licence, Version 2.0 (the "Licence").
# When you redistribute the program with modifications, you must add your
# name and your initials to "Copyright and contact information" section
# and briefly explain the modification in the "Revision History",
# or take other appropriate means in compliance with the Licence.
#
# This program is Licenced under the Apache Licence, Version 2.0;
# you may not use this file except in compliance with the Licence.
# You may obtain a copy of the Licence at
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the Licence is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the Licence for the specific language governing permissions and
# limitations under the License.
#--------------------------------
SCRIPT_PATH=~/Desktop/twitter/src
OUT_PATH=~/Desktop/twitter/out/figs
#MATLAB=/Applications/MATLAB_R2015b.app/bin//matlab
MATLAB=/usr/local/bin/matlab
GNUTERM=svg
#GNUPLOT=/opt/local/bin/gnuplot
GNUPLOT=/usr/bin/gnuplot
TwtFile=~/Desktop/twitter/out/trumptweets2019.txt
DumpFile=~/Desktop/twitter/dump/dumpfile
#--------------------------------
#$MATLAB -nodisplay -nodesktop -r "run ~/Desktop/twitter/gettweets_nopost.m; quit" >> ~/Desktop/twitter/dump/dumpfile
$MATLAB -nodisplay -nodesktop -r "cd('${SCRIPT_PATH}');gettweets_nopost; quit" >> $DumpFile
proj=$(tail -n 1 $TwtFile | awk '{print $6}')
$GNUPLOT <<-EOT
        set terminal svg
        set output "${OUT_PATH}/donnytweets2019.svg"
        set xdata time
        set timefmt "%Y-%m-%d"
        set format x "%m-%d"
        set xtics rotate by 270
        set xlabel "Time (MM-dd)" 
        set ylabel "Average Tweets per Day"
        set title "Trump Tweet Stats (2019) \n Projected total: $proj"
        unset key
        set grid
        plot "$TwtFile" using 1:5 with linesp lt 1 pt 7 
EOT
