%%Run after rawimgtoalignmask
%Sample specific data input here and in shiftcentroid()
%yfp=850 cfp=700
%561=730 640=810
clear all
n=input('How many fluorescent proteins in this system?');
ythresh=850;
cthresh=700;
rthresh=730;
frthresh=810;
mkdir voronoi
mpath=fullfile(pwd,'masks');
impath=fullfile(pwd,'testout');
  for p = 1:numel(dir('Ilastik'))-2% don't need to skip the first one
        imfn = sprintf('merge_f%04d.tif',p);
        posstr=sprintf('%04d',p);
        mfn = sprintf('mask_f%04d.tif',p);
        imfile = [impath,filesep,imfn];
        mfile = [mpath,filesep,mfn];
        info2 = imfinfo(imfile);
        imageStack = [];
        numberOfImages = length(info2);
        s=strel('diamond',10);
        for k = 1:numberOfImages
            currentImage = imread(imfile, k, 'Info', info2);
            dampImg=imopen(currentImage,s);
            currentImage=imsubtract(currentImage, dampImg);
            imageStack(:,:,k) = currentImage;
        end
        mask=imread(mfile);
        k=whos('mask');
        [voronoi, centers] = voronoiPolygon(mask,k.size(1),k.size(2));
        new_mask = voronoiMaskIntersection(voronoi, mask);
        imshow(new_mask);
        cc3 = bwconncomp(new_mask);
        imwrite(new_mask,fullfile(pwd,'voronoi',['voronoi_f' posstr '.tif']))
        xfpdata(p).centroid = regionprops(cc3,imageStack(:,:,1),'Centroid'); %try removing imageStack (:,:,1)
        dimsy(p)=size(new_mask,1);
        dimsx(p)=size(new_mask,2);
        xfpdata(p).bfp = regionprops(cc3,imageStack(:,:,1),'MeanIntensity');
        xfpdata(p).cfp = regionprops(cc3,imageStack(:,:,4),'MeanIntensity');
        if n==3
             xfpdata(p).yfp = regionprops(cc3,imageStack(:,:,5),'MeanIntensity');
        end
        xfpdata(p).r1= regionprops(cc3, imageStack(:,:,2), 'MeanIntensity');
        xfpdata(p).r2= regionprops(cc3, imageStack(:,:,(6+n-2)), 'MeanIntensity');
        xfpdata(p).fr1= regionprops(cc3, imageStack(:,:,3), 'MeanIntensity');
        xfpdata(p).fr2= regionprops(cc3, imageStack(:,:,(7+n-2)), 'MeanIntensity');
  end 
  %7 by 7 is specific for sample
  dimsx=reshape(dimsx,[7 7])';
  dimsy=reshape(dimsy,[7 7])';
  xfpdataorig=xfpdata;
[xfpdata]=shiftcentroid(dimsx,dimsy,xfpdata);
save('xfpdata','xfpdata');
save('xfpdataorig','xfpdataorig');


    


%% Runtime
    
 function rawvalpic = getrawimg(pos, xfpdata,new_mask)
 l=struct2cell(xfpdata(p).centroid);
        l=l';
        d=cell2mat(l);
        text_str = cell(size(xfpdata(p).r1,1),1);
        for ii=1:size(xfpdata(p).r1,1)
                 text_str{ii,1} = [struct2cell(xfpdata(p).cfp(ii)) ...
                struct2cell(xfpdata(p).yfp(ii)) struct2cell( xfpdata(p).r1(ii))];
            text_str{ii,2} =  [struct2cell(xfpdata(p).fr1(ii)),...
                struct2cell(xfpdata(p).r2(ii)) struct2cell(xfpdata(p).fr2(ii))];
           
        end
       imshow(new_mask, []);
       text(d(:,1)-20,d(:,2), text_str(:,1) ,'Color','red','FontSize',6);
       text(d(:,1)+30,d(:,2), text_str(:,2) ,'Color','red','FontSize',6);
end