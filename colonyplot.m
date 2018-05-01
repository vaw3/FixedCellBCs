%% Colony plotting software
clear all
load xfplineage.mat
%load colonydata.mat
n=input('Graph 1. Colony with distance, 2. All cells with scatter 3. Both');
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

if n==1 || n==3
    mcolor=col(find(strcmp(ccode,colony(1).barcode)),:);
    figure
    scatter(colony(1).colonyx,colony(1).colonyy,'*','MarkerFaceColor',mcolor)
    hold on
    viscircles([colony(1).colonyx colony(1).colonyy], colony(1).maxdist,'Color',mcolor);
    for i=2:size(colony,1)/10
        mcolor=col(find(strcmp(ccode,colony(i).barcode)),:);
        scatter(colony(i).colonyx,colony(i).colonyy,'*','MarkerFaceColor',mcolor)
        viscircles([colony(i).colonyx colony(i).colonyy], colony(i).maxdist,'Color',mcolor);
    end
    hold off
    saveas(gcf,'Colonywithrange.fig')
    close gcf
end
%% Plot individual cells
if n==2 || n==3
figure
q=vertcat(fid{:,1});
scatter(q(:,1),q(:,2),'*','MarkerFaceColor',col(1,:));
hold on
i=2;
for i=2:cnum(1)
    q=vertcat(fid{:,i});
    scatter(q(:,1),q(:,2),'*','MarkerFaceColor',col(i,:));
end
hold off
legend(ccode)
saveas(gcf,'ScatterCelllineages.fig')
close gcf
figure
for i=1:cnum(1)
    q=vertcat(fid{:,i});
    subplot(round(sqrt(cnum(1))),round(sqrt(cnum(1))),i)
    scatter(q(:,1),q(:,2),'*','MarkerFaceColor',col(i,:))
end
end
