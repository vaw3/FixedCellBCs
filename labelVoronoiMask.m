function [L, newImg] = labelVoronoiMask(voronoi, intensities_cell, mRNA_threshold, nuclei_channels, mRNA_channels, channel_label)
    channels = [nuclei_channels mRNA_channels];
    L_cell = cell(length(mRNA_channels), length(intensities_cell{1,1}));
    newImg = zeros(size(voronoi,1), size(voronoi,2), 3);
    for i = 1:length(channels)
        if sum(nuclei_channels == channels(i))
            intensities_binary = intensities_cell{1,i} > 0;
            [~, c] = find(intensities_binary == 1);
            newimg = zeros(size(voronoi,1), size(voronoi,2));
            for k = 1:length(c)
                newimg = newimg | (voronoi == c(k));
            end
            switch channel_label(i)
                case 'C'
                    newImg(:,:,3) = newimg;
                case 'Y'
                    newImg(:,:,2) = newimg * 0.1;     
            end
        elseif sum(mRNA_channels == channels(i))
            [~, c] = find(mRNA_channels == channels(i));
            intensities_binary = intensities_cell{1,i} > mRNA_threshold(c);
            chars = [' ', channel_label(i)];
            string = chars(intensities_binary + 1);
            L_cell(i - length(nuclei_channels),:) = num2cell(string);
        end
    end
    L_mat = cell2mat(L_cell);
    L = num2cell(L_mat',2);
    L = L';
    for j = 1:size(L,2)
        L{1,j} = strcat(L{1,j});
    end
end