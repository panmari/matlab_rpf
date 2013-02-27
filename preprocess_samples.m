function neighbourhood = preprocess_samples(bin_import, k, boxsize, max_samples_box, spp)
    if nargin < 4
        spp = 8;
    end
    mean_position = [floor(mean(bin_import(1,k:k+spp-1))), floor(mean(bin_import(2,k:k+spp-1)))]';
    standard_deviation = boxsize/4;
    % add all samples of current pixel
    N = k:k+7; 
    % Normal of first intersection
    % World-Space position of first intersection
    % primary albedo (texture value of first intersection) = sec_origin
    % World-Space position of second intersection
    % secondary normal
    % secondary albedo (texture value second intersection)
    features = [13, 19, 16, 21, 28, 34];
    [means, st_deviation] = getFeatureMeanAndStd(bin_import, features, k, spp);
    mu = repmat(mean_position, [1, max_samples_box - spp]);
    sample_pos_array = round(normrnd(mu, standard_deviation));
    for sample_pos = sample_pos_array
        % skip if out of range or at initial position
        if (any(sample_pos < [1,1]' | sample_pos > [620, 362]') || all(sample_pos == mean_position))
            continue;
        end
        j = getIndexByPosition(sample_pos);
        sample_number = randi([0, 7]); %TODO: make sure a sample isn't chosen twice?
        inspected_sample = j + sample_number;
        flag = 1;
        for f_nr = 1:length(features)
            feature_value = bin_import(features(f_nr):(features(f_nr)+2), inspected_sample);
            larger_than_variance = abs(feature_value - means(:,f_nr)) > 3*st_deviation(:,f_nr);
            variance_is_significant = abs(feature_value - means(:,f_nr)) > 0.1 | st_deviation(:,f_nr) > 0.1;
            if any(larger_than_variance & variance_is_significant)             
                flag = 0;
                break;
            end
        end
        if flag == 1
            % append to neighbourhood, not sure how many are added
            N = [N, inspected_sample];
        end
    end
    %Neighbourhood ready for statistical analysis
    
    neighbourhood = makeStruct(bin_import, N);
end