%%Run after rawimgtoalignmask
%yfp=850 cfp=700
%561=730 640=810
function masterBC
ythresh=850;
cthresh=700;
rthresh=730;
frthresh=810;
path=pwd;
mpath=[path,'\masks\'];
impath=[path,'\testout\'];
  for p = 1:numel(dir('Ilastik'))-2% don't need to skip the first one
        imfn = sprintf('merge_f%04d.tif',p);
        mfn = sprintf('mask_f%04d.tif',p);
        imfile = [impath,imfn];
        mfile = [mpath,mfn];
        info2 = imfinfo(imfile);
        imageStack = [];
        numberOfImages = length(info2);
        for k = 1:numberOfImages
            currentImage = imread(imfile, k, 'Info', info2);
            imageStack(:,:,k) = currentImage;
        end
        mask=imread(mfile);
        k=whos('mask');
        [voronoi, centers] = voronoiPolygon(mask,k.size(1),k.size(2));
        new_mask = voronoiMaskIntersection(voronoi, mask);
        imshow(new_mask);
        cc3 = bwconncomp(new_mask);
        xfpdata(p).centroid = regionprops(cc3,imageStack(:,:,1),'Centroid');
        xfpdata(p).cfp = regionprops(cc3,imageStack(:,:,1),'MeanIntensity');
        xfpdata(p).yfp = regionprops(cc3,imageStack(:,:,2),'MeanIntensity');
        xfpdata(p).r1= regionprops(cc3, imageStack(:,:,3), 'MeanIntensity');
        xfpdata(p).r2= regionprops(cc3, imageStack(:,:,7), 'MeanIntensity');
        xfpdata(p).fr1= regionprops(cc3, imageStack(:,:,4), 'MeanIntensity');
        xfpdata(p).fr2= regionprops(cc3, imageStack(:,:,8), 'MeanIntensity');
        
       
  
        
         for ii=1:size(xfpdata(p).r1,1)
             uid(index+1,1)={pos};
                 if(cell2mat(struct2cell(xfpdata(p).cfp(ii)))>700&&cell2mat(struct2cell(xfpdata(p).cfp(ii)))>850)
                     xfpdata(p).xfpcode(ii,1)={'CY'};
                     xfpdata(p).uicode(ii,1)=32000;
                     uid(index+1,2)={32000};
                     uid(index+1,3)={'O'};
                 elseif(cell2mat(struct2cell(xfpdata(p).cfp(ii)))>700)
                         xfpdata(p).xfpcode(ii,1)={'C'};
                         xfpdata(p).uicode(ii,1)=20000;
                         uid(index+1,2)={20000};
                         uid(index+1,3)={'C'};
                 elseif(cell2mat(struct2cell(xfpdata(p).yfp(ii)))>850)
                         xfpdata(p).xfpcode(ii,1)={'Y'};
                         xfpdata(p).uicode(ii,1)=30000;
                         uid(index+1,2)={30000};
                         uid(index+1,3)={'Y'};
                 else
                     xfpdata(p).xfpcode(ii,1)={'X'};
                     xfpdata(p).uicode(ii,1)=1000;
                     uid(index+1,2)={1000};
                     uid(index+1,3)={'X'};
                 end
                 
                 if(cell2mat(struct2cell(xfpdata(p).r1(ii)))>730&&...
                         cell2mat(struct2cell(xfpdata(p).fr1(ii)))>810&&...
                     cell2mat(struct2cell(xfpdata(p).fr2(ii)))>810)
                     xfpdata(p).rnacode(ii,1)={'134'};
                     xfpdata(p).uicode(ii,1)=xfpdata(p).uicode(ii,1)+431;
                     uid(index+1,2)={table2array(uid(index+1,2))+431};
                     uid(index+1,4)={strcat(table2cell(uid(index+1,3)),{'134'})};
                 elseif(cell2mat(struct2cell(xfpdata(p).r1(ii)))>730&&...
                         cell2mat(struct2cell(xfpdata(p).fr1(ii)))>810)
                     xfpdata(p).rnacode(ii,1)={'13'};
                     uid(index+1,4)={strcat(table2cell(uid(index+1,3)),{'13'})};
                     xfpdata(p).uicode(ii,1)=xfpdata(p).uicode(ii,1)+31;
                     uid(index+1,2)={table2array(uid(index+1,2))+31};
                 elseif(cell2mat(struct2cell(xfpdata(p).r1(ii)))>730&&...
                         cell2mat(struct2cell(xfpdata(p).fr2(ii)))>810)
                     xfpdata(p).rnacode(ii,1)={'14'};
                     uid(index+1,4)={strcat(table2cell(uid(index+1,3)),{'14'})};
                     xfpdata(p).uicode(ii,1)=xfpdata(p).uicode(ii,1)+41;
                     uid(index+1,2)={table2array(uid(index+1,2))+41};
                 elseif(cell2mat(struct2cell(xfpdata(p).fr1(ii)))>810&&...
                         cell2mat(struct2cell(xfpdata(p).fr2(ii)))>810)
                     xfpdata(p).rnacode(ii,1)={'34'};
                     uid(index+1,4)={strcat(table2cell(uid(index+1,3)),{'34'})};
                     xfpdata(p).uicode(ii,1)=xfpdata(p).uicode(ii,1)+34;
                     uid(index+1,2)={table2array(uid(index+1,2))+34};
                 elseif(cell2mat(struct2cell(xfpdata(p).r1(ii)))>730)
                     xfpdata(p).rnacode(ii,1)={'1'};
                     uid(index+1,4)={strcat(table2cell(uid(index+1,3)),{'1'})};
                     xfpdata(p).uicode(ii,1)=xfpdata(p).uicode(ii,1)+1;
                     uid(index+1,2)={table2array(uid(index+1,2))+1};
                 elseif(cell2mat(struct2cell(xfpdata(p).fr1(ii)))>810)
                     xfpdata(p).rnacode(ii,1)={'3'};
                     uid(index+1,4)={strcat(table2cell(uid(index+1,3)),{'3'})};
                     xfpdata(p).uicode(ii,1)=xfpdata(p).uicode(ii,1)+3;
                     uid(index+1,2)={table2array(uid(index+1,2))+3};
                 elseif(cell2mat(struct2cell(xfpdata(p).fr2(ii)))>810)
                     xfpdata(p).rnacode(ii,1)={'4'};
                     uid(index+1,4)={strcat(table2cell(uid(index+1,3)),{'4'})};
                     xfpdata(p).uicode(ii,1)=xfpdata(p).uicode(ii,1)+4;
                     uid(index+1,2)={table2array(uid(index+1,2))+4};
                 else
                     xfpdata(p).rnacode(ii,1)={'0'};
                     uid(index+1,4)={strcat(table2cell(uid(index+1,3)),{'0'})};
                     xfpdata(p).uicode(ii,1)=xfpdata(p).uicode(ii,1);
                     uid(index+1,2)=uid(index+1,2);
                 end
        
              index=index+1;           
           
         end
        %{
        if (size(cell2mat(struct2cell(xfpdata(p).centroid)),2)<3)
        continue
        end
        getrawimg(pos,xfpdata, new_mask);
        figsave=sprintf('D:\\exp5\\data\\%s\\%s_%02d.jpeg',prefix,prefix,pos);
        saveas(gcf,figsave);       
         %}
    
  end 
save('xfpdata','xfpdata');
save('uid','uid');
end
    


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