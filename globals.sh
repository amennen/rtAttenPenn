#!/bin/bash
#Author: Anne
#Purpose: register t1 to standard space

# define parameters for subject
subjectNum=10
# subj 9 is fake data transferred in ~/temp
runNum=2
dayNum=2
#scanDate='1/22/18'
scanDate='now'
echo "testing params for subject $subjectNum, runNumber $runNum, day $dayNum"

#highresScan=2
#functionalScan=4
dicom_path=/mnt/rtexport/RTexport_Current
#dicom_path=/home/amennen/temp
highresScan=6
functionalScan=6
#dicom_path=/Data1/subjects
projectName=rtAttenPenn

# load bxh and fsl modules or source them in bash rc
bxhpath=/opt/BXH/1.11.1/bin/
project_path=/home/amennen/code/rtAttenPenn
#project_path=/Data1/code/rtAttenPenn
roi_name=wholebrain_mask

# if today's date='now'
#subjName=$(date +"%m%d%y")$runNum'_'$projectName
# if not today, put 8/10/18
subjName=$(date --date=$scanDate +"%m%d%y")$runNum'_'$projectName
scannerdate=$(date --date=$scanDate +"%Y%m%d")
scanFolder=$dicom_path/$scannerdate'.'$subjName'.'$subjName

echo "subject name is $subjName"
echo "looking for dicoms in $scanFolder"
