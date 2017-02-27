function [mask2, L] = watershedSegmentation(mask_path, mask)
    %% Read a binary mask from an ilastik probability file
    if ~exist('mask', 'var')
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
    mask2 = bwareaopen(mask2, 1000);
    %figure;
    %imshow(mask2);
end