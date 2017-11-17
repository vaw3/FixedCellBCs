 r1=cell2mat(struct2cell(xfpdata(1).r1));
for i=2:size(xfpdata,2)
    tmp=cell2mat(struct2cell(xfpdata(i).r1));
    r1=[r1 tmp];
end
clear tmp;
fr1=cell2mat(struct2cell(xfpdata(1).fr1));
for i=2:size(xfpdata,2)
    tmp=cell2mat(struct2cell(xfpdata(i).fr1));
    fr1=[fr1 tmp];
end
 clear tmp;
 r2=cell2mat(struct2cell(xfpdata(1).r2));
for i=2:size(xfpdata,2)
    tmp=cell2mat(struct2cell(xfpdata(i).r2));
    r2=[r2 tmp];
end
 clear tmp;
  fr2=cell2mat(struct2cell(xfpdata(1).fr2));
for i=2:size(xfpdata,2)
    tmp=cell2mat(struct2cell(xfpdata(i).fr2));
    fr2=[fr2 tmp];
end
 clear tmp;
   cfp=cell2mat(struct2cell(xfpdata(1).cfp));
for i=2:size(xfpdata,2)
    tmp=cell2mat(struct2cell(xfpdata(i).cfp));
    cfp=[cfp tmp];
end
 clear tmp;
    yfp=cell2mat(struct2cell(xfpdata(1).yfp));
for i=2:size(xfpdata,2)
    tmp=cell2mat(struct2cell(xfpdata(i).yfp));
    yfp=[yfp tmp];
end
 clear tmp;
 subplot(2,3,1)
 histogram(r1,25)
 title('R1')
 subplot(2,3,2)
 histogram(fr1,25)
 title('FR1')
 subplot(2,3,3)
 histogram(cfp,25)
 title('cfp')
 subplot(2,3,4)
 histogram(r2,25)
 title('R2')
 subplot(2,3,5)
 histogram(fr2,25)
 title('FR2')
 subplot(2,3,6)
 histogram(yfp,25)
 title('yfp')
 saveas(gcf,'XFPHistograms.fig')