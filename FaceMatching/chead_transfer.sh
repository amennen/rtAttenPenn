#!/bin/bash
#Author: ACM
#Purpose: transfer behavioral go no go to chead

ID=3
# have to match subjectnumber to ID number
# subjectNum 1 == RT002
# subjectNum 2 == RT003

# just each time transfer everything
dayNum=1
subjectID=$(printf "%03d" $ID)
echo "transferring faces task data for subject ID $subjectID"
projectName=tfMRI_output
project_path=/Users/amennen/tfMRI_output
cheadDir=/data/jag/cnds/amennen/rtAttenPenn/fmridata/behavdata/faces
subject_local_folder=$project_path/RT$subjectID

rsync -prltD --chmod=Dug+rwx,Dg+s,Fug+rw,o-rwx $subject_local_folder amennen@chead:$cheadDir/
