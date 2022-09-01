function [sky] = synthetic_sky(hsize, sigma)

% returns uint16 synthetic image of the sky with random stars
% INPUT     - hsize: size of the gaussian PSF  
%           - sigma: stdev of the gaussian PSF


if nargin<1
    hsize = 15;
    sigma = 3;
end

% synthetic image
sky = conv2((rand([1024,1024])>0.9999),fspecial('gaussian', hsize,sigma),'same') + (rand(1024)*0.01);
sky = sky/max(max(sky));