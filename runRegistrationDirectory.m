%first ff is hyb1 second is hyb2
clear all
dir1= 'C:\Users\svetsa\Desktop\experiment5\masks_tif';
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
numberOfFolders = length(listOfFolderNames);

sn = numberOfFolders - 1; % sn = no. of samples
%%
for samp=2:2:sn-3
    
ff(1) = readAndorDirectory(listOfFolderNames{samp});
ff(2) = readAndorDirectory(listOfFolderNames{samp+1});
FPR1MaskName = [ff(1).prefix '_FPR1mask'];
RegisteredName = [ff(1).prefix '_registered'];
mkdir([RegisteredName])
mkdir([FPR1MaskName])

for pos = 0:80
    %disp(int2str(pos));
    for ww = 0:1 %loop over channels
        img1(:,:,ww+1) = imread(getAndorFileName(ff(1),pos,0,0,ww));
        img2(:,:,ww+1) = imread(getAndorFileName(ff(2),pos,0,0,ww));
    end
    [img_stack, row_s, col_s] = registerTwoImages(img1,img2,1);
    %disp([int2str(row_s) '   ' int2str(col_s)]);
    row_s = row_s+1;
    col_s = col_s+1;
    if(row_s<0||col_s<0)
        [img_stack, row_s, col_s] = registerTwoImages(img2,img1,1);
    end
    if(row_s<0||col_s<0)
        row_s = abs(row_s);
        col_s = abs(col_s);
    end
    if(row_s==0)
        row_s =1;
    end
    if(col_s==0)
        col_s=1;
    end
        
   intersect_img = img_stack(row_s:(end-row_s), col_s:(end-col_s), :); % gets the union of the two registered images
   C = intersect_img(:,:,1);% sets a matrix to the first channel of the multichannel file
   C = imfuse(C, intersect_img(:,:,2));% uses the command imfuse to concatentate the next channel to variable C
   C=rgb2gray(C);
   file1 = sprintf('%sFPR1mask_m%04d.tif', strcat(FPR1MaskName,'\'),pos);
   imwrite(C, file1);%[ff(1).prefix '_FPR1mask\MaskPos_',int2str(pos),'.tif']);
   file2 = sprintf('%sregistered_m%04d.tif',strcat(RegisteredName,'\'), pos)
   writeMultichannel(intersect_img,file2);
end
end
