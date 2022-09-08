function [photoA,photoB,pos_T_sky,pos_T] = generate_photos_withT(sky,l,xA,yA,xB,yB,I_A,I_B,size_A,size_B)

% photoA
photoA = sky(yA:yA+l-1, xA:xA+l-1); 

% photoB
photoB = sky(yB:yB+l-1, xB:xB+l-1);

% Add the reflection of the satellite -------------------------------------
% generate image of the satellite reflection
sat_photo_A = zeros(21,21);
sat_photo_A(7:7+size_A,7:7+size_A) = I_A;
sat_photo_A = conv2(sat_photo_A,fspecial('gaussian', round(15),1),'same');

sat_photo_B = zeros(21,21);
sat_photo_B(7:7+size_B,7:7+size_B) = I_B;
sat_photo_B = conv2(sat_photo_B,fspecial('gaussian', round(15),1),'same');

% add target to random position
frame = 20;     %the target will not appear in the extreme edge of the photo
pos_T_sky.xA = randi([xA+frame, xA+l-frame]); 
pos_T_sky.yA = randi([yA+frame, yA+l-frame]); 
pos_T_sky.xB = randi([xB+frame, xA+l-frame]); 
pos_T_sky.yB = randi([yB+frame, yA+l-frame]);

% coordinates of the target in the photos coordinate system
pos_T.xA = pos_T_sky.xA-xA;
pos_T.yA = pos_T_sky.yA-yA;
pos_T.xB = pos_T_sky.xB-xB;
pos_T.yB = pos_T_sky.yB-yB;

% add Target reflection
photoA(pos_T.yA-10:pos_T.yA+10,pos_T.xA-10:pos_T.xA+10) = photoA(pos_T.yA-10:pos_T.yA+10,pos_T.xA-10:pos_T.xA+10) + sat_photo_A;
photoB(pos_T.yB-10:pos_T.yB+10,pos_T.xB-10:pos_T.xB+10) = photoA(pos_T.yB-10:pos_T.yB+10,pos_T.xB-10:pos_T.xB+10) + sat_photo_B;


end

