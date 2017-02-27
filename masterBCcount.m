%%Run after h5tobinmaskdriveSHORT
%yfp=850 cfp=700
%561=730 640=810
function drive
fpr1dir = 'D:\exp5\bwmask';
ildir = 'D:\exp5\Ilastik';
processedir = 'D:\exp5\processed_pos';
exp5dir= 'D:\exp5\Multi';
bwmask = 'D:\exp5\bwmask';
fpr1subFolders= getSubFolders(fpr1dir);
for(bo = 1:length(fpr1subFolders))
    wholefile = fliplr(char(fpr1subFolders{bo}));
    nameofFolder = fliplr(strtok(wholefile, '\'));
    fpr1subFolders{bo} = nameofFolder;
end
ythresh=850;
cthresh=700;
rthresh=730;
frthresh=810;
fpr1subFolders = fpr1subFolders(2:end);
%]
[procsubFolders] = getSubFolders(processedir);%gets the file path of the sub folders and the folder being search
exp5FolderNames = getSubFolders(exp5dir);

for(p = 1:length(fpr1subFolders))% don't need to skip the first one
    %for this cell array because the first is the not the same as the
    %parent folder
    fpr1subFoldersDir = readAndorDirectory(strcat(fpr1dir,'\',fpr1subFolders{p}));%gets directory for that
    for(pos = 0:length(fpr1subFoldersDir.m)-1)
        prefix = fliplr(strtok(fliplr(fliplr(strtok(fliplr(fpr1subFolders{p}), '\'))),'_'));%gets the for eg., "D4MTSR_FPR1mask" from the whole file name
        mfile = sprintf('%s\\%s_m%04d.tif',strcat(fpr1dir,'\',fpr1subFolders{p}),fpr1subFolders{p}, pos);% gets the h5 file probability file
        mask=imread(mfile);
        exp5FolderNames{p+1};
        procsubFolders{p+1};
        fpr1subFoldersDir;
        ff{1} = readAndorDirectory(exp5FolderNames{p+1});
        imfile = getAndorFileName(ff{1}(1), pos, [], [], []);
        info = imfinfo(imfile);
        imageStack = [];
        numberOfImages = length(info);
        for k = 1:numberOfImages
            currentImage = imread(imfile, k, 'Info', info);
            imageStack(:,:,k) = currentImage;
        end

        k=whos('mask');
        [voronoi, centers] = voronoiPolygon(mask,k.size(1),k.size(2));
        new_mask = voronoiMaskIntersection(voronoi, mask);
        cc3 = bwconncomp(new_mask);
        xfpdata(pos+1).centroid = regionprops(cc3,imageStack(:,:,1),'Centroid');
        xfpdata(pos+1).cfp = regionprops(cc3,imageStack(:,:,1),'MeanIntensity');
        xfpdata(pos+1).yfp = regionprops(cc3,imageStack(:,:,2),'MeanIntensity');
        xfpdata(pos+1).r1= regionprops(cc3, imageStack(:,:,3), 'MeanIntensity');
        xfpdata(pos+1).r2= regionprops(cc3, imageStack(:,:,7), 'MeanIntensity');
        xfpdata(pos+1).fr1= regionprops(cc3, imageStack(:,:,4), 'MeanIntensity');
        xfpdata(pos+1).fr2= regionprops(cc3, imageStack(:,:,8), 'MeanIntensity');
  
        %%
         for ii=1:size(xfpdata(pos+1).r1,1)
             pos
                 if(cell2mat(struct2cell(xfpdata(pos+1).cfp(ii)))>700&&cell2mat(struct2cell(xfpdata(pos+1).cfp(ii)))>850)
                     xfpdata(pos+1).xfpcode(ii,1)={'CY'};
                 elseif(cell2mat(struct2cell(xfpdata(pos+1).cfp(ii)))>700)
                         xfpdata(pos+1).xfpcode(ii,1)={'C'};
                 elseif(cell2mat(struct2cell(xfpdata(pos+1).yfp(ii)))>850)
                         xfpdata(pos+1).xfpcode(ii,1)={'Y'};
                 else
                     xfpdata(pos+1).xfpcode(ii,1)={'X'};
                 end
                 
                 if(cell2mat(struct2cell(xfpdata(pos+1).r1(ii)))>730&&...
                         cell2mat(struct2cell(xfpdata(pos+1).fr1(ii)))>810&&...
                     cell2mat(struct2cell(xfpdata(pos+1).fr2(ii)))>810)
                     xfpdata(pos+1).rnacode(ii,1)={'134'};
                 elseif(cell2mat(struct2cell(xfpdata(pos+1).r1(ii)))>730&&...
                         cell2mat(struct2cell(xfpdata(pos+1).fr1(ii)))>810)
                     xfpdata(pos+1).rnacode(ii,1)={'13'};
                 elseif(cell2mat(struct2cell(xfpdata(pos+1).r1(ii)))>730&&...
                         cell2mat(struct2cell(xfpdata(pos+1).fr2(ii)))>810)
                     xfpdata(pos+1).rnacode(ii,1)={'14'};
                 elseif(cell2mat(struct2cell(xfpdata(pos+1).fr1(ii)))>810&&...
                         cell2mat(struct2cell(xfpdata(pos+1).fr2(ii)))>810)
                     xfpdata(pos+1).rnacode(ii,1)={'34'};
                 elseif(cell2mat(struct2cell(xfpdata(pos+1).r1(ii)))>730)
                     xfpdata(pos+1).rnacode(ii,1)={'1'};
                 elseif(cell2mat(struct2cell(xfpdata(pos+1).fr1(ii)))>810)
                     xfpdata(pos+1).rnacode(ii,1)={'3'};
                 elseif(cell2mat(struct2cell(xfpdata(pos+1).fr2(ii)))>810)
                     xfpdata(pos+1).rnacode(ii,1)={'4'};
                 else
                     xfpdata(pos+1).rnacode(ii,1)={'0'};
                 end
        
                         
           
         end
        %{
        if (size(cell2mat(struct2cell(xfpdata(pos+1).centroid)),2)<3)
        continue
        end
        getrawimg(pos,xfpdata, new_mask);
        figsave=sprintf('D:\\exp5\\data\\%s\\%s_%02d.jpeg',prefix,prefix,pos);
        saveas(gcf,figsave);       
         %}
    end
    savename=sprintf('D:\\exp5\\data\\%s\\%s_xfp',prefix,prefix);
    save(savename,'xfpdata');
   end
    
end

    
    %%Runtime
    
 function listOfFolderNames = getSubFolders(dir1)
    %copied from kinshuk's code
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
 end
 function rawvalpic = getrawimg(pos, xfpdata,new_mask)
 l=struct2cell(xfpdata(pos+1).centroid);
        l=l';
        d=cell2mat(l);
        text_str = cell(size(xfpdata(pos+1).r1,1),1);
        for ii=1:size(xfpdata(pos+1).r1,1)
                 text_str{ii,1} = [struct2cell(xfpdata(pos+1).cfp(ii)) ...
                struct2cell(xfpdata(pos+1).yfp(ii)) struct2cell( xfpdata(pos+1).r1(ii))];
            text_str{ii,2} =  [struct2cell(xfpdata(pos+1).fr1(ii)),...
                struct2cell(xfpdata(pos+1).r2(ii)) struct2cell(xfpdata(pos+1).fr2(ii))];
           
        end
       imshow(new_mask, []);
       text(d(:,1)-20,d(:,2), text_str(:,1) ,'Color','red','FontSize',6);
       text(d(:,1)+30,d(:,2), text_str(:,2) ,'Color','red','FontSize',6);
 end