function plot3Dbrain(brainMatrix, mask, titleName)

ndim = ceil(sqrt(size(brainMatrix,3)));
figure
for i = 1:size(brainMatrix,3)
    
    subplot(ndim,ndim,i)
    imagesc(brainMatrix(:,:,i))
    set(gca,'Clim',[0 1])
   % colorbar;
    if exist(mask)
        hold on;
        imagesc(mask(:,:,i));colormap gray;
    end
end
if exist(titleName)
    title(titleName)
end
end