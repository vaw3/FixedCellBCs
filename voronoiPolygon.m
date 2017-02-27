function [img4, centers] = voronoiPolygon(newmask, infox, infoy)
%%
stats = regionprops(newmask,'Area','Centroid');
stats = addVoronoiPolygon2Stats(stats,[infox infoy]);
%%
img2 = zeros(infox,infoy);
for ii = 1:length(stats)
img2(stats(ii).VPixelIdxList) = 1;
end
%img2(~newmask) = 0;
%img3 = imcomplement(img2); 
img4=bwlabel(img2);
%imshow(img2,[])%colormap('jet'); caxis([1 800]);
r1 = regionprops(img4, 'Centroid');
centers = cat(1, r1.Centroid);
%figure
%imshow(img4)
%hold on
%plot(centers(:,1), centers(:,2), 'r*');
%hold off;
end