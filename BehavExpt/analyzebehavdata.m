
% want to plot: 

% analyze behavioral data
subjectNum =100;
subjectDay = 1;
runNum = 1;
for i = 1:numel(blockData)
    corrresps{i} = [blockData{i}.corrresps];
    resps{i} = [blockData{i}.resps];
    indsTarg{i}=find(corrresps{i}==LEFT);
    indsLure{i}=find(isnan(corrresps{i}));
    hits{i} = corrresps{i}(indsTarg{i})==resps{i}(indsTarg{i});
    hitRate{i} = sum(hits{i})/(numel(indsTarg{i}));
    falseAlarms{i} = isnan(resps{i}(indsLure{i}));
    falseAlarmRate{i} = sum(falseAlarms{i})/numel(indsLure{i});
    Aprime{i} = .5+((hitRate{i}-falseAlarmRate{i})*(1+hitRate{i}-falseAlarmRate{i}))/(4*hitRate{i}*(1-falseAlarmRate{i}));
    fprintf('Run %d A'': %.3f\n',i,Aprime{i});
end