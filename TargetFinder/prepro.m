function [photoA] = prepro(photoA,set_prepro)
%--------------------------------------------------------------------------
% performs threshold and median filter on the input photos
%--------------------------------------------------------------------------

med = set_prepro.med;
thres = set_prepro.thres;

% smooth single point noise
photoA = medfilt2(photoA,[med,med]);


% apply threshold
photoA = photoA.*(photoA>thres);


end

