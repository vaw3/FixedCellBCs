%Kinshuk wants these to be stored in tiff files but I have made them in
%binary files to make them easier to work with
% CFP=700, YFP=900
function h5tobinmaskdriveSHORT
    %Rename them these files up until the \experiment5 to fit your
    %computer's directory
    
   
    %You must create the processed subfolders yourself for the code to work
    
    %fpr1dir = 'C:\Users\svetsa\Desktop\experiment5\masks_tif\FPR1Masks';
    fpr1dir = 'D:\exp5\Composite';
    ildir = 'D:\exp5\Ilastik';
    %processedir = 'C:\Users\svetsa\Desktop\experiment5\masks_tif\processed_pos';
    processedir = 'D:\exp5\processed_pos';
    %exp5dir= 'C:\Users\svetsa\Desktop\experiment5\masks_tif\registered_tifs'; 
    exp5dir= 'D:\exp5\Multi'; 
    bwmask = 'D:\exp5\bwmask';
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
    
    for(p = 1:(length(fpr1subFolders)-1))% don't need to skip the first one
    %for this cell array because the first is the not the same as the
    %parent folder
   
    fpr1subFoldersDir = readAndorDirectory(strcat(fpr1dir,'\',fpr1subFolders{p}));%gets directory for that 
        for(pos = 0:length(fpr1subFoldersDir.m)-1)
            prefix = fliplr(strtok(fliplr(fliplr(strtok(fliplr(fpr1subFolders{p}), '\'))),'_'));%gets the for eg., "D4MTSR_FPR1mask" from the whole file name
           
            h5file = sprintf('%s\\%s_f%04d.h5',strcat(ildir,'\',fpr1subFolders{p}),fpr1subFolders{p}, pos);% gets the h5 file probability file
            exp5FolderNames{p+1}
            procsubFolders{p+1}
            fpr1subFoldersDir
            h5tobinmaskFILE(h5file, pos, 2, 1, exp5FolderNames{p+1}, procsubFolders{p+1}, fpr1subFoldersDir,p);
            
        end 
        
     end 
  save('D:\exp5\misaligned','misaligned')
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
function h5tobinmaskFILE(filename,pos,label, tpt, exp5BMdir, processedir, fpr1cleandir,sampct)
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
    
end
%% Runtime functions
function [wshedcc, titleBW] = makemask(filename,pos, label, tpt)
    
    [io2, ~]=readmaskfilesKM({filename}, label, tpt);% creates the binary mask for that specific
    shortform = filename;
    
    titleBW = BWname(shortform, pos,tpt,'','_BI.tiff');%name of the file
    io2DirtRemoved = bwareaopen(io2, 100);% gets rid of small things the program classified as 
    io2MoreFilled = io2DirtRemoved;
    io2MoreFilled = imfill(io2DirtRemoved, 'holes');
    cc = bwconncomp(io2MoreFilled);
    lbio2MoreFilled = bwlabel(io2MoreFilled);
    wshedcc = watershedSegmentation(filename, io2MoreFilled);
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
        mask = bwareaopen(mask, 100);
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
    if isnan(s)
        return;
    end
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