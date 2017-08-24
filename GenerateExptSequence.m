function GenerateExptSequence(subjectNum, subjectName, typeNum)
runNum = 1;
rtfeedback = 0;
[blockData patterns] = RealTimePunisherExptSequence(subjectNum,subjectName,runNum,rtfeedback,typeNum);

runNum = 2;
% changing it here for behavioral have rtfeedback = 0
rtfeedback = 1;
[blockData patterns] = RealTimePunisherExptSequence(subjectNum,subjectName,runNum,rtfeedback,typeNum);

runNum = 3;
rtfeedback = 1;
[blockData patterns] = RealTimePunisherExptSequence(subjectNum,subjectName,runNum,rtfeedback,typeNum);

runNum = 4;
rtfeedback = 1;
[blockData patterns] = RealTimePunisherExptSequence(subjectNum,subjectName,runNum,rtfeedback,typeNum);

runNum = 5;
rtfeedback = 1;
[blockData patterns] = RealTimePunisherExptSequence(subjectNum,subjectName,runNum,rtfeedback,typeNum);

runNum = 6;
rtfeedback = 1;
[blockData patterns] = RealTimePunisherExptSequence(subjectNum,subjectName,runNum,rtfeedback,typeNum);
end
