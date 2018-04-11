function shiftcentroid
    load xfpdata.mat
    load shift.mat
    for i=1:size(xfpdata,2)
        
        tmp=cell2mat(struct2cell(xfpdata(i).centroid)');
        tmp(:,1)=tmp(:,1)+shift(i,1);
        tmp(:,2)=tmp(:,2)+shift(i,2);
        xfpdata(i).centroid=tmp;
    end
end