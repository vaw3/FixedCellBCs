%%Debug script
path=pwd;
load xfpdata.mat 
load xfpctrldata.mat
impath=[path,filesep,'testout',filesep];
mpath=[path,filesep,'voronoi',filesep];
mkdir('debug')
mkdir(['debug',filesep,'R1'])
mkdir(['debug',filesep,'FR1'])
mkdir(['debug',filesep,'R2'])
mkdir(['debug',filesep,'FR2'])
 for p = 1:numel(dir('Ilastik'))-2% don't need to skip the first one
        imfn = sprintf('merge_f%04d.tif',p);
        mfn = sprintf('voronoi_f%04d.tif',p);
        imfile = [impath,imfn];
        mfile = [mpath, mfn];
        info2 = imfinfo(imfile);
        currentImage =[];
        for k= 1:2
          currentImage(:,:,k) = imread(imfile, k+1, 'Info', info2);
        end
        for k= 3:4
          currentImage(:,:,k) = imread(imfile, k+3, 'Info', info2);
        end
        getrawimg(p,xfpdata,currentImage)
        
        img=uint16(imageStack);
        for k = 6:7
            currentImage = imread(imfile, k, 'Info', info2);
            imageStackR2(:,:,k-3) = currentImage;
        end
        writeMultichannel(imageStackR2,fullfile(['debug',filesep,'R2'],['debugR2_f' posstr '.tif']));
 end
 function getrawimg(p, xfpdata,rnaimg)
 l=struct2cell(xfpdata(p).centroid);
 posstr=sprintf('%04d',p);
        l=l';
        d=cell2mat(l);
        text_str=[struct2cell(xfpdata(p).r1)' struct2cell(xfpdata(p).fr1)'];
       fn1 = [filesep,'voronoi',filesep,'voronoi_f',posstr,'.tif'];
       fn2 = [pwd,filesep,'mergenuclear',filesep,'nuclear_f',posstr,'.tif'];
       fn1=[pwd fn1];
       b=imread(fn2);
       a=imread(fn1);
       fusedim=imfuse(a,rnaimg(:,:,1),'ColorChannels',[1 2 0]);
       fusedimb=imfuse(b,rnaimg(:,:,2));
       imshow(fusedim)
       text(d(:,1)-30,d(:,2)-10, text_str(:,1) ,'Color','white','FontSize',6,'FontWeight','bold');
       saveas(gcf,fullfile(pwd,'debug','R1',['debugR1_f' posstr '.tif']));
       close all
       fusedim=imfuse(a,rnaimg(:,:,2),'ColorChannels',[1 2 0]);
       imshow(fusedim)
       text(d(:,1)-30,d(:,2)+10, text_str(:,2) ,'Color','white','FontSize',6,'FontWeight','bold');
       saveas(gcf,fullfile(pwd,'debug','FR1',['debugFR1_f' posstr '.tif']));
       close all
       clear text_str
       text_str=[struct2cell(xfpdata(p).r2)' struct2cell(xfpdata(p).fr2)'];
       fusedim=imfuse(a,rnaimg(:,:,3),'ColorChannels',[1 2 0]);
       imshow(fusedim)
       text(d(:,1)-30,d(:,2)-10, text_str(:,1) ,'Color','white','FontSize',6,'FontWeight','bold');
       saveas(gcf,fullfile(pwd,'debug','R2',['debugR2_f' posstr '.tif']));
       close all
       fusedim=imfuse(a,rnaimg(:,:,4),'ColorChannels',[1 2 0]);
       imshow(fusedim)
       text(d(:,1)-30,d(:,2)+10, text_str(:,2) ,'Color','white','FontSize',6,'FontWeight','bold');
       saveas(gcf,fullfile(pwd,'debug','FR2',['debugFR2_f' posstr '.tif']));
       close all
end
