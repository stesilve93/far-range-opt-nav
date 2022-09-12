%% clear
clear all
close all

%% [ Sky with moving Target ]

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

% setting of the Target reflection
size_T = 20;
I_T = 1;


% setting of the photo
l = 480;

% photos
t = 10:1:800;

sky_container(:,:,1) = sky;

%ggggg
sky_container = zeros(size(sky,1),size(sky,2),22*14);
Tcoordsky_real = zeros(2,22*14);
yA_vec = [1:50:(size(sky,1)-500)];
yB_vec = yA_vec;
xA_vec = [1:50:(size(sky,2)-500)];
xB_vec = [1:50:(size(sky,2)-500)]+50;
k = 0;
[sky_container(:,:,1),Tcoordsky_real(:,1)] = Paste_moving_T(sky,t(1),I_T,size_T);

for n = 1:size(yA_vec,2)
    for i = 1:size(xA_vec,2)
        k = k+1;
        time = t(k);
        [sky_container(:,:,i+1),Tcoordsky_real(:,i+1)] = Paste_moving_T(sky,time,I_T,size_T);
        
        xA = xA_vec(i);
        yA = yA_vec(n);
        xB = xB_vec(i);
        yB = yB_vec(n);
        

        % photoA
        photoA = sky_container(yA:yA+l-1,xA:xA+l-1,i); 
        
        % photoB
        photoB = sky_container(yB:yB+l-1,xB:xB+l-1,i+1);

        [result,Tcoord,plots] = TargetFinder(photoA,photoB);

        if result ~= [0 0]
            break
        end
        
figure(1)
imshow(sky_container(:,:,i+1)); hold on
% plot(Tcoordsky_real(1,i+1),Tcoordsky_real(2,i+1),'bo'); hold on
% plot(Tcoordsky_real(1,i),Tcoordsky_real(2,i),'ro'); hold on
rectangle('Position',[xA,yA,l,l],'LineWidth',2,'EdgeColor','r'); hold on
rectangle('Position',[xB,yB,l,l],'LineWidth',2,'EdgeColor','b');
pause(0.1);

    end
    if result ~= [0 0]
        break
    end
end

figure(1)
plot(Tcoordsky_real(1,i),Tcoordsky_real(2,i),'bo','LineWidth',2);


% figure(2)
% imshow(photoA); hold on
% plot(Tcoord.xA,Tcoord.yA,'ro','LineWidth',2);
% 
% figure(3)
% imshow(photoB); hold on
% plot(Tcoord.xB,Tcoord.yB,'bo','LineWidth',2);



