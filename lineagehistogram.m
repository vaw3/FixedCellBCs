%% Lineage Histograms
load('xfplineage.mat');    
lineage=xfpdata(1).fid;
for i=2:size(xfpdata,2)
    tmp=xfpdata(i).fid;
    lineage=vertcat(lineage,tmp);
end
lineage=categorical(lineage);
histogram(lineage)
ttle=sprintf("n=%d",size(lineage,1));
title(ttle);
%% Average Diameter Finding (current: 25) Load and try few images from masks
stats=regionprops(mask_f0002,'EquivDiameter');
stats=struct2cell(stats);
stats=cell2mat(stats);
hist(stats)