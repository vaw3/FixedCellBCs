function [xfpdata]= shiftcentroid(dimsx,dimsy,xfpdata)
    load shift.mat
    dimsy=cumsum(dimsy);
    dimsx=cumsum(dimsx,2);
    dimsy=reshape(dimsy',[49 1]);
    dimsx=reshape(dimsx',[49 1]);
    tmp=cell2mat(struct2cell(xfpdata(1).centroid)');
    xfpdata(1).centroid=tmp;
    for i=2:size(xfpdata,2)
        tmp=cell2mat(struct2cell(xfpdata(i).centroid)');
        tmp(:,1)=tmp(:,1)+dimsx(i-1)+shift(i,2);
        tmp(:,2)=tmp(:,2)+dimsy(i-1)+shift(i,1);
        xfpdata(i).centroid=tmp;
    end
end