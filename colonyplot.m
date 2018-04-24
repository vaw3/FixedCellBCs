%% Colony plotting software
clear all
load xfplineage.mat
load colonydata.mat
t=struct2cell(xfpdata);
% z=squeeze(t);
% z=z';
% ctrs=cell2mat(z(:,1));
% color=z(:,9);
% init=color{1,1};
tmp=xfpdata(1).fid(:);
for i=2:size(xfpdata,2)
    tmp=vertcat(tmp,xfpdata(i).fid(:));
end
init=tmp;
ccode=unique(init);
cnum=size(ccode);
figure
col=colorcube(cnum(1,1));
for i=1:size(xfpdata,2)
    for j=1:size(ccode,1)
        if isempty(find(strcmp(xfpdata(i).fid,ccode{j,1})))
            %fid{j,i}=col((cnum(1,1)+1),:);
            continue
        end
        fid{i,j}=xfpdata(i).centroid(find(strcmp(xfpdata(i).fid,ccode{j,1})),:);
    end
end
mcolor=col(find(strcmp(ccode,colony(1).barcode)),:);
% scatter(colony(1).colonyx,colony(1).colonyy,'*','MarkerFaceColor',mcolor)
% hold on
% viscircles([colony(1).colonyx colony(1).colonyy], colony(1).maxdist,'Color',mcolor);
% for i=2:size(colony,1)/10
%     mcolor=col(find(strcmp(ccode,colony(i).barcode)),:);
%     scatter(colony(i).colonyx,colony(i).colonyy,'*','MarkerFaceColor',mcolor)
%     viscircles([colony(i).colonyx colony(i).colonyy], colony(i).maxdist,'Color',mcolor);
% end
% hold off
% close gcf
%% Plot individual cells
%figure
q=vertcat(fid{:,1});
scatter(q(:,1),q(:,2),'*','MarkerFaceColor',col(1,:))
hold on
i=2;
for i=2:cnum(1)
    q=vertcat(fid{:,i});
    scatter(q(:,1),q(:,2),'*','MarkerFaceColor',col(i,:))
end
hold off
legend(ccode)
close gcf
