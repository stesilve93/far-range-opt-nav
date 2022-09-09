function [photoA,photoB,Tcoord_sky,Tcoord_real] = generate_photos_withT(sky,l,xA,yA,xB,yB,I_A,I_B,size_A,size_B)

% photoA
photoA = sky(yA:yA+l-1, xA:xA+l-1); 

% photoB
photoB = sky(yB:yB+l-1, xB:xB+l-1);

% Add the reflection of the satellite -------------------------------------
% generate image of the satellite reflection
T_photo_A = zeros(21,21);
T_photo_A(11-round(size_A/2):11+round(size_A/2),11-round(size_A/2):11+round(size_A/2)) = I_A;
T_photo_A = conv2(T_photo_A,fspecial('gaussian', round(15),1),'same');

T_photo_B = zeros(21,21);
T_photo_B(11-round(size_B/2):11+round(size_B/2),11-round(size_B/2):11+round(size_B/2)) = I_B;
T_photo_B = conv2(T_photo_B,fspecial('gaussian', round(15),1),'same');

% add target to random position
frame = 20;     %the target will not appear in the extreme edge of the photo
Tcoord_sky.xA = randi([xA+frame, xA+l-frame]); 
Tcoord_sky.yA = randi([yA+frame, yA+l-frame]); 
Tcoord_sky.xB = randi([xB+frame, xA+l-frame]); 
Tcoord_sky.yB = randi([yB+frame, yA+l-frame]);

% coordinates of the target in the photos coordinate system
Tcoord_real.xA = Tcoord_sky.xA-xA;
Tcoord_real.yA = Tcoord_sky.yA-yA;
Tcoord_real.xB = Tcoord_sky.xB-xB;
Tcoord_real.yB = Tcoord_sky.yB-yB;

% add Target reflection
photoA(Tcoord_real.yA-10:Tcoord_real.yA+10,Tcoord_real.xA-10:Tcoord_real.xA+10) = photoA(Tcoord_real.yA-10:Tcoord_real.yA+10,Tcoord_real.xA-10:Tcoord_real.xA+10) + T_photo_A;
photoB(Tcoord_real.yB-10:Tcoord_real.yB+10,Tcoord_real.xB-10:Tcoord_real.xB+10) = photoB(Tcoord_real.yB-10:Tcoord_real.yB+10,Tcoord_real.xB-10:Tcoord_real.xB+10) + T_photo_B;


end

