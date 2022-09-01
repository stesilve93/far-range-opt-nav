function [photoA,photoB] = prepro(photoA,photoB,thres,med)
%--------------------------------------------------------------------------
% performs threshold and median filter on the input photos
%--------------------------------------------------------------------------

% smooth single point noise
photoA = medfilt2(photoA,[med,med]);
photoB = medfilt2(photoB,[med,med]);

% apply threshold
photoA = photoA.*(photoA>thres);
photoB = photoB.*(photoB>thres);

end

