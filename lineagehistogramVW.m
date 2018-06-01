%% Lineage Histograms
clear all
load('xfplineage.mat');    
lineage=xfpdata(1).fid;
for i=2:size(xfpdata,2)
    tmp=xfpdata(i).fid;
    lineage=vertcat(lineage,tmp);
end
cells=tabulate(lineage);
e=size(cells,1);
d=cells(1:e,2);
d=cell2mat(d);
number=sum(d);
emptyCells = cellfun(@isempty,lineage);
c=sum(emptyCells);
lineage(all(cellfun('isempty',lineage),2),:) = [];
lineageh=categorical(lineage);
lineageh([number+1:number+c]) = "None";
cells=tabulate(lineageh);
A = sortrows(cells,[3],'descend');
B=A(1:30,1);
x=size(lineageh,1);
figure
histogram(lineageh,B)
ttle=sprintf("n=%d",size(lineageh,1));
title(ttle);
yticks([0 x*.01 x*.02 x*.03 x*.04 x*.05 x*.06 x*.07 x*.08 x*.09 x*.10 x*.11 x*.12 x*.13 x*.14 x*.15 x*.16 x*.17 x*.18 x*.19 x*.2 x*.21 x*.22 x*.23 x*.24 x*.25])
yticklabels([0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25])
saveas(gcf,'lineagehistogram.fig')
%% Average Diameter Finding (current: 25) Load and try few images from masks
%stats=regionprops(mask_f0002,'EquivDiameter');
%stats=struct2cell(stats);
%stats=cell2mat(stats);
%hist(stats)