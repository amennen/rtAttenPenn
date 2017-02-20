function [outputLastPat] = HighPassRealTime(inputAllPats,TR,cutoffTime)
% function [outputLastPat] = HighPassRealTIme(inputAllPats,TR)
%
% this function high pass filters the realtime data
%
% Inputs: 
% - inputAllPats:patterns matrix [time x voxels]
% - TR:          sampling rate   [sec]
% - cutoffTime:  filter cutoff   [sec]
%
% Outputs:
% - outputLastPat:patterns vector [1 x voxels]
%
%MdB, 7/2011


%standard deviation of high pass gaussian
hp_sigma = cutoffTime/(2*TR); %fsl's approximation to calculationg standard deviation

%call mex function to high pass according to fslmaths
[outputAllPats]=highpass_gaussian_realtime(inputAllPats,hp_sigma); 

outputLastPat = outputAllPats(end,:);