#!/bin/bash
#Author: ACM
#Purpose: transfer behavioral go no go to chead

subjectNum=1
# just each time transfer everything
dayNum=1

echo "trnasferring gaze task data for subject $subjectNum"
projectName=rtAttenPenn
project_path=/Users/amennen/rtAttenPenn/GazeTask
cheadDir=/data/jag/cnds/amennen/rtAttenPenn/gazedata
subject_local_folder=$project_path/data/subject$subjectNum

rsync -prltD --chmod=Dug+rwx,Dg+s,Fug+rw,o-rwx $subject_local_folder amennen@chead:$cheadDir/
