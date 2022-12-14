function [sky,Tcoordsky_real] = Paste_moving_T(sky,t,I_T,size_T)


% Add the reflection of the satellite -------------------------------------
% generate image of the satellite reflection
T_photo = zeros(21,21);
T_photo(11-round(size_T/2):11+round(size_T/2),11-round(size_T/2):11+round(size_T/2)) = I_T;
T_photo = conv2(T_photo,fspecial('gaussian', round(15),1),'same');


% trajectory of the moving target in the sky
Tcoordsky_real = [1500-5*t; 1100-10*t];

% paste the target reflection on the sky
sky(Tcoordsky_real(2)-10:Tcoordsky_real(2)+10,Tcoordsky_real(1)...
    -10:Tcoordsky_real(1)+10) = sky(Tcoordsky_real(2)-10:Tcoordsky_real(2)+10,Tcoordsky_real(1)...
    -10:Tcoordsky_real(1)+10) + T_photo; 



end

