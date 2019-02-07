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
OUT_PATH=~/Desktop/twitter/out
GNUTERM=jpeg
GNUPLOT=/opt/local/bin/gnuplot
TwtFile=~/Desktop/twitter/out/trumptweets2019.txt
#--------------------------------
proj=$(tail -n 1 $TwtFile | awk '{print $6}')
$GNUPLOT <<-EOT
        set terminal jpeg
        set output "${OUT_PATH}/donnytweets2019.jpeg"
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
