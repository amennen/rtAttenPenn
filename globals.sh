#!/bin/bash
#Author: Anne
#Purpose: register t1 to standard space

# define parameters for subject
subjectNum=114
# subj 9 is fake data transferred in ~/temp
runNum=1
dayNum=3
#scanDate='1/22/18'
scanDate='now'
echo "testing params for subject $subjectNum, runNumber $runNum, day $dayNum"

#dicom_path=/mnt/rtexport/RTexport_Current
dicom_path=/mnt/Data
highresScan=5
functionalScan=6
#dicom_path=/Data1/subjects
projectName=rtAttenPenn
echo "highres scan set as $highresScan, functional scan set as $functionalScan"
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
