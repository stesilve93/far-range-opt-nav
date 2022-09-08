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

% Generate photos with Target
% FoV
l = 480;                % px dimension of the photo
xA = 200;   yA = 250;   % top-left coordinate of the first photo
xB = 250;   yB = 350;   % top-left coordinate of the second photo
I_A = 1;    I_B = 0.51; % intensity of the Target reflection
size_A = 7; size_B = 4; % dimension of the Target reflection [px]

[photoA,photoB,pos_T_sky,pos_T] = generate_photos_withT(sky,l,xA,yA,xB,yB,I_A,I_B,size_A,size_B);


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
plot(pos_T_sky.xA,pos_T_sky.yA,'ro','LineWidth',2); hold on
plot(pos_T_sky.xB,pos_T_sky.yB,'bo','LineWidth',2); hold on

% show photos of the sky---------------------------------------------------
figure(2)
imshow(photoA); hold on
rectangle('Position',[1,1,l-1,l-1],'LineWidth',2,'EdgeColor','r');
plot(pos_T.xA,pos_T.yA,'ro','LineWidth',2)
title('photo A');

figure(3)
imshow(photoB); hold on
rectangle('Position',[1,1,l-1,l-1],'LineWidth',2,'EdgeColor','b');
plot(pos_T.xB,pos_T.yB,'bo','LineWidth',2)
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




