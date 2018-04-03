#!/bin/bash
#Author: Anne
#Purpose: register t1 to standard space

# define parameters for subject
subjectNum=8
runNum=1
dayNum=2
#highresScan=2
#functionalScan=4
#dicom_path=/mnt/rtexport/RTexport_Current
highresScan=5
functionalScan=7
dicom_path=/Data1/subjects
#subject_dicom_path=$dicom_path/
projectName=rtAttenPenn

# load bxh and fsl modules or source them in bash rc
bxhpath=/opt/BXH/1.11.1/bin/
#project_path=/home/amennen/code/rtAttenPenn
project_path=/Data1/code/rtAttenPenn
roi_name=wholebrain_mask
