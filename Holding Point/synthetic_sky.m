function [sky] = synthetic_sky(hsize, sigma, dim_x, dim_y)

% returns uint16 synthetic image of the sky with random stars
% INPUT     - hsize: size of the gaussian PSF  
%           - sigma: stdev of the gaussian PSF


N = rand(dim_y,dim_x)*0.05;       % noise layer 
B = 0.01*ones(dim_y,dim_x);     % background gray image
S = conv2((rand([dim_y,dim_x])>0.9999),fspecial('gaussian', hsize,sigma),'same');   % stars

% synthetic image
sky = N+B+S;
sky = sky/max(max(sky));
