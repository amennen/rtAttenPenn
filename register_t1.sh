#!/bin/bash
#Author: Anne
#Purpose: register t1 to standard space
# Things it does
# 1. skull strip data
# 2. register to standard space
# 3. invert transformation

# define parameters
subjectNum=8
subjectName=# figure out how to put this here
runNum=1
dayNum=1
highresScan=2

project_path=/home/amennen/code/rtAttenPenn
subject_save_path=$project_path/data/subject$subjectNum/day$dayNum/reg
dicom_path=/mnt/rtexport/RTexport_Current
subject_dicom_path=$dicom_path/

