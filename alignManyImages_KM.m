function [acoords, pix] = alignManyImages(imgs,maxov,acoords)

dims = size(imgs);
si=size(imgs{1,1});

for ii=1:dims(1)
    for jj=1:dims(2)
        currimgind=sub2ind(dims,ii,jj);
        currimg = imgs{ii,jj};
        if ii <dims(1) %if not in bottom row, align with bottom and crop extra
            nxtimg = imgs{ii+1,jj};
            pix{ii,jj}=alignTwoImagesFourier_KM(currimg,nxtimg,1,maxov);
            %acoords(ii,jj).wabove=[ind ind2];
        else
            pix{ii,jj}=currimg;
        end
        if jj > 1 %align with left and crop extra
            leftimg=imgs{ii,jj-1};
            pix{ii,jj}=alignTwoImagesFourier_KM(pix{ii,jj},leftimg,2,maxov);
            %acoords(ii,jj).wside=[ind2 ind];
        end
    end
end
acoords=maxov;

% 
% si=size(imgs{1,1});
% if nargout == 2
%     fullIm=zeros(si(1)*dims(1),si(2)*dims(2));
% end
% 
% for jj=1:dims(2)
%     for ii=1:dims(1)
%         currinds=[(ii-1)*si(1)+1 (jj-1)*si(2)+1];
%         for kk=2:ii
%             currinds(1)=currinds(1)-acoords(kk,jj).wabove(1);
%         end
%         for mm=2:jj
%             currinds(2)=currinds(2)-acoords(ii,mm).wside(1);
%         end
%         acoords(ii,jj).absinds=currinds;
%         if nargout == 2
%             currimg=imgs{ii,jj};
%             fi(currinds(1):(currinds(1)+si(1)-1),currinds(2):(currinds(2)+si(2)-1))=currimg;
%         end
%     end
% end


