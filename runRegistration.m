function runRegistration
clear all
%mkdir('Composite');
%mkdir('Multi');
dir1 = 'D:\exp5\';
%{
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

sn = numberOfFolders - 2; % sn = no. of samples
%}
%%
dim=input('Enter image side length  ')       
ff = readAndorDirectory('D:\exp5\masks_tif\D4BMP');% i made a file in my matlab folder that contains all the masks
ffhyb = readAndorDirectory('D:\exp5\masks_tif\D4BMPHyb2');
fnm=strcat(dir1,'Multi\',ff.prefix);
fnc=strcat(dir1,'Composite\',ff.prefix);
mkdir(fnm)
mkdir(fnc)
disp=[-(dim+1) -dim -(dim-1);-1 0 1;(dim-1) dim (dim+1)];
mapclean=repmat(-1,3,3);
%% The else-if statements within the for loop generate the mapclean matrix that has -1 value for invalid 
%positions and 0 or positive values for the valid positions to be stitched.
for pos =0:1:((dim*dim)-1)       
    %disp(int2str(pos));
    map=disp+pos;
    if (pos==0)
        mapclean(2:3,2:3)=map(2:3,2:3);        
    elseif(pos==dim*dim-1)
        mapclean(1:3,1:2)=map(1:2,1:2);
    elseif(pos==dim-1)
        mapclean(2:3,1:2)=map(2:3,1:2);
    elseif(pos==dim*(dim-1))
        mapclean(1:2,2:3)=map(1:2,2:3);
    elseif(pos<dim)
        mapclean(2:3,1:3)=map(2:3,1:3);
    elseif(mod(pos,dim)==0)
        mapclean(1:3,2:3)=map(1:3,2:3);
    elseif(mod((pos+1),dim)==0)
        mapclean(1:3,1:2)=map(1:3,1:2);
    elseif(pos>=dim*(dim-1))
        mapclean(1:3,1:2)=map(1:2,1:3);
    end

        
        
            
    for ww = 0:3 %loop over channels CHANGE FOR CONTROL
        img1(:,:,ww+1) = imread(getAndorFileName(ff(1),pos,0,0,ww));
        img2(:,:,ww+1) = imread(getAndorFileName(ffhyb(1),pos,0,0,ww));
    end
    [img_stack, row_s, col_s] = registerTwoImages(img1,img2,1); %or the other way
    if(row_s<0||col_s<0)
        [img_stack, row_s, col_s] = registerTwoImages(img1,img2,1);
    end
    if(row_s<0||col_s<0)
        img1p = permute(img1, [2,1, 3]);
        img2p = permute(img2,[2,1,3]);
        [img_stack, row_s, col_s] = registerTwoImages(img1p,img2p,1);
    end
%      if(row_s<0||col_s<0)
%         changex = 200;
%         changey = 100;
%         img1big = zeros(size(img1, 1)+changex,size(img1, 2)+changex,size(img1,3));
%         img1big(changex/2:(changex/2+size(img1,1)-1),changex/2:(changex/2+size(img1,2)-1),:)=img1(:,:,:);
%         
%         img2big = zeros(size(img2, 1)+changex,size(img2, 2)+changex,size(img2,3));
%         size(img2big)
%         img2big(changex/2:(changex/2+size(img2,1)-1),changex/2:(changex/2+size(img2,2)-1),:)=img2;
%         [img_stack, row_s, col_s] = registerTwoImages(img1big,img2big,1);
%         row_s
%         col_s
%     end
    if(row_s<0||col_s<0)
        %disp('pos')
        %pos
        row_s = abs(row_s);
            col_s = abs(col_s);
    end
    row_s = row_s+1;
    col_s = col_s+1;
  
     
    intersect_img = img_stack(row_s:(end-row_s), col_s:(end-col_s), :);% gets the union of the two registered images
    file1 = sprintf('%s_m%04d', ff.prefix,pos);
    if(ww==2)
        intersect_img(:,:,4)=intersect_img(:,:,5);
        intersect_img(:,:,5)=intersect_img(:,:,6);
    end
    writeMultichannel(intersect_img, ['D:\exp5\Multi\',ff.prefix,'\',file1,'.tif']); % writes file to multichannel
    %writeMultichannel(intersect_img, fnm);
    size(intersect_img);
     C = intersect_img(:,:,1);% sets a matrix to the first channel of the multichannel file
   % for a = 2:2
    %    C = imfuse(C, intersect_img(:,:,a));% uses the command imfuse to concatentate the next channel to variable C
    %end
    
%    C = rgb2gray(C);% gets rid of the colors that come in multichannel files
    imwrite(C, ['D:\exp5\Composite\',ff.prefix,'\',file1,'.tif']);
    %imwrite(C, fnc);
    
    
    
end