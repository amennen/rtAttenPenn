#!/bin/bash
#Author: Anne
#Purpose: register t1 to standard space
# Things it does
# 1. skull strip data
# 2. register to standard space
# 3. invert transformation
# input is if you're running it the first time and have to convert from dicoms

source globals.sh   
echo "subject number is $subjectNum, day $dayNum, run $runNum"
subject_save_path=$project_path/data/subject$subjectNum/day$dayNum/reg
# move into subjects directory
mkdir -pv $subject_save_path
cd $subject_save_path
echo "moving into folder: $subject_save_path"

subjName=$(date +"%m%d%y")$runNum'_'$projectName
echo "subject name is $subjName"
scannerdate=$(date +"%Y%m%d")
scanFolder=$dicom_path/$(date +"%Y%m%d")'.'$subjName'.'$subjName
echo "looking for dicoms in $scanFolder"

# Process t1-weighted MPRAGE and check brain extraction!
highresFN=highres
highresfiles_genstr=$(printf "%s/001_0000%02d_0*" "$scanFolder" "$highresScan")
if [ $1 -eq 1 ]
then
	mkdir -pv $subject_save_path/tempdcm
	cp $highresfiles_genstr $subject_save_path/tempdcm/
	dcm2niix -f highres -o $subject_save_path/ -z y $subject_save_path/tempdcm/
	rm $subject_save_path/tempdcm/*
fi

bet $highresFN.nii.gz $highresFN'_'brain.nii.gz -R -m 

fslview $highresFN.nii.gz $highresFN'_'brain.nii.gz &
echo "copying this version of file into subject folder for safe keeping!"
mkdir -pv $project_path/data/subject$subjectNum/usedscripts/
cp $project_path/skullstrip_t1.sh $project_path/data/subject$subjectNum/usedscripts/skullstrip_T1.sh
echo "done!"
