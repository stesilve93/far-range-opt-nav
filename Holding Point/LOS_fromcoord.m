function [FOV,LOS] = LOS_fromcoord(f, x_sens, l, Tcoord)
%--------------------------------------------------------------------------
% compute the LoS given the camera characteristics and the image coordinate
%--------------------------------------------------------------------------

FOV.y = rad2deg(2* atan(0.5*x_sens/f));
FOV.x = rad2deg(2* atan(0.5*x_sens/f));


% compute pixel dimension
pix_dim = x_sens/l;

% compute coordinate distance
x_sat_dim = Tcoord.xB * pix_dim;
y_sat_dim = Tcoord.yB * pix_dim;

% compute coordinate from the central point
x_sat_cam = x_sat_dim - x_sens/2;
y_sat_cam = x_sens/2 - y_sat_dim;

% compute LoS
LOS.x = rad2deg(atan(x_sat_cam/f));
LOS.y = rad2deg(atan(y_sat_cam/f));



end

