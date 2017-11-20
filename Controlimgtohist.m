clear all
path=pwd;
mergeMultipleMontageDirectories({'ControlR1'},{'ControlR1'},[3 3],3,'control1');
mergeMultipleMontageDirectories({'ControlR2'},{'ControlR2'},[3 3],3,'control2');
mkdir('ctrlmasks');
mkdir('mergectrl');
for ii=1:2
for i=1:1:numel(dir('control1'))-2
    FileTif=sprintf('\\control%d\\merge_f%04d.tif',ii,i);
    FileTif=[pwd FileTif];
    InfoImage=imfinfo(FileTif);
    mImage=InfoImage(1).Width;
    nImage=InfoImage(1).Height;
    a=zeros(nImage,mImage,1,'uint16');
    a=imread(FileTif,'Index',1);
    fctrl=sprintf('\\mergectrl\\ctrl_%d_f%04d.tif',ii,i);
    fctrl=[pwd fctrl];
    imwrite(a, fctrl);
end
end
%% Post Ilastik
for ii=1:2
for pos=1:1:numel(dir('control1'))-2
h5file = sprintf('ctrl_%d_f%04d.h5',ii,pos);
h5tobinmaskFILE(h5file, ii, pos, 2, 1);
end
end

%%
path=pwd;
mpath=[path,'\ctrlmasks\'];
ct=1;
for ii=1:2
    impath=sprintf('\\control%d\\',ii);
    impath=[pwd, impath];
for p = 1:numel(dir('control1'))-2% don't need to skip the first one
        imfn = sprintf('merge_f%04d.tif',p);
        mfn = sprintf('ctrlmask_%d_f%04d.tif',ii,p);
        imfile = [impath,imfn];
        mfile = [mpath,mfn];
        info2 = imfinfo(imfile);
        imageStack = [];
        for k = 1:3
            currentImage = imread(imfile, k, 'Info', info2);
            imageStack(:,:,k) = currentImage;
        end
        mask=imread(mfile);
        k=whos('mask');
        [voronoi, centers] = voronoiPolygon(mask,k.size(1),k.size(2));
        new_mask = voronoiMaskIntersection(voronoi, mask);
        imshow(new_mask);
        cc3 = bwconncomp(new_mask);
        xfpctrldata(ct).centroid = regionprops(cc3,imageStack(:,:,1),'Centroid');
        xfpctrldata(ct).r = regionprops(cc3,imageStack(:,:,2),'MeanIntensity');
        xfpctrldata(ct).fr = regionprops(cc3,imageStack(:,:,3),'MeanIntensity');
        ct=ct+1;
        
       
  
        

        %{
        if (size(cell2mat(struct2cell(xfpdata(p).centroid)),2)<3)
        continue
        end
        getrawimg(pos,xfpdata, new_mask);
        figsave=sprintf('D:\\exp5\\data\\%s\\%s_%02d.jpeg',prefix,prefix,pos);
        saveas(gcf,figsave);       
         %}
    
end 
save('xfpctrldata','xfpctrldata');
end
    
%% Runtime functions
function h5tobinmaskFILE(filename, ii, pos,label,tpt)
    % for identifying what are artifacts
    roundStdThres = 19;%the margin of standard deviation before and after hybridization nuc 1 and 3 and nuc 2 and 4 pictures to identify artifacts
    overallStdThres = 50; % the margin of standard deviation before and after hybridization nuc 1,2,3,4 pictures to identify artifacts
    circleAreaThres = 1550;% the threshold for largest area that the foreign object could be   
    eccenThres = .935;
    
    % for indentifying whether a mask is properly aligned
    CFPThres = 670;% the minimum value of the mean intensity of the mean intensities of a slide for it to be considered properly registered; only for CFP channels
    YFPThres = 720;% the minimum value of the mean intensity of the mean intensities of a slide for it to be considered properly registered; only for YFP channels
    
    [wshedcc] = makemask({filename}, label, tpt); % gets binary mask
    
    ccshedcc = wshedcc;%bwconncomp(wshedcc); % bwconncomp was not working so I am not using it
    fn1 = sprintf('ctrlmask_%d_f%04d',ii,pos);
    imwrite(ccshedcc, ['E:\BrendanTut\Trial_1_9_29_2917\ctrlmasks\',fn1,'.tif'],'Compression','none');
    
end
function [wshedcc] = makemask(filename, label, tpt)
    
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
    t=[p,'\ctrlIlastik\',ilastikfile];
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
        mask2=mask;
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