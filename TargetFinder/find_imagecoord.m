function [x0,y0] = find_imagecoord(corr_mat, conv_len)
%--------------------------------------------------------------------------
% find the coordinate of the configuration of  maximum overlapping of 
% bright points between the two photos
%--------------------------------------------------------------------------

% find the coordinates of the maximum in the correlation matrix
[a,b] = find(corr_mat == max(max(corr_mat)));

% find relative coordinates of top-left corner of photoB over photoA
x0 = b-round(conv_len/2); 
y0 = a-round(conv_len/2);


end

