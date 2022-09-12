%% clear
clear all
close all

showplot = 0;
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
         

% Generate photos with Target----------------------------------------------
% FoV
l = 480;                % px dimension of the photo
xA = 200;   yA = 250;   % top-left coordinate of the first photo
xB = 300;   yB = 450;   % top-left coordinate of the second photo
I_A = 1;    I_B = 1;    % intensity of the Target reflection
size_A = 5; size_B = 3; % dimension of the Target reflection [px]

[photoA,photoB,Tcoord_sky,Tcoord_real] = generate_photos_withT(sky,l,xA,yA,xB,yB,I_A,I_B,size_A,size_B);


%% [ Target search ]

% Target Search algorithm--------------------------------------------------
[result,Tcoord,plots] = TargetFinder(photoA,photoB);


% display------------------------------------------------------------------
error_t = norm([Tcoord.xB,Tcoord.yB] - [Tcoord_real.xB,Tcoord_real.yB]);
error_tm1 = norm([Tcoord.xA,Tcoord.yA] - [Tcoord_real.xA,Tcoord_real.yA]);

% message
if result == [0 0]
    MSG = 'No Target Found';
elseif result == [1 0]
    MSG = ['Target found at t-1. Pixel distance error is ', num2str(error_tm1)];
elseif result == [0 1]
    MSG = ['Target found at t. Pixel distance error is ', num2str(error_t)];
elseif result == [1 1]
     MSG = ['Target found at t-1 and t. Pixel distance errors are ', num2str(error_t), ' and ',num2str(error_tm1) ];
end

disp(MSG);

%% [ Line of sight ]

% Camera characteristics --------------------------------------------------
f = 0.05;           % focal length [m]
x_sens = 0.01;      % x dimension of the sensor [m] (assume square for now)

%compute LoS
[FOV,LOS] = LOS_fromcoord(f, x_sens, l, Tcoord);

%% [ Plots ]

if showplot == 1

% show sky with FoV--------------------------------------------------------
figure(1)
imshow(sky); hold on
rectangle('Position',[xA,yA,l,l],'LineWidth',2,'EdgeColor','r'); hold on
rectangle('Position',[xB,yB,l,l],'LineWidth',2,'EdgeColor','b'); hold on
title('FoV of the camera');
% plot stars
figure(1)
plot(Tcoord_sky.xA,Tcoord_sky.yA,'ro','LineWidth',2); hold on
plot(Tcoord_sky.xB,Tcoord_sky.yB,'bo','LineWidth',2); hold on

% show photos of the sky---------------------------------------------------
figure(2)
imshow(photoA); hold on
rectangle('Position',[1,1,l-1,l-1],'LineWidth',2,'EdgeColor','r');
plot(Tcoord_real.xA,Tcoord_real.yA,'ro','LineWidth',2);
title('photo A');

figure(3)
imshow(photoB); hold on
rectangle('Position',[1,1,l-1,l-1],'LineWidth',2,'EdgeColor','b');
plot(Tcoord_real.xB,Tcoord_real.yB,'bo','LineWidth',2);
title('photo B');

% show corr matrix --------------------------------------------------------
figure(4)
imagesc(plots.corr_mat);
title('Correlation matrix');
colorbar

% show difference matrix --------------------------------------------------
figure(5)
imagesc(plots.diff_cropped);
title('Difference between photoA and photoB')

% show photos with coordinate of the Target found by the search -----------
figure(6)
imshow(photoA); hold on
rectangle('Position',[1,1,l-1,l-1],'LineWidth',2,'EdgeColor','r'); hold on
if result(1) == 1 
plot(Tcoord.xA,Tcoord.yA,'ro', 'LineWidth',2); 
end

figure(7)
imshow(photoB); hold on
if result(2) == 1
plot(Tcoord.xB,Tcoord.yB,'bo', 'LineWidth',2); 
end
rectangle('Position',[1,1,l-1,l-1],'LineWidth',2,'EdgeColor','b');


end

