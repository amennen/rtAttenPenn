function [outputLastPat] = SmoothRealTime(inputLastPat,roiDims,roiInds,FWHM)
% function [outputPatVec] = SmoothRealTime(inputPatVec,roiDims,roiInds,FWHM)
%
% Inputs: 
% - inputLastPat : last pattern acquired [1 x voxels]
% - roiDims      : roi dimensions        [mask width x mask height x slices]
% - roiInds      : roi indices           [= find(mask)];
% - FWHM         : full width half max of gaussian 
%
% Outputs:
% - outputLastPat: smoothed version of last pattern acquired [1 x voxels]
%
%
% MdB, 8/2011

%smoothing parameters 
smooth_kernelsize = [3 3 3]; %[units]
voxel_size = 3; %[mm]
smooth_sigma  = (FWHM/voxel_size)/(2*sqrt(2*log(2)));

%smooth in 3D
inputLastPatVol = zeros(roiDims);

%convert 1D pattern vector to 3D pattern volume
inputLastPatVol(roiInds) = inputLastPat;

%smooth in 3D
inputLastPatVol = smooth3(inputLastPatVol,'gaussian',smooth_kernelsize,smooth_sigma);

%replace in pattern matrix
outputLastPat = inputLastPatVol(roiInds);