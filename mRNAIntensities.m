dir = '/Users/Jeremiah/Desktop/Experiment 4';
sample_names = {'Dish1Well8Hyb1Before'};
nuclei_channels = [0 1];
mRNA_channels = [2 3];
positions = 24;
mRNA_threshold_561 = [768];
mRNA_threshold_640 = [850];
mRNA_threshold = [mRNA_threshold_561, mRNA_threshold_640];
channel_label = 'CY13';


for i = 1:length(sample_names)
    intensities_cell = cell(length(positions), length([nuclei_channels, mRNA_channels]));
    nuclei_number = zeros(length(positions), length(nuclei_channels));
    for p = 1:length(positions)
        image_path_cell = cell(1, length(nuclei_channels));
        for j = 1:length(nuclei_channels)
            file1 = sprintf('_w%04d_m%04d_Probabilities.h5', nuclei_channels(j), positions(p));
            image_path_cell{1,j} = strcat(dir, '/masks_tif/', sample_names{i}, file1); 
        end
        [combinedMask, mask1, mask2] = combineMask(image_path_cell);
        figure;
        imshow(combinedMask);
        [voronoi, centers] = voronoiPolygon(combinedMask);
        new_mask = voronoiMaskIntersection(voronoi, combinedMask);
        channels = [nuclei_channels, mRNA_channels];
        cc = bwconncomp(voronoi);
        cc3 = bwconncomp(new_mask);
        for k = 1:length(channels)
            file2 = sprintf('_w%04d_m%04d.tif', channels(k), positions(p));
            image_path = strcat(dir, '/masks_tif/', sample_names{i}, file2);
            img = imread(image_path);
            if sum(nuclei_channels == channels(k))
                if channels(k) == 0
                    mask = mask1;
                else
                    mask = mask2;
                end
                stats = regionprops(cc, mask, 'MeanIntensity');
                intensities_cell{p,k} = [stats.MeanIntensity];
                cc2 = bwconncomp(mask);
                stats2 = regionprops(cc2, img, 'MeanIntensity');
                nuclei_number(p,k) = length([stats2.MeanIntensity]);
                if nuclei_number(p,k) ~= sum(intensities_cell{p,k} > 0)
                    array = sort(intensities_cell{p,k});
                    val1 = array(length(array) - nuclei_number(p,k) + 1);
                    val2 = array(length(array) - nuclei_number(p,k));
                    threshold = (val1 + val2)/2;
                    intensities_cell{p,k} = (intensities_cell{p,k} > threshold).*intensities_cell{p,k};
                end
                if nuclei_number(p,k) ~= sum(intensities_cell{p,k} > 0)
                    disp('Threshold Fix does not work.');
                    disp(nuclei_number(p,k));
                    disp(sum(intensities_cell{p,k} > 0));
                end
            elseif sum(mRNA_channels == channels(k))
                stats = regionprops(cc3, img, 'MeanIntensity');
                intensities_cell{p,k} = [stats.MeanIntensity];
            end
        end
        [L, newImg] = labelVoronoiMask(voronoi, intensities_cell(p,:), mRNA_threshold, nuclei_channels, mRNA_channels, channel_label);
        figure;
        hold on
        Img = brighten(newImg, 1);
        imshow(Img);
        text(centers(:,1), centers(:,2), L, 'FontSize', 8, 'Color', [1,0.3,0]);
        hold off
    end
end
