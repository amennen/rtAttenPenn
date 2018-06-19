#!/bin/bash
#Author: ACM
#Purpose: transfer behavioral go no go to chead

subjectNum=1
# just each time transfer everything
dayNum=1

echo "trnasferring behavioral gonogo data for subject $subjectNum"
projectName=rtAttenPenn
project_path=/Users/amennen/rtAttenPenn/BehavExpt
cheadDir=/data/jag/cnds/amennen/rtAttenPenn/behavgonogo
subject_local_folder=$project_path/data/subject$subjectNum

rsync -prltD --chmod=Dug+rwx,Dg+s,Fug+rw,o-rwx $subject_local_folder amennen@chead:$cheadDir/
