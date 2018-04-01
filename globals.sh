#!/bin/bash
#Author: Anne
#Purpose: register t1 to standard space

# define parameters for subject
subjectNum=8
runNum=1
dayNum=1
highresScan=2
functionalScan=4
dicom_path=/mnt/rtexport/RTexport_Current
subject_dicom_path=$dicom_path/
projectName=rtAttenPenn

# load bxh and fsl modules or source them in bash rc
bxhpath=/opt/BXH/1.11.1/bin/
project_path=/home/amennen/code/rtAttenPenn
roi_name=wholebrain_mask.nii.gz