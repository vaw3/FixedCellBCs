%%Debug script
path=pwd;
load xfpdata.mat 
load xfpctrldata.mat
impath=[path,filesep,'testout',filesep];
mpath=[path,filesep,'mergenuclear',filesep];
mkdir('debug')
mkdir(['debug',filesep,'R1'])
mkdir(['debug',filesep,'R2'])
 for p = 1:numel(dir('Ilastik'))-2% don't need to skip the first one
        imfn = sprintf('merge_f%04d.tif',p);
        mfn = sprintf('nuclear_f%04d.tif',p);
        %mfile = [mpath,mfn];
%         imfile = [impath,imfn];
%         mfile = [mpath, mfn];
%         info2 = imfinfo(imfile);
%         imageStack = [];
%         imageStackR2 = [];
        posstr=sprintf('%04d',p);
        [R1img, R2img]=getrawimg(posstr, xfpdata);
%         posstr=sprintf('%04d',p);
%         imageStack(:,:,1)=imread(mfile);
%         imageStack(:,:,2)=R1img;
        imageStack(:,:,1) = imread([mpath mfn]);
        for k = 2:3
            currentImage = imread(imfile, k, 'Info', info2);
            imageStack(:,:,k) = currentImage;
        end
        img=uint16(imageStack);
        writeMultichannel(img,fullfile(['debug',filesep,'R1'],['debugR1_f' posstr '.tif']));
        imageStackR2(:,:,1)=R2  img;
        imageStackR2(:,:,2)=imread(imfile, 1, 'Info', info2);
        for k = 6:7
            currentImage = imread(imfile, k, 'Info', info2);
            imageStackR2(:,:,k-3) = currentImage;
        end
        writeMultichannel(imageStackR2,fullfile(['debug',filesep,'R2'],['debugR2_f' posstr '.tif']));
 end
  function [R1img, R2img] = getrawimg(p, xfpdata)
 l=struct2cell(xfpdata(p).centroid);
        l=l';
        d=cell2mat(l);
        text_str=[struct2cell(xfpdata(1).r1)' struct2cell(xfpdata(1).fr1)'];
       fn1 = [filesep,'mergenuclear',filesep,'nuclear_f',posstr,'.tif'];
       fn1=[pwd fn1];
       a=imread(fn1);
       t=zeros(1024,'logical');
       imshow(a)
       text(d(:,1)-30,d(:,2)-10, text_str(:,1) ,'Color','white','FontSize',6);
       text(d(:,1)-30,d(:,2)+10, text_str(:,2) ,'Color','white','FontSize',6);
       R1img=getframe(gcf);
             l=imfuse(a,R1img.cdata);
       z=rgb2gray(R1img.cdata);
       z=im2uint16(z);
       z=imresize(z, [1024 1024], 'bilinear');
       R1img=z;
       close all
       clear text_str
       text_str=[struct2cell(xfpdata(1).r2)' struct2cell(xfpdata(1).fr2)'];
       imshow(t)
       text(d(:,1)-30,d(:,2)-10, text_str(:,1) ,'Color','white','FontSize',6);
       text(d(:,1)-30,d(:,2)+10, text_str(:,2) ,'Color','white','FontSize',6);
       clear text_str
       R2img=getframe(gcf);
       R2img=getframe(gcf);
       z=rgb2gray(R2img.cdata);
       z=im2uint16(z);
       z=imresize(z, [1024 1024], 'bicubic');
       R2img=z;
       close all
end
