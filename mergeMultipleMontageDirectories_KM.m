function mergeMultipleMontageDirectories_KM(directory1,directory2,dims,chans,outdir,alignchans)
% Register multiple LSM montages to produce one multichannel montage.
% Output in Andor format
% directory1/2 are cell arrays containing directory names for multiple
% rounds of imaging. Assumes these can be overlaid without registeration. 
% after overlaying them, registers the stack from directory1 to that from
% directory2 using channel number chans (if more than more, will take max
% intensity over channels). dims are the dimension of the input arrays. 
% will put result in outdir. 
% if argument alignchans is specified will use the indicated channel number
% on the registered image to align the montage and will write a montage
% image for each channel in outdir (NOTE: this feature not tested)

max_imgs = prod(dims);

if ~exist(outdir,'dir')
    mkdir(outdir);
end


for ii = 1:max_imgs
    col = mod(ii-1,dims(1))+1;
    row = floor((ii - col)/dims(1))+1;
    
    imgnow1 = maxIntensityLSMMontage(directory1{1},ii);
    for kk = 2:length(directory1)
        imgnow1 = cat(3,imgnow1,maxIntensityLSMMontage(directory1{kk},ii));
    end
    
    imgnow2 = maxIntensityLSMMontage(directory2{1},ii);
    for kk = 2:length(directory2)
        imgnow2 = cat(3,imgnow2,maxIntensityLSMMontage(directory2{kk},ii));
    end
    
    [q,shift(ii,1),shift(ii,2)] = registerTwoImages(imgnow1,imgnow2,chans);
    %if shift(ii,1)>=0 && shift(ii,2)>=0
        fi=margincrop(q,[abs(shift(ii,2)) abs(shift(ii,2))],[abs(shift(ii,1)) abs(shift(ii,1))]);
%         fi(:,:,chans+1:2*chans)=margincrop(q(:,:,chans+1:2*chans),[shift(ii,2) 0],[shift(ii,1) 0]);
%     elseif shift(ii,1)>=0 && shift(ii,2)<0
%         fi(:,:,1:chans)=margincrop(q(:,:,1:chans),[-shift(ii,2) 0], [0 shift(ii,1)]);
%         fi(:,:,chans+1:2*chans)=margincrop(q(:,:,chans+1:2*chans),[0 -shift(ii,2)],[shift(ii,1) 0]);
%     elseif shift(ii,1)<0 && shift(ii,2)>=0
%         fi(:,:,1:chans)=margincrop(q(:,:,1:chans),[0 shift(ii,2)],[-shift(ii,1) 0]);
%         fi(:,:,chans+1:2*chans)=margincrop(q(:,:,1+chans:2*chans),[shift(ii,2) 0], [0 -shift(ii,1)]);
%     else
%         fi(:,:,1:chans)=margincrop(q(:,:,1:chans),[-shift(ii,2) 0],[-shift(ii,1) 0]);
%         fi(:,:,1+chans:2*chans)=margincrop(q(:,:,1+chans:2*chans),[0 -shift(ii,2)],[0 -shift(ii,1)]);
    %end
         
    all_imgs{row,col}=fi;
    %all_imgs{row,col}=imgnow1;

    
end

    save('shift.mat','shift');
      si = size(all_imgs);
%     all_si_c = cellfun(@size,all_imgs,'UniformOutput',false);
%     all_si = cell2mat(all_si_c);
%     im_max_size = [max(max(all_si(:,[1 3 5 7]))) max(max(all_si(:,[2 4 6 8])))];
%     %im_max_size = [max(max(all_si(:,1))) max(max(all_si(:,2)))]; 
%     toAlign = cell(dims);
      [ac, pix]=alignManyImages_KM(all_imgs,200);
      ct=1;
    for ii=1:si(1)
        for jj = 1:si(2)    
            fi=pix{ii,jj};
            posstr=sprintf('%04d',ct);
            writeMultichannel(fi,fullfile(outdir,['merge_f' posstr '.tif']));
            ct=ct+1;
        end
    end
  
%     for kk = 1:size(all_imgs{1,1},3)
%         for ii=1:si(1)
%             for jj = 1:si(2)
%                 toAlign{ii,jj} = all_imgs{ii,jj}(:,:,kk);
%             end
%         end
%         [~,fi]=alignManyImages(toAlign,200,ac);
%         imwrite(fi,fullfile(outdir,['montage_c' int2str(kk) '.tif']));
%     end
    
end


