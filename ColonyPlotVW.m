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
cells=tabulate(tmp); %counts occurances and precent in a list
cells = sortrows(cells,[3],'descend');
A=cells(1:30,1);
cnum=size(A);
col=colorcube(45);
col(31,:) = [];
col(30,:) = [];
col(25,:) = [];
col(21,:) = [];
col(19,:) = [];
col(13,:) = [];
col(11,:) = [];
col(8,:) = [];
col(2,:) = [];
col(28,:) = [];
col(25,:) = [];
for i=1:size(xfpdata,2)
    for j=1:size(A,1)
        if isempty(find(strcmp(xfpdata(i).fid,A{j,1})))
            %fid{j,i}=col((cnum(1,1)+1),:);
            continue
        end
        fid{i,j}=xfpdata(i).centroid(find(strcmp(xfpdata(i).fid,A{j,1})),:);
    end
end
%% Plot individual cells
if n==2 || n==3
figure
q=vertcat(fid{:,1});
scatter(q(:,1),q(:,2),'Filled','MarkerFaceColor',col(1,:));
hold on
i=2;
for i=2:cnum(1)
    q=vertcat(fid{:,i});
    scatter(q(:,1),q(:,2),'Filled','MarkerFaceColor',col(i,:));
end
hold off
legend(A)
saveas(gcf,'ScatterCelllineages.fig')
close gcf
figure
for i=1:cnum(1)
    q=vertcat(fid{:,i});
    subplot(round(sqrt(cnum(1))),round(sqrt(cnum(1))),i)
    scatter(q(:,1),q(:,2),'*','MarkerFaceColor',col(i,:))
end
end
