#!/bin/bash
#Author: Anne
#Purpose: register t1 to standard space
# Things it does
source globals.sh   
echo "subject number is $subjectNum, day $dayNum, run $runNum"
subject_save_path=$project_path/data/subject$subjectNum/day$dayNum/reg
# move into subjects directory
mkdir -pv $subject_save_path
#cd $subject_save_path
#echo "moving into folder: $subject_save_path"
echo "running matlab script to make mask"
matlab -nodesktop -nodisplay -r "try; makemask_day($subjectNum,$dayNum); catch me; fprintf('%s / %s\n', me.identifier, me.message); end;exit"

echo "done!"
