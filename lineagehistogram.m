%% Lineage Histograms
clear all
load('xfplineage.mat');    
lineage=xfpdata(1).fid;
for i=2:size(xfpdata,2)
    tmp=xfpdata(i).fid;
    lineage=vertcat(lineage,tmp);
end
lineageh=categorical(lineage);
figure
histogram(lineageh)
ttle=sprintf("n=%d",size(lineageh,1));
title(ttle);
saveas(gcf,'lineagehistogram.fig')
%% Average Diameter Finding (current: 25) Load and try few images from masks
stats=regionprops(mask_f0002,'EquivDiameter');
stats=struct2cell(stats);
stats=cell2mat(stats);
hist(stats)