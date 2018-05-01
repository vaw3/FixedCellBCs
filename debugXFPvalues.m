%%Debug script
clear all
path=pwd;
load xfpdataorig.mat
n=input('How many fluorescent proteins in this system?');
%load xfpctrldata.mat
impath=[path,filesep,'testout',filesep];
xfpdata=xfpdataorig;
mpath=[path,filesep,'voronoi',filesep];
mkdir('debug')
mkdir(['debug',filesep,'R1'])
mkdir(['debug',filesep,'FR1'])
mkdir(['debug',filesep,'R2'])
mkdir(['debug',filesep,'FR2'])
mkdir(['debug',filesep,'FP1'])
mkdir(['debug',filesep,'FP2'])
if n==3
    mkdir(['debug',filesep,'FP3'])
end
for p = 1:numel(dir('Ilastik'))-2% don't need to skip the first one
    if isempty(struct2cell(xfpdata(p).centroid))
        continue
    end
    imfn = sprintf('merge_f%04d.tif',p);
    mfn = sprintf('voronoi_f%04d.tif',p);
    imfile = [impath,imfn];
    mfile = [mpath, mfn];
    info2 = imfinfo(imfile);
    currentImage =[];
    nucfpimg =[];
    nucfpimg(:,:,1) = imread(imfile, 1, 'Info', info2);
    nucfpimg(:,:,2) = imread(imfile, 4, 'Info', info2);
    if n==3
       nucfpimg(:,:,n) = imread(imfile, 5, 'Info', info2);
    end
    for k= 1:2
        currentImage(:,:,k) = imread(imfile, k+1, 'Info', info2);
    end
    for k= 3:4
        currentImage(:,:,k) = imread(imfile, k+n+1, 'Info', info2);
    end
    getrawimg(p,xfpdata,currentImage)
    nucimg(p,xfpdata,nucfpimg,n)
    
    %         img=uint16(imageStack);
    %         for k = 6:7
    %             currentImage = imread(imfile, k, 'Info', info2);
    %             imageStackR2(:,:,k-3) = currentImage;
    %         end
    %         writeMultichannel(imageStackR2,fullfile(['debug',filesep,'R2'],['debugR2_f' posstr '.tif']));
end
function getrawimg(p, xfpdata,rnaimg)
l=struct2cell(xfpdata(p).centroid);
posstr=sprintf('%04d',p);
l=l';
d=cell2mat(l);
text_str=[struct2cell(xfpdata(p).r1)' struct2cell(xfpdata(p).fr1)'];
fn1 = [pwd,filesep,'voronoi',filesep,'voronoi_f',posstr,'.tif'];
fn2 = [pwd,filesep,'mergenuclear',filesep,'nuclear_f',posstr,'.tif'];
b=imread(fn2);
a=imread(fn1);
fusedim=imfuse(a,rnaimg(:,:,1),'ColorChannels',[1 2 0]);
fusedimb=imfuse(b,rnaimg(:,:,2));
imshow(fusedim)
text(d(:,1)-30,d(:,2)-10, text_str(:,1) ,'Color','cyan','FontSize',6,'FontWeight','bold');
saveas(gcf,fullfile(pwd,'debug','R1',['debugR1_f' posstr '.tif']));
close all
fusedim=imfuse(a,rnaimg(:,:,2),'ColorChannels',[1 2 0]);
imshow(fusedim)
text(d(:,1)-30,d(:,2)+10, text_str(:,2) ,'Color','cyan','FontSize',6,'FontWeight','bold');
saveas(gcf,fullfile(pwd,'debug','FR1',['debugFR1_f' posstr '.tif']));
close all
clear text_str
text_str=[struct2cell(xfpdata(p).r2)' struct2cell(xfpdata(p).fr2)'];
fusedim=imfuse(a,rnaimg(:,:,3),'ColorChannels',[1 2 0]);
imshow(fusedim)
text(d(:,1)-30,d(:,2)-10, text_str(:,1) ,'Color','cyan','FontSize',6,'FontWeight','bold');
saveas(gcf,fullfile(pwd,'debug','R2',['debugR2_f' posstr '.tif']));
close all
fusedim=imfuse(a,rnaimg(:,:,4),'ColorChannels',[1 2 0]);
imshow(fusedim)
text(d(:,1)-30,d(:,2)+10, text_str(:,2) ,'Color','cyan','FontSize',6,'FontWeight','bold');
saveas(gcf,fullfile(pwd,'debug','FR2',['debugFR2_f' posstr '.tif']));
close all
end
function nucimg(p, xfpdata,fpimg,n)
l=struct2cell(xfpdata(p).centroid);
posstr=sprintf('%04d',p);
l=l';
d=cell2mat(l);
text_str=[struct2cell(xfpdata(p).bfp)' struct2cell(xfpdata(p).bfp)'];
imshow(fpimg(:,:,1), [])
text(d(:,1)-30,d(:,2)-10, text_str(:,1) ,'Color','cyan','FontSize',6,'FontWeight','bold');
saveas(gcf,fullfile(pwd,'debug','FP1',['debugFP1_f' posstr '.tif']));
clear text_str
close all
text_str=[struct2cell(xfpdata(p).cfp)' struct2cell(xfpdata(p).cfp)'];
imshow(fpimg(:,:,2), [])
text(d(:,1)-30,d(:,2)-10, text_str(:,1) ,'Color','cyan','FontSize',6,'FontWeight','bold');
saveas(gcf,fullfile(pwd,'debug','FP2',['debugFP2_f' posstr '.tif']));
if n==3
    clear text_str
    close all
    text_str=[struct2cell(xfpdata(p).yfp)' struct2cell(xfpdata(p).yfp)'];
    imshow(fpimg(:,:,3), [])
    text(d(:,1)-30,d(:,2)-10, text_str(:,1) ,'Color','cyan','FontSize',6,'FontWeight','bold');
    saveas(gcf,fullfile(pwd,'debug','FP3',['debugFP3_f' posstr '.tif']));
end
end
