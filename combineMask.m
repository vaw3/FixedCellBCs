function [newMask, mask1, mask2] = combineMask(image_path_cell)
    if size(image_path_cell, 2) == 1
        mask1 = readmaskfilesKM(image_path_cell(1), 2);
        mask1 = bwareaopen(mask1, 1000);
        mask1 = imdilate(mask1,strel('disk',3));
        mask1 = imerode(mask1,strel('disk',3));
        mask1 = watershedSegmentation('', mask1);
        newMask = bwareaopen(mask1, 1000);
    else
        mask1 = readmaskfilesKM(image_path_cell(1), 2);
        mask2 = readmaskfilesKM(image_path_cell(2), 2);
        mask1 = bwareaopen(mask1, 1000);
        mask2 = bwareaopen(mask2, 1000);
        mask1 = imdilate(mask1,strel('disk',3));
        mask2 = imdilate(mask2,strel('disk',3));
        mask1 = imerode(mask1,strel('disk',3));
        mask2 = imerode(mask2,strel('disk',3));
        mask1edge = imdilate(mask1,strel('disk',1)) - mask1;
        mask2edge = imdilate(mask2,strel('disk',1)) - mask2;
        [mask1, L1] = watershedSegmentation('', mask1);
        [mask2, L2] = watershedSegmentation('', mask2);
        newMask = mask1 + mask2 - (((L1 == 0) - mask1edge) > 0) - (((L2 == 0) - mask2edge) > 0);
        newMask = newMask > 0;
        newMask = bwareaopen(newMask, 1000);
        newMask = imfill(newMask, 'holes');
    end
end