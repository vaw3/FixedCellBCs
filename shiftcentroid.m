function [xfpdata]= shiftcentroid(dimsx,dimsy,xfpdata)
    load shift.mat
    dimsy=cumsum(dimsy);
    dimsx=cumsum(dimsx,2);
    dims(:,:,1)=dimsx;
    dims(:,:,2)=dimsy;
    tmpshift(:,:,1)=reshape(shift(:,1),[7 7])';
    tmpshift(:,:,2)=reshape(shift(:,2),[7 7])';
    ct=1;
    for i=1:size(dimsx,2)
        for j=1:size(dimsy,2)
          curdata=cell2mat(struct2cell(xfpdata(ct).centroid)');
          if isempty(curdata)
              xfpdata(ct).centroid=curdata;
              ct=ct+1;
              clear tmp
              continue
          end
          if i==1&&j==1 
              tmp(:,1)=curdata(:,1);%+tmpshift(i,j,1);
              tmp(:,2)=curdata(:,2);%+tmpshift(i,j,2);
          elseif i==1&&j>1
              tmp(:,1)=curdata(:,1)+dims(i,j-1,1);%+tmpshift(i,j,1);
              tmp(:,2)=curdata(:,2);%+tmpshift(i,j,2);
          elseif j==1&&i>1
              tmp(:,1)=curdata(:,1);%+tmpshift(i,j,1);
              tmp(:,2)=curdata(:,2)+dims(i-1,j,2);%+tmpshift(i,j,2);
          else
              tmp(:,1)=curdata(:,1)+dims(i-1,j-1,1);%+tmpshift(i,j,1);
              tmp(:,2)=curdata(:,2)+dims(i-1,j-1,2);%+tmpshift(i,j,2);
          end
          xfpdata(ct).centroid=tmp;
          clear tmp
          ct=ct+1;
        end
    end
%         tmpy(i,j)=tmp(:,1)+dimsx(i-1)+shift(i,2);
%         tmp(:,2)=tmp(:,2)+dimsy(i-1)+shift(i,1);
%         xfpdata(i).centroid=tmp;
end