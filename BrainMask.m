% BrainMask.m binarizes an fMRI brain volume
% author: mason simon (mgsimon@princeton.edu) renamed by NTB


function mask = BrainMask(volume,grow,recede)
% volume is a 3D matrix of BOLD fMRI signals
% grow is an integer giving the number of voxels to expand the mask by. if
%   negative, the mask is contracted by this amount.

dims = size(volume);

% cluster the volume into 2 clusters: background (bg) and brain voxels
K = 2;
bg_mean = 0;
brain_mean = max(volume(:))/2;
[index means] = kmeans(volume(:), K, 'start', [bg_mean; brain_mean]);
mask = reshape(index-1, dims);

% expand or contract the mask by taking the max or min of a neighborhood
% extending around each voxel by grow number of voxels.
if grow ~= 0
    R = abs(grow)+1;
    D = R*2 - 1;

    % see ordfilt2 documentation to understand what ord is for.
    if grow < 0
        ord = 1;
    elseif grow > 0
        ord = D^2;
    else
        error('something is amiss');
    end
    
    for i = 1:dims(3)
        mask(:, :, i) = ordfilt2(squeeze(mask(:, :, i)), ord, ones(D,D));
    end
end

if recede
    maskRecede = zeros(size(mask));
    for i = 1:64
        
        if i==1
            iInd = (i):(i+1);
        elseif i==64
            iInd = (i-1):(i);
        else
            iInd = (i-1):(i+1);
        end
        
        for j = 1:64
            
            if j==1
                jInd = (j):(j+1);
            elseif j==64
                jInd = (j-1):(j);
            else
                jInd = (j-1):(j+1);
            end
            
            for k = 1:36
                
                if k==1
                    kInd = (k):(k+1);
                elseif k==36
                    kInd = (k-1):(k);
                else
                    kInd = (k-1):(k+1);
                end
                
                tempCube = 0;
                tempCube = mask(iInd,jInd,kInd);
                
                if sum(sum(sum(tempCube)))<numel(tempCube)
                    maskRecede(i,j,k) = 0;
                else
                    maskRecede(i,j,k) = 1;
                end
                
            end
        end
    end
else
    maskRecede = mask;
end

mask = logical(maskRecede);
    
end