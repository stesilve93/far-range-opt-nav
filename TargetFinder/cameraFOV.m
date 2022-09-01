function [FoV_x,FoV_y] = cameraFOV(f,x_sens)

FoV_y = rad2deg(2* atan(0.5*x_sens/f));
FoV_x = rad2deg(2* atan(0.5*x_sens/f));

end

