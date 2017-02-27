%Kinshuk wants these to be stored in tiff files but I have made them in
%binary files to make them easier to work with
% CFP=700, YFP=900
function h5tobinmaskdriveSHORT
    %Rename them these files up until the \experiment5 to fit your
    %computer's directory
    persistent count;
    count=1;
    %You must create the processed subfolders yourself for the code to work
    
    %fpr1dir = 'C:\Users\svetsa\Desktop\experiment5\masks_tif\FPR1Masks';
    fpr1dir = 'D:\exp5\Composite';
    ildir = 'D:\exp5\Ilastik';
    %processedir = 'C:\Users\svetsa\Desktop\experiment5\masks_tif\processed_pos';
    processedir = 'D:\exp5\processed_pos';
    %exp5dir= 'C:\Users\svetsa\Desktop\experiment5\masks_tif\registered_tifs'; 
    exp5dir= 'D:\exp5\Multi'; 
    bwmask = 'D:\exp5\bwmask'
    fpr1subFolders= getSubFolders(fpr1dir);
    %fpr1subFolders = fpr1subFolders(2:2:length(fpr1subFolders));%getSubFolders 
    %also reads in files inside the sub folders and so to get rid of those I do this step
    
    %(This code just gets me the name of the folders inside the fpr1dir)[
    for(bo = 1:length(fpr1subFolders))
        wholefile = fliplr(char(fpr1subFolders{bo}));
        nameofFolder = fliplr(strtok(wholefile, '\'));
        fpr1subFolders{bo} = nameofFolder;
    end    
    fpr1subFolders = fpr1subFolders(2:end);
    %]
    [procsubFolders] = getSubFolders(processedir);%gets the file path of the sub folders and the folder being search
    exp5FolderNames = getSubFolders(exp5dir);
    
    for(p = 5:length(fpr1subFolders))% don't need to skip the first one
    %for this cell array because the first is the not the same as the
    %parent folder
    fpr1subFoldersDir = readAndorDirectory(strcat(fpr1dir,'\',fpr1subFolders{p}));%gets directory for that 
        for(pos = 0:length(fpr1subFoldersDir.m)-1)
            prefix = fliplr(strtok(fliplr(fliplr(strtok(fliplr(fpr1subFolders{p}), '\'))),'_'));%gets the for eg., "D4MTSR_FPR1mask" from the whole file name
           
            h5file = sprintf('%s\\%s_m%04d.h5',strcat(ildir,'\',fpr1subFolders{p}),fpr1subFolders{p}, pos);% gets the h5 file probability file
            exp5FolderNames{p+1}
            procsubFolders{p+1}
            fpr1subFoldersDir
            h5tobinmaskFILE(h5file, pos, 2, 1, exp5FolderNames{p+1}, procsubFolders{p+1}, fpr1subFoldersDir);
            
        end 
        
    end 
  
end
%% Gets File names in directory
function listOfFolderNames = getSubFolders(dir1)
    %copied from kinshuk's code
    allSubFolders = genpath(dir1);
    
    % Parse into a cell array.
    remain = allSubFolders;
    listOfFolderNames = {};
    while true
        [singleSubFolder, remain] = strtok(remain, ';');
        if isempty(singleSubFolder)
            break;
        end
        listOfFolderNames = [listOfFolderNames singleSubFolder];
    end
end

%%
function h5tobinmaskFILE(filename,pos,label, tpt, exp5BMdir, processedir, fpr1cleandir)
    % for identifying what are artifacts
    roundStdThres = 19;%the margin of standard deviation before and after hybridization nuc 1 and 3 and nuc 2 and 4 pictures to identify artifacts
    overallStdThres = 50; % the margin of standard deviation before and after hybridization nuc 1,2,3,4 pictures to identify artifacts
    circleAreaThres = 1550;% the threshold for largest area that the foreign object could be   
    eccenThres = .935;
    
    % for indentifying whether a mask is properly aligned
    CFPThres = 670;% the minimum value of the mean intensity of the mean intensities of a slide for it to be considered properly registered; only for CFP channels
    YFPThres = 720;% the minimum value of the mean intensity of the mean intensities of a slide for it to be considered properly registered; only for YFP channels
    
    [wshedcc, titleBW] = makemask(filename, pos, label, tpt); % gets binary mask
    
    ccshedcc = wshedcc;%bwconncomp(wshedcc); % bwconncomp was not working so I am not using it
    fn1 = sprintf('%s_m%04d', fpr1cleandir.prefix,pos);
    imwrite(ccshedcc, ['D:\exp5\bwmask\',fpr1cleandir.prefix,'\',fn1,'.tif'],'Compression','none');
    
%%
    % gets the different channels of the registered tif file and stores
    % them in a multidimensional array
    ff{1} = readAndorDirectory(exp5BMdir);
    mask = getAndorFileName(ff{1}(1), pos, [], [], []);
    info = imfinfo(mask);
    imageStack = [];
    numberOfImages = length(info);
    for k = 1:numberOfImages
        currentImage = imread(mask, k, 'Info', info);
        imageStack(:,:,k) = currentImage;
    end
%%
    % return the mean intensities in an array for each of the channels of
    % in the image stack
   % [MeanIntensities, centroids] = intensityforAllChannels(imageStack, ccshedcc);
 %   Areas = cell2mat(struct2cell(regionprops(ccshedcc, 'Area')));
    %%
    %{
This finds the artifacts
    artifacts = [];
        for(j = 1:size(MeanIntensities, 2))% iterate through the columns
            eccen = cell2mat(struct2cell(regionprops(ccshedcc, 'Eccentricity'))); % holds the values of how much each object looks like a line 
            if(std(MeanIntensities([1 2], j))<roundStdThres&&std(MeanIntensities([3 4], j))<roundStdThres); % this was found to be the most effective way of removing foreign objects
                if(Areas(j)<=circleAreaThres) % the areas of the artifacts must be smaller than the threshold
                    artifacts= [artifacts j];% stores the index of the artifacts so they can be later removed
                end
            else if(eccen(j)>eccenThres&&(centroids(j,1)>.1*size(ccshedcc, 1))&&(centroids(j,1)<.9*size(ccshedcc, 1))&&(centroids(j,2)>.1*size(ccshedcc, 2))&&(centroids(j,2)<.9*size(ccshedcc, 2)))%gets 
                    %rid of half moon shaped objects becuase those are most 
                    %likely the partial recognition of the artifacts but we
                    %had to be careful of real cells cut off by the
                    %registration along the border so objects near the
                    %border were not considered
                    
                    if(Areas(j)<=circleAreaThres)
                         artifacts= [artifacts j];
                    end      
            end
            end
        end
        %% 
        %this piece of code gets all those artifact objects and gets the
        %rectangle box that encompasses them and sets that equal to zero so
        %they don't show up in the processed image
        boundbox = struct2cell(regionprops(ccshedcc, 'BoundingBox'));
        for(i = artifacts)
            hold on;
            rect = floor(boundbox{i})+1;
            wshedcc([rect(2):(rect(2)+rect(4))],[rect(1): (rect(1)+rect(3))]) = 0;
        end
    %}
    
        %%
        %I check for alignment 
        ct=0;
        if(passThres(ccshedcc, 1, 5, imageStack, CFPThres, pos)&& pos<80)
              %{
             ct=ct+1
                fname = strcat(processedir, '\Pos_',num2str(pos), 'BM.tif');
                imwrite(wshedcc,char(strcat(processedir, '\Pos_',num2str(pos), 'BM.tif')), 'Compression', 'none');
                %copyfile(getAndorFileName(fpr1cleandir, pos, [],[],[]),processedir); % moves the files from the FPR1 Mask folder to the Processed Files Folder
  %}
      end
      
end
%% Runtime functions
function [wshedcc, titleBW] = makemask(filename,pos, label, tpt)
    
    [io2, ~]=readmaskfilesKM({filename}, label, tpt);% creates the binary mask for that specific
    shortform = filename;
    
    titleBW = BWname(shortform, pos,tpt,'','_BI.tiff');%name of the file
    io2DirtRemoved = bwareaopen(io2, 1000);% gets rid of small things the program classified as 
    io2MoreFilled = io2DirtRemoved;
    io2MoreFilled = imfill(io2DirtRemoved, 'holes');
    cc = bwconncomp(io2MoreFilled);
    lbio2MoreFilled = bwlabel(io2MoreFilled);
    wshedcc = watershedSegmentation(filename, io2MoreFilled);
end
%%
function [registeredCleanly] = passThres(ccshedcc, c1, c2, imageStack, thres, pos);
  %{  
      meaninten1 = cell2mat(struct2cell(regionprops(ccshedcc, imageStack(:,:,c1) , 'MeanIntensity')))
     meaninten2 = cell2mat(struct2cell(regionprops(ccshedcc, imageStack(:,:,c2) , 'MeanIntensity')))
     
     if(mean(meaninten1)<thres||mean(meaninten2)<thres) % if mean of the mean intensities is lower than the threshold, then the file was not registered properly
         registeredCleanly = false;
     else
         registeredCleanly = true;
     end  
     
     %}
ans1=regionprops(ccshedcc, imageStack(:,:,c1), 'MeanIntensity');
ans2=regionprops(ccshedcc, imageStack(:,:,c2), 'MeanIntensity');
ans3=regionprops(ccshedcc, imageStack(:,:,c1+1), 'MeanIntensity');
ans4=regionprops(ccshedcc, imageStack(:,:,c2+1), 'MeanIntensity');
g1=cell2mat(struct2cell(ans1));
g2=cell2mat(struct2cell(ans2));
g3=cell2mat(struct2cell(ans3));
g4=cell2mat(struct2cell(ans4));
diff=g1-g2;
diff=diff.^2;
diff=diff.^(0.5);
diff2=g3-g4;
diff2=diff2.^2;
diff2=diff2.^(0.5);
my_cell = sprintf(char(65));
my_cell = strcat(my_cell,num2str(pos+1));
xlswrite('d4mtsrtestcfp.xlsx',diff,1,my_cell);
xlswrite('d4mtsrtestyfp.xlsx',diff2,1,my_cell);
registeredCleanly = true;
pos
end
%%
function [MeanIntensities, centroids] =intensityforAllChannels(imageStack, ccshedcc)
    MeanIntensities = [];
    for(chan  =1:size(imageStack,3))
        hold on;
        meaninten = cell2mat(struct2cell(regionprops(ccshedcc, imageStack(:,:,chan) , 'MeanIntensity')));
        MeanIntensities = [MeanIntensities;meaninten]; %adds the mean intensity list to the matrix
    end
end
%%
function [fname] =BWname (fileloc, pos, t, chan, filetype)
    fname = strcat(fileloc,'_p_',num2str(pos),'_t_',num2str(t),'_c_',num2str(chan),filetype);
end
%%
function [io2, pnuc] = readmaskfilesKM(ilastikNucAll,lblN, tpt)
    %[pnuc, inuc] = readmaskfiles1(maskno, segfiledir, rawfiledir, dirinfo, dirinfo1, nzslices, imageno);
    % if all the z slices are separate files
    % if don't have time point will have less-dim .h5 file
    
    % reading masks
    
    %nzslices = size(ilastikNucAll,2);
    
    %for m=1:size(ilastikNucAll,2)  % loop over z slizes
    
    ilastikfile=ilastikNucAll{1};
    io = h5read(ilastikfile,'/exported_data');
    io = io(lblN,:,:,tpt);% make this into a variable ( which ilastik label to use as signal and which to use as background. the last dimension is time
    io1 = squeeze(io);
    
    %io1_t = io1(:,:,tpt);
    
    pnuc = io1'; % flipped here
    for i=1:3
        io2thresh = pnuc<(0.1+0.1*i);
        %figure
        %imshow(io2thresh)
    end
    io2 = imfill(io2thresh,'holes');
    
    %end
    
end
function [mask2] = watershedSegmentation(mask_path, mask)
    %% Read a binary mask from an ilastik probability file
    if ~exist('mask', 'var')
        disp('bbob')
        mask = readmaskfilesKM({mask_path}, 2);
        mask = bwareaopen(mask, 1000);
    end
    %% Find the fused nuclei in the mask and put it into a new mask file
    cc = bwconncomp(mask);
    stats = regionprops(cc, 'Area');
    area = [stats.Area];
    fusedNuclei = area > mean(area) + std(area);
    sublist = cc.PixelIdxList(fusedNuclei);
    sublist = cat(1,sublist{:});
    fusedMask = false(size(mask));
    fusedMask(sublist) = 1;
    %% Erode the fused mask to find the centers of the nuclei to be segmented
    s = round(1.2*sqrt(mean(area))/pi);
    nucmin = imerode(fusedMask,strel('disk',s));
    %% Find the area considered to be the background of the fused mask
    outside = ~imdilate(fusedMask,strel('disk',1));
    %% Create a basin of minimum values using outside and nucmin
    basin = imcomplement(bwdist(outside));
    basin = imimposemin(basin, nucmin | outside);
    %% Do watershed algorithm on the basin
    L = watershed(basin);
    %% Combine the masks together into one final mask
    mask2 = L > 1 | (mask - fusedMask);
    %% Distinguish out small areas post-watershed
    mask2 = bwareaopen(mask2, 40);
end