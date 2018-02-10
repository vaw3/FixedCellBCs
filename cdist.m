function d=cdist(a,b)
a=cell2mat(struct2cell(a));
b=cell2mat(struct2cell(b));
d=pdist2(a,b);
end
