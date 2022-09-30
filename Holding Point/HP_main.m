%--------------------------------------------------------------------------
% simulate the Correlation algorithm in the holding point phase
%--------------------------------------------------------------------------
clear all

% CAMERA CHARACTERISTICS --------------------------------------------------
f = 0.05;           % focal length [m]
x_sens = 0.01;      % x dimension of the sensor [m] (assume square for now)
l = 480;
alpha_camera = deg2rad(0);  % angle between direction of camera and velocity


% ORBIT -------------------------------------------------------------------
% with circular orbit
%----
r = 6371 + 1000; % Km
Theta = deg2rad(0.03); % anomaly between C and T
%----

distance = 2*(r*sin(Theta/2)); 
D1 = ['T distance: ',num2str(distance), ' Km']; disp(D1)
v = sqrt(398600/r);
T = 2*pi*sqrt(2*r^3/398600);
omega = v/r;                % angular velocity

LOS_T = Theta/2+alpha_camera;            

% compute velocity of the fixed stars in the fov of the camera
v_stars = omega*f;                      % [m/s]
v_stars_px = round(v_stars*l/x_sens);   % [px/s]

% compute the px dimension of the sliding sky for T
dim_x = 480;
dim_y = v_stars_px*round(T);

% generate sliding sky
hsize = 5;
sigma = 2;
[sky] = synthetic_sky(hsize, sigma, dim_x, dim_y);

% time step
t_step = 1; % [s]
t_vec = 1:t_step:T;
step_slide = t_step*v_stars_px; % pixel step

fov_vec = 1:step_slide:dim_y-dim_x; % up-left corner of the photo on the sliding sky

% pixel dimension of VESPA
vespa_dim = 3;  %characteristic dimension, cube shape for now
alpha = 2*atan(0.5*vespa_dim/(distance*10^3));  % half angle from the camera
vespa_dim_cam = tan(alpha)*f*2;                 % Vespa dimension on the camera
pix_dim = x_sens/l;
vespa_px_dim = round(vespa_dim_cam/pix_dim);    % pixel dimension of Vespa
D2 = ['Vespa pixel dimension: ',num2str(vespa_dim_cam/pix_dim), ' px']; disp(D2)

% IMAGE OF THE T REFLECTION -----------------------------------------------
%----
size_vec = vespa_px_dim*ones(size(fov_vec,2));
I_vec = 0.5+0.5*sin(0.1*t_vec);
%----

Tcoord_real.xT = round(l/2);    % if same orbit and camera is pointing velocity
Tcoord_real.yT = round((f*tan(LOS_T) + x_sens/2)*l/x_sens); % compute the pixel position of the Target
T_photo = zeros(21,21);
if size_vec(1)==0
T_photo(11-round(size_vec(1)/2):11+round((1)/2),11-round(size_vec(1)/2):11+round(size_vec(1)/2)) = 0;
else
    T_photo(11-round(size_vec(1)/2):11+round((1)/2),11-round(size_vec(1)/2):11+round(size_vec(1)/2)) = I_vec(1);
end
    T_photo = conv2(T_photo,fspecial('gaussian', round(15),1),'same');

% HOLDING POINT SIMULATION ------------------------------------------------
% first frame
photoB = sky(1:dim_x,1:dim_x);
photoB(Tcoord_real.yT-10:Tcoord_real.yT+10,Tcoord_real.xT-10:Tcoord_real.xT+10) = photoB(Tcoord_real.yT-10:Tcoord_real.yT+10,Tcoord_real.xT-10:Tcoord_real.xT+10) + T_photo;

[FOV,LOS] = LOS_fromcoord(f, x_sens, l, Tcoord_real.xT,Tcoord_real.yT);


figure()
photoB_frame = insertText(photoB,[Tcoord_real.xT+20,Tcoord_real.yT-20],['[',num2str(LOS.x,'%.2f'),';', num2str(LOS.y,'%.2f'),'] deg']);
imshow(photoB_frame); hold on

F(1) = getframe(gcf); % save frame for video 
drawnow;

coord_mat = zeros(2,size(fov_vec,2));   % container for T coordinates
for n = 2:100
    
    % update new photos
    photoA = photoB;
    photoB = sky(fov_vec(n):fov_vec(n)+dim_x-1,1:dim_x);

    % add Target reflection
    T_photo = zeros(21,21);
    if size_vec(n) ==0
    T_photo(11-round(size_vec(n)/2):11+round(size_vec(n)/2),11-round(size_vec(n)/2):11+round(size_vec(n)/2)) = 0;
    else
        T_photo(11-round(size_vec(n)/2):11+round(size_vec(n)/2),11-round(size_vec(n)/2):11+round(size_vec(n)/2)) = I_vec(n);
    end
    T_photo = conv2(T_photo,fspecial('gaussian', round(15),1),'same');
    photoB(Tcoord_real.yT-10:Tcoord_real.yT+10,Tcoord_real.xT-10:Tcoord_real.xT+10) = photoB(Tcoord_real.yT-10:Tcoord_real.yT+10,Tcoord_real.xT-10:Tcoord_real.xT+10) + T_photo;

    % search for target coordinates
    [result,Tcoord,plots] = TargetFinder(photoA,photoB);

    [FOV,LOS] = LOS_fromcoord(f, x_sens, l, Tcoord.xB,Tcoord.yB);




    % new frame
    if isnan(Tcoord.xB)
        photoB_frame = insertText(photoB,[50,50],['TARGET NOT FOUND'],'BoxColor','r');
    else
    str{1} = ['[',num2str(LOS.x,'%.2f'),';', num2str(LOS.y,'%.2f'),'] deg'];
    str{2} = 'TARGET FOUND';
    boxcolor = ["y","g"];
    photoB_frame = insertText(photoB,[Tcoord.xB+20,Tcoord.yB-20;50 50],str,'BoxColor',boxcolor);
    
    end
    imshow(photoB_frame); hold on
    if result(2) == 1
    plot(Tcoord.xB,Tcoord.yB,'bo', 'LineWidth',2); 
    end
    F(n) = getframe(gcf);  % save video frame
    drawnow;

end

% SAVE VIDEO --------------------------------------------------------------
writerObj = VideoWriter('myVideo.avi');
writerObj.FrameRate = 5;
open(writerObj);    % open the video writer
% write the frames to the video
for i=1:length(F)
    frame = F(i) ;  % convert the image to a frame
    writeVideo(writerObj, frame);
end
close(writerObj);   % close the writer object



