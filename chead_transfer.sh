#!/bin/bash
#Author: Anne
#Purpose: transfer everything to chead

# redo things from globals in case you want to transfer from previous subject
subjectNum=12
runNum=1
dayNum=3
scanDate='2/20/20'
transferDicoms=1
copybehav=1

#scanDate='now'
echo "testing params for subject $subjectNum, runNumber $runNum, day $dayNum"
projectName=rtAttenPenn
#dicom_path=/mnt/rtexport/RTexport_Current
dicom_path=/mnt/Data
project_path=/home/amennen/code/rtAttenPenn
# if today's date='now'
# if not today, put 8/10/18
subjName=$(date --date=$scanDate +"%m%d%y")$runNum'_'$projectName
scannerdate=$(date --date=$scanDate +"%Y%m%d")
scanFolder=$dicom_path/$scannerdate'.'$subjName'.'$subjName
echo "subject name is $subjName"
echo "looking for dicoms in $scanFolder"
echo "subject number is $subjectNum, day $dayNum, run $runNum"
# first transfer fmri data

cheadDir=/data/jux/cnds/amennen/rtAttenPenn/fmridata
if [ $transferDicoms -eq 1 ] 
then
    echo "moving data files $scanFolder to $cheadDir"
    #scp -r $scanFolder amennen@chead:$cheadDir/transferredImages/
    rsync -prltD --chmod=Dug+rwx,Dg+s,Fug+rw,o-rwx $scanFolder amennen@chead:$cheadDir/transferredImages/
fi

# transfer all data from subject folder if day number 3 (overwrite if want to anyway)
subject_local_folder=$project_path/data/subject$subjectNum
# copy whatever is in that folder (so it will continually recopy/overwrite other things)
subject_save_path=$project_path/data/subject$subjectNum
if [ $copybehav -eq 1 ]
then
   #scp -r $subject_local_folder amennen@chead:$cheadDir/data/
   echo "moving behav data files from $subject_local_folder to $cheadDir/behavdata/gonogo/"
   rsync -prltD --chmod=Dug+rwx,Dg+s,Fug+rw,o-rwx $subject_local_folder amennen@chead:$cheadDir/behavdata/gonogo/
fi

