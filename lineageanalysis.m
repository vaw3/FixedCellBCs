
load('xfplineage.mat');    
%% Colony Finding
colony=struct('colonyx',0,'colonyy',0);
for i=1:size(xfpdata,2)
    index=0;
    for j=1:size(xfpdata(i).centroid,1)
        bcode=xfpdata(i).fid(j);
        ct=0;
        centroid={};
        for k=1:size(xfpdata(i).centroid,1)
            if isequal(bcode,xfpdata(i).fid(k)) &&...
                    cdist(xfpdata(i).centroid(j),xfpdata(i).centroid(k))<125 
                %Threshold 125 is based on a multiple of diameter
                %(currently 5*diameter of 25)
                ct=ct+1;
                centroid(ct) = [struct2cell(xfpdata(i).centroid(k))]; 
            end
        end
        tmp=cell2mat(centroid);
        tmpx=mean(tmp(:,1));
        tmpy=mean(tmp(:,2));
        if any(colony(i).colonyx==tmpx) &&...
                any(colony(i).colonyy==tmpy)
            continue
        else
        colony(i).barcode(index)=bcode;
        colony(i).cells(index)=ct;
        colony(i).centroids(index).value=tmp;        
        colony(i).colonyx(index) = tmpx;
        colony(i).colonyy(index) = tmpy;
        index=index+1;
        end    
    end
end
            
                
                
        