load('xfplineage.mat');    
lineage=xfpdata(1).fid;
for i=2:size(xfpdata,2)
    tmp=xfpdata(i).fid;
    lineage=vertcat(lineage,tmp);
end
lineage=categorical(lineage);
histogram(lineage)