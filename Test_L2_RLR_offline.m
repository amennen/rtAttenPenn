function [labelsPredicted,labelsTest,testAccuracy,activations] = Test_L2_RLR_offline(trainedModel,examplesTest,labelsTest)


%[labelsPredicted,temp,classProbabilities] = svmpredict(labelsTest,examplesTest,libsvmModel,opts);
%testAccuracy = labelsPredicted==labelsTest;

%
if size(examplesTest,2)==1
    examplesTest = transpose(examplesTest);
end

%
nExamples = size(examplesTest,1);

%
activations = exp( examplesTest * trainedModel.weights + repmat(trainedModel.biases,nExamples,1) )' ./ (1+exp( examplesTest * trainedModel.weights + repmat(trainedModel.biases,nExamples,1) )');

[temp,labelsPredicted] = max(activations);

labelsPredicted = transpose(labelsPredicted);

if any(labelsTest)
    tempCorrInd = find(labelsPredicted == find(labelsTest));
    testAccuracy(tempCorrInd) = ones(1,numel(tempCorrInd));
    
    tempIncorrInd = find(labelsPredicted ~= find(labelsTest));
    testAccuracy(tempIncorrInd) = ones(1,numel(tempIncorrInd));
    
else
    testAccuracy = NaN;
end