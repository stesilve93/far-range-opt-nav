function [alpha_x,alpha_y] = LOS_fromcoord(f, x_sens, l, x_sat, y_sat)
%--------------------------------------------------------------------------
% compute the LoS given the camera characteristics and the image coordinate
%--------------------------------------------------------------------------

% compute pixel dimension
pix_dim = x_sens/l;

% compute coordinate distance
x_sat_dim = x_sat * pix_dim;
y_sat_dim = y_sat * pix_dim;

% compute coordinate from the central point
x_sat_cam = x_sat_dim - x_sens/2;
y_sat_cam = x_sens/2 - y_sat_dim;

% compute LoS
alpha_x = rad2deg(atan(x_sat_cam/f));
alpha_y = rad2deg(atan(y_sat_cam/f));



end

