% clear all
% n=input('How many fluorescent proteins in this system?');
% mergeMultipleMontageDirectories({'BCR1','BCR2'},{'BCR3','BCR4'},[7 7],(n+2),'testout');
% %
% mkdir('mergenuclear')
% for i=1:1:numel(dir('testout'))-2
%     FileTif=sprintf('merge_f%04d.tif',i);
%     FileTif=fullfile(pwd,'testout',FileTif);
%     InfoImage=imfinfo(FileTif);
%     mImage=InfoImage(1).Width;
%     nImage=InfoImage(1).Height;
%     NumberImages=length(InfoImage);
%     FinalImage=zeros(nImage,mImage,NumberImages,'uint16');
%         for j=1:NumberImages
%         FinalImage(:,:,j)=imread(FileTif,'Index',j);
%         end
%     a=FinalImage(:,:,1);
%     b=FinalImage(:,:,4);
%     c=imfuse(a,b);
%     if n==3
%         z=FinalImage(:,:,5);
%         c=imfuse(c,z);
%     end
%     d=rgb2gray(c);
%     fimg=sprintf('nuclear_f%04d.tif',i);
%     fimg=fullfile(pwd,'mergenuclear',fimg);
%     imwrite(d,fimg);
% end
%% Post ILASTIK Section makes binary masks
mkdir('masks');
for pos=1:1:numel(dir('Ilastik'))-2
h5file = sprintf('nuclear_f%04d.h5',pos);
h5tobinmaskFILE(h5file, pos, 2, 1);
end
%% Runtime functions
function h5tobinmaskFILE(filename,pos,label,tpt)
    % for identifying what are artifacts
    roundStdThres = 19;%the margin of standard deviation before and after hybridization nuc 1 and 3 and nuc 2 and 4 pictures to identify artifacts
    overallStdThres = 50; % the margin of standard deviation before and after hybridization nuc 1,2,3,4 pictures to identify artifacts
    circleAreaThres = 1550;% the threshold for largest area that the foreign object could be   
    eccenThres = .935;
    
    % for indentifying whether a mask is properly aligned
    CFPThres = 670;% the minimum value of the mean intensity of the mean intensities of a slide for it to be considered properly registered; only for CFP channels
    YFPThres = 720;% the minimum value of the mean intensity of the mean intensities of a slide for it to be considered properly registered; only for YFP channels
    
    [wshedcc] = makemask({filename}, pos, label, tpt); % gets binary mask
    
    ccshedcc = wshedcc;%bwconncomp(wshedcc); % bwconncomp was not working so I am not using it
    fn1 = sprintf('mask_f%04d.tif',pos);
    fn1=fullfile(pwd,'masks',fn1);
    imwrite(ccshedcc, fn1);
    
end

function [wshedcc] = makemask(filename,pos, label, tpt)
    
    [io2, ~]=readmaskfilesKM(filename, label, tpt);% creates the binary mask for that specific
    shortform = filename;
    
    io2DirtRemoved = bwareaopen(io2, 100);% gets rid of small things the program classified as 
    io2MoreFilled = io2DirtRemoved;
    io2MoreFilled = imfill(io2DirtRemoved, 'holes');
    cc = bwconncomp(io2MoreFilled);
    lbio2MoreFilled = bwlabel(io2MoreFilled);
    wshedcc = watershedSegmentation(filename, io2MoreFilled);
end
%
function [io2, pnuc] = readmaskfilesKM(ilastikNucAll,lblN, tpt)
    %[pnuc, inuc] = readmaskfiles1(maskno, segfiledir, rawfiledir, dirinfo, dirinfo1, nzslices, imageno);
    % if all the z slices are separate files
    % if don't have time point will have less-dim .h5 file
    
    % reading masks
    
    %nzslices = size(ilastikNucAll,2);
    
    %for m=1:size(ilastikNucAll,2)  % loop over z slizes
    
    ilastikfile=ilastikNucAll{1};
    p=pwd;
    t=fullfile(p,'Ilastik',ilastikfile);
    io = h5read(t,'/exported_data');
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
    %Read a binary mask from an ilastik probability file
    if ~exist('mask', 'var')
        disp('bbob')
        mask = readmaskfilesKM(mask_path, 2);
        mask = bwareaopen(mask, 100);
    end
    %Find the fused nuclei in the mask and put it into a new mask file
    cc = bwconncomp(mask);
    stats = regionprops(cc, 'Area');
    area = [stats.Area];
    fusedNuclei = area > mean(area) + std(area);
    sublist = cc.PixelIdxList(fusedNuclei);
    sublist = cat(1,sublist{:});
    fusedMask = false(size(mask));
    fusedMask(sublist) = 1;
    %Erode the fused mask to find the centers of the nuclei to be segmented
    s = round(1.2*sqrt(mean(area))/pi);
    if isnan(s)
        return;
    end
    nucmin = imerode(fusedMask,strel('disk',s));
    %Find the area considered to be the background of the fused mask
    outside = ~imdilate(fusedMask,strel('disk',1));
    %Create a basin of minimum values using outside and nucmin
    basin = imcomplement(bwdist(outside));
    basin = imimposemin(basin, nucmin | outside);
    %Do watershed algorithm on the basin
    L = watershed(basin);
    %Combine the masks together into one final mask
    mask2 = L > 1 | (mask - fusedMask);
    %Distinguish out small areas post-watershed
    mask2 = bwareaopen(mask2, 40);
end