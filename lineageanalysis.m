clear all
load('xfplineage.mat');    
%% Colony Finding
t=find(cellfun(@isempty,{xfpdata.centroid}))';
xfpdata(t)=[];
t=struct2cell(xfpdata);
z=squeeze(t);
z=z';
ctrs=cell2mat(z(:,1));
color=z(:,9);
init=color{1,1};
colony=struct('colonyx',0,'colonyy',0);
colony=repmat(colony,[size(ctrs,1),1]);
for i=2:size(color,1)
    tmp=color{i,1};
    tmp=vertcat(init,tmp);
    init=tmp;
end
for i=1:size(ctrs,1)
    index=1;
    debug=1;
    tmpdist=[];
    bcode=init(i);
    ct=0;
    centroid={};
    for j=1:size(ctrs,1)
        if isequal(bcode,init(j)) &&...
                cdist(ctrs(i,:),ctrs(j,:))<100
            %Threshold 125 is based on a multiple of diameter
            %(currently 5*diameter of 25)
            tmpdist=[tmpdist cdist(ctrs(i,:),ctrs(j,:))];
            ct=ct+1;
            centroid(ct,:) = {ctrs(j,1) ctrs(j,2)};
        end
    end
    if(ct==1)
        tmpdist=[];
    end
    if(isempty(tmpdist))
        
        continue
    else
        maxdist=max(tmpdist);
        tmp=cell2mat(centroid);
        tmpx=mean(tmp(:,1));
        tmpy=mean(tmp(:,2));
        debug=debug+1;
        if i>1 && any(colony(i-1).colonyx==tmpx) &&...
                any(colony(i-1).colonyy==tmpy)
            continue
        else
            colony(i).barcode(index,1)=bcode;
            colony(i).cells(index,1)=ct;
            colony(i).centroids(index).value=tmp;
            colony(i).colonyx(index,1) = tmpx;
            colony(i).colonyy(index,1) = tmpy;
            colony(i).maxdist(index,1) = maxdist;
            index=index+1;
        end
    end
end
%     t(i)=debug;
t=find(cellfun(@isempty,{colony.cells}))';
colony(t)=[];
save('colonydata.mat','colony')   

   
                
                
        