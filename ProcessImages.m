% ProcessImages.m
%
% This script does various processing steps to raw image files
%   - read
%   - grayscale
%   - resize
%   - adjust intensity
%   - equalize contrast
%   - writes to a new directory, with a new name
%
%
% Written by NTB 2009?
% Edited by MdB 6/2011

%% constants

imgformat = 'jpg';  %reading:   format of image
numrows = 256;      %resize:    number of rows
numcols = 256;      %resize:    number of columns
low_bound = .02;    %intenisty: lower bound of intensity
upper_bound = .98;  %intensity: upper bound of intensity
ntilesrows = 4;     %contrast:  number of tile rows
ntilescols = 4;     %contrast:  number of tile cols
nbins = 512;        %contrast:  number of bins for histogrm
cliplimit = .01;    %contrast:  limit of contrast enhancement


%% set up directories

% where raw files are located 
imFn = 'F_square';
imFn = 'outdoor2';
imFn = 'male_happy_2';
old_root_dir = ['/Volumes/norman/amennen/FINALPENNIMAGES/scenes/'];
% where new files will be written 
new_root_dir = ['/Volumes/norman/amennen/FINALPENNIMAGES/scenes'];

% now 3/8: using for color versions
old_root_dir = ['/Volumes/norman/amennen/FINALPENNIMAGES/instructstim/'];
new_root_dir = ['/Volumes/norman/amennen/FINALPENNIMAGES/instructstim/'];
code_dir = pwd;
cd(old_root_dir);
% subfolders containing image files
%folders =  {'indoor','outdoor','male','female'};
oldfolders = {imFn};
newfolders = {[imFn '_LUMproc_NEW2']};
idealM = 127;
%oldfolders = {'male_happy'};
%newfolders = {'male_happy_proc'}
%% image processing loop 
imageCounter = 0;
for folder=1:length(oldfolders) % loop through each folder 
    fprintf('---------------------------- Processing Folder %s, Folder # %d of %d ---------------------------- \n',oldfolders{folder},folder,length(oldfolders));

    % file directories
    old_folder = fullfile(old_root_dir,oldfolders{folder});
    new_folder = fullfile(new_root_dir,[newfolders{folder}]); 
    assert(strcmp(old_folder,new_folder)==0,'you might overwrite your images!!');
    
    if(~(exist(new_folder,'dir')>0));mkdir(new_folder);end 
    
    % image list within folder
    img_files = dir(old_folder);
    img_files = img_files(3:size(img_files,1),:); %remove . and ..
    if (strcmp(img_files(1).name,'.DS_Store')) %sometimes appears
        img_files = img_files(2:end);
    end
    numImages = size(img_files,1);
    fprintf('---------------------------- %d Images within Folder  ---------------------------- \n',numImages);
        

    for index = 1:size(img_files,1) % loop through each image in the folder 
        imageCounter = imageCounter+1;
        %orig_image = imread(fullfile(old_folder,img_files(index).name),imgformat);
        % changed this because the nimstim files weren't recognized as jpgs
        orig_image = imread(fullfile(old_folder,img_files(index).name));
        % grayscale
        if(size(size(orig_image),2)>2)
            gray_image = rgb2gray(orig_image);
        else
            gray_image = orig_image;
        end
        
        % resize
        imresize_image = imresize(gray_image,[numrows numcols]);
        
        % adjust intensity
        imad_image = imadjust(imresize_image, [low_bound upper_bound], []);
        
        % contrast-limited adaptive histogram equalization 
        imad_eq_image = adapthisteq(imad_image, 'NumTiles', [ntilesrows ntilescols], 'NBins', nbins, 'ClipLimit', cliplimit);
        
        %control luminance
        imad_lum = double(imad_eq_image)/double(max(max(imad_eq_image)));
        
        % write image
        imwrite(imad_lum, [new_folder '/' num2str(imageCounter) '.jpg'], 'jpg');
    end % end image loop
end % end folder loop 

cd(code_dir);