

function [mat ts] = ReadFile(file_name,dims,brainmask)
%function [mat ts] = ReadFile(file_name,dims,brainmask)
%
%reads file and returns a timestamp of when file was read (approx)
%
%INPUTS:
%-file_name = full file name (including directory)
%-dims      = scalar number, fMRI matrix size (e.g. 64)
%-brainmask = 3D logical volume of brain mask

%mat = MosaicRead(file_name,dims);      % allegra
mat = RealtimeDicomRead(file_name,dims);% skyra

if (size(brainmask,1)>1)
    mat = mat(brainmask);
end
ts = datestr(now,30);



% RealtimeDicomRead.m turns a mosaic image from the scanner into a 3d image (a volume)
% author: MdB 9/2011, derived from MosaicRead.m


function [volume image] = RealtimeDicomRead(filename, slice_dimension)
% filename is the path to the square image
% slice_dimension is the side length of each square sub-image
%
% WARNING: if the image has 2 or more objects separated by an entirely
% blank slice, this function will incorrectly determine the number of
% slices in the mosaic image.

W = slice_dimension;
H = slice_dimension;

image = dicomread(filename);

S = length(image); % length of each side of the mosaic image
N = S/W;           % number of slices per row or column of the image

% the mosaic image can't have fewer than min_slices in it, or the side
% length S would be shorter, and it can't have more than max_slices, or S
% would be greater.
min_slices = (N-1)^2 + 1;
max_slices = N^2;%N^2;

% we allocate enough memory for the case that there are max_slices, build
% up volume slice-by-slice until we have at least min_slices, and then stop
% looking for new slices once we hit an entirely blank one, on the
% assumption that it marks the end of the volume.
volume = nan(W, H, max_slices);
cols = repmat(0:(N-1), N, 1)';
rows = cols';
for i=1:max_slices
    % this is a little cleverness that relies on matlab's column-major
    % ordering of matrices.
    row = rows(i);
    col = cols(i);
    
    x = (col * W) + 1;
    y = (row * H) + 1;
    slice = image(y:(y+H-1), x:(x+W-1));
    if i > min_slices && all(slice(:) == 0)
        break
    end
    volume(:, :, i) = slice;
end

%volume = volume(:, :, 1:(i-1));
%for MosaicRead
%1;
end

end