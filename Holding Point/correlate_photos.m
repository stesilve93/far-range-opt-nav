function [corr_mat] = correlate_photos(photoA,photoB,conv_len)
%--------------------------------------------------------------------------
% Compute the correlation matrix of the two photos with tunable dimension
% of the second photo
%--------------------------------------------------------------------------

%the photo has to be flipped for the convolution algorithm
photoB_flip = flip(flip(photoB(1:conv_len,1:conv_len),1),2);  

corr_mat = conv2(photoA,photoB_flip,'same');


end

