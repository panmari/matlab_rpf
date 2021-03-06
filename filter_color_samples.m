function new_colors = filter_color_samples(neighbourhood, a, b, weights_col_rand, spp)
    sum_weights_col_rand = sum(weights_col_rand)/3;
    
    init_variance = 0.02; % indoor
    % init_variance = 0.002 % other
    variance = 8*init_variance/spp;
    
    %This could cause division by zero:
    variance_color = variance/(1-sum_weights_col_rand)^2;
    variance_feature = variance_color;   
    scale_c = -1/(2*variance_color);
    scale_f = -1/(2*variance_feature);
        
    new_colors = zeros(3,spp);

    for i=1:spp
        squared_error_color = bsxfun(@minus, neighbourhood.color, neighbourhood.color(:,i)).^2;
        weighted_error_color = bsxfun(@times, squared_error_color, a);
        sum_wec = sum(weighted_error_color);
        
        squarred_error_features = bsxfun(@minus, neighbourhood.features, neighbourhood.features(:,i)).^2;
        weighted_error_features = bsxfun(@times, squarred_error_features, b);
        sum_wef = sum(weighted_error_features);
        
        relative_weights =    exp(scale_c*sum_wec + scale_f*sum_wef);
       
        new_colors(:,i) = sum(bsxfun(@times, neighbourhood.color_unnormed, relative_weights),2)./ ...
                                                        sum(relative_weights); 
    end
    
    %% HDR clamp
    new_colors_mean = mean(new_colors, 2);
    % could introduce larger error margin like 2*std
    new_colors_std = std(new_colors,0,2); 
    new_colors_error = abs(bsxfun(@minus, new_colors, new_colors_mean));
    outliers = any(bsxfun(@gt, new_colors_error, new_colors_std), 1);
    new_colors(:,outliers) = repmat(new_colors_mean, [1, sum(outliers == 1)]);

    %% Reinsert energy
    lost_energy_per_sample = new_colors_mean - mean(new_colors, 2);
    new_colors = bsxfun(@plus, new_colors, lost_energy_per_sample);
end