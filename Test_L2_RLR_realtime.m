function [labelsPredicted,labelsTest,testAccuracy,activations] = Test_L2_RLR_realtime(trainedModel,examplesTest,labelsTest)


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

if any(labelsTest)
    if labelsPredicted == find(labelsTest)
        testAccuracy = 1;
    else
        testAccuracy = 0;
    end
else
    testAccuracy = NaN;
end