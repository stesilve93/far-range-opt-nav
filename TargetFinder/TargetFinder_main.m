%% clear
clear all
close all

%% [ Generate two photos of the sky with the target's reflection ]

% Upload sky image --------------------------------------------------------
sky_switch = 0;     % 0: uploaded photo of the sky
                    % 1: random generated synthetic photo of the sky


if sky_switch == 0
sky = rgb2gray(imread('stars.jpg'));    % convert in grey
sky = im2double(sky);                   % resize between [0,1]
end

if sky_switch == 1
    hsize = 20;
    sigma = 3;
    [sky] = synthetic_sky(hsize, sigma);
end
[l_sky,h_sky] = size(sky);             

% Cut the two photos ------------------------------------------------------
% FoV
l = 480;                % px dimension of the photo
xA = 200;   yA = 250;   % top-left coordinate of the first photo
xB = 300;   yB = 350;   % top-left coordinate of the second photo

% photoA
photoA = sky(yA:yA+l-1, xA:xA+l-1); 

% photoB
photoB = sky(yB:yB+l-1, xB:xB+l-1);

% Add the reflection of the satellite -------------------------------------
% generate image of the satellite reflection
sat_photo_A = zeros(21,21);
I_A = 0.7
sat_photo_A(7:13,7:13) = I_A;
sat_photo_A = conv2(sat_photo_A,fspecial('gaussian', 15,1),'same');

sat_photo_B = zeros(21,21);
I_B = 0.7
sat_photo_B(7:13,7:13) = I_B;
sat_photo_B = conv2(sat_photo_B,fspecial('gaussian', 15,1),'same');

% add target to random position
frame = 20;     %the target will not appear in the extreme edge of the photo
pos_sat_xA_sky = randi([xA+frame, xA+l-frame]); 
pos_sat_yA_sky = randi([yA+frame, yA+l-frame]); 
pos_sat_xB_sky = randi([xB+frame, xA+l-frame]); 
pos_sat_yB_sky = randi([yB+frame, yA+l-frame]);

% coordinates of the target in the photos coordinate system
pos_sat_xA = pos_sat_xA_sky-xA;
pos_sat_yA = pos_sat_yA_sky-yA;
pos_sat_xB = pos_sat_xB_sky-xB;
pos_sat_yB = pos_sat_yB_sky-yB;

% add Target reflection
photoA(pos_sat_yA-10:pos_sat_yA+10,pos_sat_xA-10:pos_sat_xA+10) = photoA(pos_sat_yA-10:pos_sat_yA+10,pos_sat_xA-10:pos_sat_xA+10) + sat_photo_A;
photoB(pos_sat_yB-10:pos_sat_yB+10,pos_sat_xB-10:pos_sat_xB+10) = photoA(pos_sat_yB-10:pos_sat_yB+10,pos_sat_xB-10:pos_sat_xB+10) + sat_photo_B;

%% [ Target search ]

% Set variables -----------------------------------------------------------
% set preprocessing variables
thres = 0.4;    % threshold filter
med = 3;        % dimension of the median filter
% set the dimension of the filter
conv_len = l;

% Target Search algorithm--------------------------------------------------

% pre processing
[photoA,photoB] = prepro(photoA,photoB,thres,med);

tic
% correlation
[corr_mat] = correlate_photos(photoA,photoB,conv_len);
toc

% find relative coordinates between the two images
[x0,y0] = find_imagecoord(corr_mat, conv_len);

% compute target coordinate in the two photos
[x_T_A,y_T_A,x_T_B,y_T_B,diff_cropped] = find_Tcoord(x0,y0,photoA,photoB);
time = toc;

%% [ Line of sight ]

% Camera characteristics --------------------------------------------------
f = 0.05;           % focal length [m]
x_sens = 0.01;      % x dimension of the sensor [m] (assume square for now)

% compute FoV of the camera
[FoV_x,FoV_y] = cameraFOV(f,x_sens); 

%compute LoS
[alpha_x,alpha_y] = LOS_fromcoord(f, x_sens, l, x_T_B, y_T_B); 


%% [ Plots ]

% show sky with FoV--------------------------------------------------------
figure(1)
imshow(sky); hold on
rectangle('Position',[xA,yA,l,l],'LineWidth',2,'EdgeColor','r'); hold on
rectangle('Position',[xB,yB,l,l],'LineWidth',2,'EdgeColor','b'); hold on
title('FoV of the camera');
% plot stars
figure(1)
plot(pos_sat_xA_sky,pos_sat_yA_sky,'ro','LineWidth',2); hold on
plot(pos_sat_xB_sky,pos_sat_yB_sky,'bo','LineWidth',2); hold on

% show photos of the sky---------------------------------------------------
figure(2)
imshow(photoA); hold on
rectangle('Position',[1,1,l-1,l-1],'LineWidth',2,'EdgeColor','r');
plot(pos_sat_xA,pos_sat_yA,'ro','LineWidth',2)
title('photo A');

figure(3)
imshow(photoB); hold on
rectangle('Position',[1,1,l-1,l-1],'LineWidth',2,'EdgeColor','b');
plot(pos_sat_xB,pos_sat_yB,'bo','LineWidth',2)
title('photo B');

% show corr matrix --------------------------------------------------------
figure(4)
imagesc(corr_mat);
title('Correlation matrix');
colorbar

% show difference matrix --------------------------------------------------
figure(5)
imagesc(diff_cropped);
title('Difference between photoA and photoB')

% show photos with coordinate of the Target found by the search -----------
figure(6)
imshow(photoA); hold on
rectangle('Position',[1,1,l-1,l-1],'LineWidth',2,'EdgeColor','r'); hold on
if diff_cropped(y_T_A-y0,x_T_A-x0) > 0.2
plot(x_T_A,y_T_A,'ro', 'LineWidth',2); 
end

figure(7)
imshow(photoB); hold on
plot(x_T_B,y_T_B,'bo', 'LineWidth',2); 
rectangle('Position',[1,1,l-1,l-1],'LineWidth',2,'EdgeColor','b');




