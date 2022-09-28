function [result,Tcoord,plots] = TargetFinder(photoA,photoB)


% Set variables -----------------------------------------------------------
% set preprocessing variables
set_prepro.thres = 0.4;    % threshold filter
set_prepro.med = 3;        % dimension of the median filter
% set the dimension of the filter
conv_len = size(photoA,1);
%--------------------------------------------------------------------------

% pre processing
[photoA] = prepro(photoA,set_prepro);
[photoB] = prepro(photoB,set_prepro);


% correlation
[corr_mat] = correlate_photos(photoA,photoB,conv_len);


% find relative coordinates between the two images
[x0,y0] = find_imagecoord(corr_mat, conv_len);

% compute target coordinate in the two photos
[Tcoord,result,diff_cropped] = find_Tcoord(x0,y0,photoA,photoB);

plots.corr_mat = corr_mat;
plots.diff_cropped = diff_cropped;





end

