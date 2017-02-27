function [io2, pnuc] = readmaskfilesKM(ilastikNucAll,lblN)
%[pnuc, inuc] = readmaskfiles1(maskno, segfiledir, rawfiledir, dirinfo, dirinfo1, nzslices, imageno);
% if all the z slices are separate files
% if don't have time point will have less-dim .h5 file

% reading masks

%nzslices = size(ilastikNucAll,2);

%for m=1:size(ilastikNucAll,2)  % loop over z slizes

ilastikfile=ilastikNucAll{1};
io = h5read(ilastikfile,'/exported_data');
io = io(lblN,:,:,:);% make this into a variable ( which ilastik label to use as signal and which to use as background. the last dimension is time
io1 = squeeze(io);

%io1_t = io1(:,:,tpt);

pnuc = io1'; % flipped here
io2thresh = pnuc<0.2;
io2 = imfill(io2thresh,'holes');

%end

end