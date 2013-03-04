function print_img_without_spikes(bin_import, name, std_factor, spp)
    %initialize image
    img = zeros(620, 362, 3);
    % Number of samples per pixel

    N = size(bin_import, 2);
    for i = 0:spp:N-1
        x = mod(i/8, size(img,2)) + 1;
        y = floor(i/8/size(img,2)) + 1;
        samples = bin_import(7:9,i+1:i+spp);
        samples_mean = sum(samples,2)/spp;
        samples_std = std(samples,0,2).*std_factor;
        samples_error = abs(bsxfun(@minus, samples, samples_mean));
        samples_spikes = any(bsxfun(@gt, samples_error, samples_std));
        unspiky_samples = samples(:, ~samples_spikes);
        a = size(unspiky_samples, 2);
        img(y , x, :) = (sum(unspiky_samples,2) + (spp - a) * samples_mean) ...
                                        /spp;
    end
    exrwrite(img, [name 'std_' num2str(std_factor) '.exr']);
end