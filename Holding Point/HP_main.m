%--------------------------------------------------------------------------
% simulate the Correlation algorithm in the holding point phase
%--------------------------------------------------------------------------
clear all

% Camera characteristics 
f = 0.05;           % focal length [m]
x_sens = 0.01;      % x dimension of the sensor [m] (assume square for now)
l = 480;

% orbit characteristics (circular orbit)
%----
r = 6371 + 1000; % Km
Theta = deg2rad(0.05); % anomaly between C and T
%----

distance = 2*(r*sin(Theta/2));
v = sqrt(398600/r);
T = 2*pi*sqrt(2*r^3/398600);
omega = v/r;        % angular velocity
alpha_camera = deg2rad(0);  % angle between direction of camera and velocity
LOS_T = Theta/2;    % assuming same circular orbit

% compute velocity of the fixed stars in the fov of the camera
v_stars = omega*f;  % m/s
v_stars_px = round(v_stars*l/x_sens);

% compute the px dimension of the sliding sky
dim_x = 480;
dim_y = v_stars_px*round(T);

% generate sliding sky
hsize = 20;
sigma = 3;
[sky] = synthetic_sky(hsize, sigma, dim_x, dim_y);

% time step
t_step = 1;
t_vec = 1:t_step:T;
step_slide = t_step*v_stars_px;

fov_vec = 1:step_slide:dim_y-dim_x;


% compute pixel dimension of VESPA
vespa_dim = 3;
alpha = 2*atan(0.5*vespa_dim/(distance*10^3));
vespa_dim_cam = tan(alpha)*f*2;
pix_dim = x_sens/l;
vespa_px_dim = round(vespa_dim_cam/pix_dim);

% generate image of the satellite reflection
%----
size_vec = vespa_px_dim*ones(size(fov_vec,2));
I_vec = 0.5+0.5*sin(0.1*t_vec);
%----

Tcoord_real.xT = round(l/2);    % if same orbit and camera is pointing velocity
Tcoord_real.yT = round((f*tan(LOS_T) + x_sens/2)*l/x_sens); % compute the pixel position of the Target
T_photo = zeros(21,21);
T_photo(11-round(size_vec(1)/2):11+round((1)/2),11-round(size_vec(1)/2):11+round(size_vec(1)/2)) = I_vec(1);
T_photo = conv2(T_photo,fspecial('gaussian', round(15),1),'same');

% first frame
photoB = sky(1:dim_x,1:dim_x);
photoB(Tcoord_real.yT-10:Tcoord_real.yT+10,Tcoord_real.xT-10:Tcoord_real.xT+10) = photoB(Tcoord_real.yT-10:Tcoord_real.yT+10,Tcoord_real.xT-10:Tcoord_real.xT+10) + T_photo;
figure()
imshow(photoB); hold on
F(1) = getframe(gcf); % save frame for video 
drawnow;

coord_mat = zeros(2,size(fov_vec,2));
for n = 2:100

    photoA = photoB;
    photoB = sky(fov_vec(n):fov_vec(n)+dim_x-1,1:dim_x);

    % add Target reflection
    T_photo = zeros(21,21);
    T_photo(11-round(size_vec(n)/2):11+round(size_vec(n)/2),11-round(size_vec(n)/2):11+round(size_vec(n)/2)) = I_vec(n);
    T_photo = conv2(T_photo,fspecial('gaussian', round(15),1),'same');
    photoB(Tcoord_real.yT-10:Tcoord_real.yT+10,Tcoord_real.xT-10:Tcoord_real.xT+10) = photoB(Tcoord_real.yT-10:Tcoord_real.yT+10,Tcoord_real.xT-10:Tcoord_real.xT+10) + T_photo;

    % search for target coordinates
    [result,Tcoord,plots] = TargetFinder(photoA,photoB);

    imshow(photoB); hold on
    if result(2) == 1
    plot(Tcoord.xB,Tcoord.yB,'bo', 'LineWidth',2); 
    end
    F(n) = getframe(gcf);  % save video frame
%     pause(1)
    drawnow;

   
end

%---------- save video
writerObj = VideoWriter('myVideo.avi');
writerObj.FrameRate = 5;
open(writerObj);    % open the video writer
% write the frames to the video
for i=1:length(F)
    frame = F(i) ;  % convert the image to a frame
    writeVideo(writerObj, frame);
end
close(writerObj);   % close the writer object


% % show photos with coordinate of the Target found by the search -----------
% figure()
% imshow(photoA); hold on
% if result(1) == 1 
% plot(Tcoord.xA,Tcoord.yA,'ro', 'LineWidth',2); 
% end
% 
% figure()
% imshow(photoB); hold on
% if result(2) == 1
% plot(Tcoord.xB,Tcoord.yB,'bo', 'LineWidth',2); 
% end



























