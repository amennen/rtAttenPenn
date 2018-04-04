#!/bin/bash
#Author: Anne
#Purpose: register t1 to standard space
# Things it does
source globals.sh   
echo "subject number is $subjectNum, day $dayNum, run $runNum"
subject_save_path=$project_path/data/subject$subjectNum/day$dayNum/reg
# move into subjects directory
cd $subject_save_path
echo "moving into folder: $subject_save_path"
if [ $dayNum -gt 1 ]
then
	functional2FN=exfunc2
	if [ -f $functional2FN'_'brain.nii.gz ]; then echo "ungzipping epi"; gunzip $functional2FN'_'brain.nii.gz ; fi
	$bxhpath/bxhabsorb $functional2FN'_'brain.nii $functional2FN'_'brain.bxh
	
	if [ -f mask12func2.nii.gz ]; then echo "ungzipping mask"; gunzip mask12func2.nii.gz ; fi
	$bxhpath/bxhabsorb mask12func2.nii mask12func2.bxh
fi
if [ $dayNum -eq 1 ]
then
	functionalFN=exfunc
	if [ -f $functionalFN'_'brain.nii.gz ]; then echo "ungzipping epi"; gunzip $functionalFN'_'brain.nii.gz ; fi
	$bxhpath/bxhabsorb $functionalFN'_'brain.nii $functionalFN'_'brain.bxh

	if [ -f $roi_name'_'exfunc.nii.gz ]; then echo "ungzipping mask"; gunzip $roi_name'_'exfunc.nii.gz ; fi
	$bxhpath/bxhabsorb $roi_name'_'exfunc.nii $roi_name'_'exfunc.bxh
fi
echo "running matlab script to make mask"
cd $project_path
matlab -nodesktop -nodisplay -r "try; makemask_day($subjectNum,$dayNum); catch me; fprintf('%s / %s\n', me.identifier, me.message); end;exit"

echo "done!"
