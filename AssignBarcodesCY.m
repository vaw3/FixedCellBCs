%load xfpdata.mat
%Set threshold
clear all
mkdir lineageimg
load xfpdata.mat
tcfp=400; tyfp=400; tbfp=400;
n=input('How many fluorescent proteins in this system?');
tred1=450;tfar1=200;
tred2=450;tfar2=450;
lineages = {'B','Y','1','2','3','4'};
lineagecomb={'B','Y','1','2','3','4','N'};
lineagecomb=string(lineagecomb');
for i=2:6
temp=string(combnk(lineages,i));
switch i
    case 2
        temp=strcat(temp(:,1),temp(:,2));
    case 3
        temp=strcat(temp(:,1),temp(:,2),temp(:,3));
    case 4
        temp=strcat(temp(:,1),temp(:,2),temp(:,3),temp(:,4));
    case 5
        temp=strcat(temp(:,1),temp(:,2),temp(:,3),temp(:,4),temp(:,5));
    case 6
        temp=strcat(temp(:,1),temp(:,2),temp(:,3),temp(:,4),temp(:,5),temp(:,6));
end
lineagecomb= vertcat(lineagecomb,temp);
end
lineageID=categorical(lineagecomb);
for p=1:size(xfpdata,2)
for ii=1:size(xfpdata(p).centroid,1)
    if  cell2mat(struct2cell(xfpdata(p).cfp(ii)))>tcfp
        xfpdata(p).uid(ii,1)=true;
        xfpdata(p).fid(ii,1)='C';
    else
        xfpdata(p).uid(ii,1)=false;
        xfpdata(p).fid(ii,1)=' ';
    end
    if  cell2mat(struct2cell(xfpdata(p).yfp(ii)))>tyfp
        xfpdata(p).uid(ii,2)=true;
        xfpdata(p).fid(ii,2)='Y';
    else
        xfpdata(p).uid(ii,2)=false;
        xfpdata(p).fid(ii,2)=' ';
    end
    if n==3
        if  cell2mat(struct2cell(xfpdata(p).bfp(ii)))>tbfp
            xfpdata(p).uid(ii,n)=true;
            xfpdata(p).fid(ii,n)='B';
        else
            xfpdata(p).uid(ii,n)=false;
            xfpdata(p).fid(ii,n)=' ';
        end
    end
    if  cell2mat(struct2cell(xfpdata(p).r1(ii)))>tred1
        xfpdata(p).uid(ii,3+n-2)=true;
        xfpdata(p).fid(ii,3+n-2)='2';
    else
        xfpdata(p).uid(ii,3+n-2)=false;
        xfpdata(p).fid(ii,3+n-2)=' ';
    end
    if  cell2mat(struct2cell(xfpdata(p).fr1(ii)))>tfar1
        xfpdata(p).uid(ii,4+n-2)=true;
        xfpdata(p).fid(ii,4+n-2)='4';
    else
        xfpdata(p).uid(ii,4+n-2)=false;
        xfpdata(p).fid(ii,4+n-2)=' ';
    end
    if  cell2mat(struct2cell(xfpdata(p).r2(ii)))>tred2
        xfpdata(p).uid(ii,5+n-2)=true;
        xfpdata(p).fid(ii,5+n-2)='1';
    else
        xfpdata(p).uid(ii,5+n-2)=false; 
        xfpdata(p).fid(ii,5+n-2)=' ';
    end
     if cell2mat(struct2cell(xfpdata(p).fr2(ii)))>tfar2
        xfpdata(p).uid(ii,6+n-2)=true;
        xfpdata(p).fid(ii,6+n-2)='3';
    else
        xfpdata(p).uid(ii,6+n-2)=false; 
        xfpdata(p).fid(ii,6+n-2)=' ';
     end
end

%         if (size(cell2mat(struct2cell(xfpdata(p).centroid)),2)<3)
%         continue
%         end
%         posstr=sprintf('%04d.tif',p);
%         getrawimg(p,xfpdata);
%         fn1=[filesep,'lineageimg',filesep,'lineageimg_',posstr];
%         fn1=[pwd fn1];
%         saveas(gcf,fn1);       
         
    
end
for p=1:size(xfpdata,2)
   tmp=xfpdata(p).fid;
   k=cellstr(tmp);
   tmp=strrep(k,' ','');
   xfpdata(p).fid=tmp;
end

save('xfplineage.mat','xfpdata');
%% Runtime

 function rawvalpic = getrawimg(p, xfpdata)
 l=struct2cell(xfpdata(p).centroid);
        l=l';
        posstr=sprintf('%04d',p);
        d=cell2mat(l);
        text_str = cell(size(xfpdata(p).r1,1),1);
        for ii=1:size(xfpdata(p).r1,1)
                 text_str{ii,1} = xfpdata(p).fid(ii,:);           
        end
        fn1=[filesep,'masks',filesep,'mask_f',posstr,'.tif'];
        fn1=[pwd fn1];
       a=imread(fn1);
       imshow(a)
       text(d(:,1)-20,d(:,2), text_str(:,1) ,'Color','cyan','FontSize',6);
end