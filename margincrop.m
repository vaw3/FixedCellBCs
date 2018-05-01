function CROP = margincrop(I, LR, TB)
%MARGINCROP - Crop image matrix along first 2 dimensions
%  CROP = margincrop(I, [LEFT RIGHT], [TOP BOTTOM])
%  crops image I with ndims(I) >=2 by LEFT+RIGHT columns
%  and TOP+BOTTOM rows. May use [] instead of [0 0] (i.e. no crop).
%
%  Example:
%  I = meshgrid(1:50)
%  J = margincrop(I,[10 3],[2 2]) 
%  subplot(1,2,1);imagesc(I);axis([1 50 1 50]);
%  subplot(1,2,2);imagesc(J);axis([1 50 1 50]);colormap(lines)
%  -> crops left side by 10, right by 3 and top & bottom by 2.
%
%  Example: K = margincrop(I,[],[0 1]) 
%  Only removes bottom row of I.
%
%  Possible extensions: 
%  - output number of removed pixels
%  - output "imcrop equivalent" arguments
%  - pad with padarray() for negative crops


if isempty(LR)
    L = 0;
    R = 0;
else
    L = LR(1);
    R = LR(2);
end

if isempty(TB)
    T = 0;
    B = 0;
else
    T = TB(1);
    B = TB(2);
end

if any([T B L R]<0)
    error('Can''t remove a negative number of rows or cols')
end

T = 1+T;
B = size(I,1)-B;
L = 1+L;
R = size(I,2)-R;

CROP = I(T:B,L:R,:);

%------reshape dimensions > 2 back again 
if ndims(I) > 3
sz = size(I);
CROP = reshape(CROP,[(B-(T-1)) (R-(L-1)) sz(3:end)]);
end

