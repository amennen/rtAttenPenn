#!/bin/bash
#Author: Anne
#Purpose: register t1 to standard space
# Things it does
# 1. skull strip data
# 2. register to standard space
# 3. invert transformation

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
functionalFN=exfunc
functionalFN_RE=exfunc_re
fileN=6
exfunc_str=$(printf "%s/001_0000%02d_0000%02d.dcm" "$scanFolder" "$functionalScan" "$fileN")
if [ $1 -eq 1 ]
then
	$bxhpath/dicom2bxh $highresfiles_genstr $functionalFN.bxh
	$bxhpath/bxhreorient --orientation=LAS $functionalFN.bxh $functionalFN_RE.bxh  
	$bxhpath/sbxh2analyze --overwrite --analyzetypes --niigz --niftihdr -s $functionalFN_RE.bxh $functionalFN_RE

	# now register to highres!
	exfunc2highres_mat=example_func2highres
	highres2exfunc_mat=highres2example_func
	epi_reg --epi=$functionalFN_RE --t1=$highresFN_RE --t1brain=$highresFN_RE_brain --out=$exfunc2highres_mat
	convert_xfm -inverse -omat $highres2exfunc_mat.mat $exfunc2highres_mat

	# now register mask to all data
	applywarp -i $project_path/$roi_name.nii.gz -r $functionalFN_RE.nii.gz -o $roi_name_exfunc.nii.gz -w standard2highres_warp.nii.gz --postmat=$highres2exfunc_mat 
	# check after here that the applied warp is binary and in the right
	# orientation so we could just apply to nifti files afterwards
	if [ -f $roi_name_exfunc.nii.gz ]; then echo "ungzipping mask"; gunzip $roi_name_exfunc.nii.gz ; fi
	$bxhpath/bxhabsorb $roi_name_exfunc.nii $roi_name_exfunc.bxh
fi

bet $functionalFN_RE.nii.gz$ $functionalFN_RE_brain -R -m
if [ -f $functionalFN_RE_brain.nii.gz ]; then echo "ungzipping epi"; gunzip $functionalFN_RE_brain.nii.gz ; fi
bxhabsorb $functionalFN_RE_brain.nii $functionalFN_RE_brain.bxh

echo "copying this version of file into subject folder for safe keeping!"
mkdir -pv $project_path/data/subject$subjectNum/usedscripts/
cp reg_epi.sh $project_path/data/subject$subjectNum/usedscripts/reg_epi.sh
echo "done!"