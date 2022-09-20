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

% time vector of the photos
t = 1:1:100;

% setting of the Target reflection
size_T_vec = 5*ones(size(t));     % pixel size
I_T_vec = rand(size(t));        % intensity

% setting of the photos
l = 480;

% save memory for photos of the sky at differet t (moving T)
sky_container = zeros(size(sky,1),size(sky,2),size(t,2));

%% [ Scan setting ] 

% save memory for real coordinates of T
Tcoordsky_real = zeros(2,size(t,2));

% set pixel steps for the scan
step_x = 100;     % pixel step between two photos (coordinate of the top left corner)
step_y = 200;     % pixel step between two photos (coordinate of the top left corner)

% top-left corner coordinates of the photos
y_vec = 1:step_y:(size(sky,1)-l);
x_vec = 1:step_x:(size(sky,2)-l);


%---------- extract photos at t1
[sky_container(:,:,1),Tcoordsky_real(:,1)] = Paste_moving_T(sky,t(1),I_T_vec(1),size_T_vec(1));

% photoA
photoB = sky_container(y_vec(1):y_vec(1)+l-1,x_vec(1):x_vec(1)+l-1,1);

% show sky at t1
figure(1)
imshow(sky_container(:,:,1)); hold on; 
rectangle('Position',[x_vec(1),y_vec(1),l,l],'LineWidth',2,'EdgeColor','b'); hold on
F(1) = getframe(gcf); % save frame for video 
drawnow;

result = [0 0]; 
k = 1;
xB = x_vec(1);
yB = y_vec(1);
for n = 1:size(y_vec,2)
    if rem(n,2) == 1            % if n is odd scan goes left to right
        for m = 1:size(x_vec,2)
            k = k+1;
            [sky_container(:,:,k),Tcoordsky_real(:,k)] = Paste_moving_T(sky,t(k),I_T_vec(k),size_T_vec(k));
           
            % old second photo becomes new first photo
            xA = xB;        
            yA = yB;
            % coord of new photo
            xB = x_vec(m);
            yB = y_vec(n);
                
            % photoA (old new photo becomes old photo)
            photoA = photoB; 
          
            % photoB (extract new photo)
            photoB = sky_container(yB:yB+l-1,xB:xB+l-1,k);
    
            % show timestep t
            figure(1)
            imshow(sky_container(:,:,k)); hold on           
            rectangle('Position',[xA,yA,l,l],'LineWidth',2,'EdgeColor','r'); hold on
            rectangle('Position',[xB,yB,l,l],'LineWidth',2,'EdgeColor','b');
            F(k) = getframe(gcf);  % save video frame
            drawnow;

            % run TargetFinder
            [result,Tcoord,plots] = TargetFinder(photoA,photoB);
            
            if sum(result) ~= 0     % if TargetFinder found something
                % plot the Target coord found
                figure(1)
                plot(Tcoord.xB+xB,Tcoord.yB+yB,'g*','LineWidth',2); hold on;
                F(k) = getframe(gcf);   % video frame
                drawnow
                break
            end
        end
    else
        for m = 1:size(x_vec,2)
            k = k+1;
            [sky_container(:,:,k),Tcoordsky_real(:,k)] = Paste_moving_T(sky,t(k),I_T_vec(k),size_T_vec(k));
            
            % flip vector to go right to left
            flipped_x_vec = flip(x_vec);
       
            % old second photo becomes new first photo
            xA = xB;
            yA = yB;
            % coord of new photo
            xB = flipped_x_vec(m);
            yB = y_vec(n);
            
    
            % photoA (old new photo becomes old photo)
            photoA = photoB; 
            
            % photoB (extract new photo)
            photoB = sky_container(yB:yB+l-1,xB:xB+l-1,k);
    
            % show timestep t
            figure(1)
            imshow(sky_container(:,:,k)); hold on;
            rectangle('Position',[xA,yA,l,l],'LineWidth',2,'EdgeColor','r'); hold on
            rectangle('Position',[xB,yB,l,l],'LineWidth',2,'EdgeColor','b');
            F(k) = getframe(gcf) ;  % video frame
            drawnow

            % run TargetFinder
            [result,Tcoord,plots] = TargetFinder(photoA,photoB);
            
            if sum(result) ~= 0 % if TargetFinder found something
                % plot the Target coord found
                figure(1)
                plot(Tcoord.xB+xB,Tcoord.yB+yB,'g*','LineWidth',2); hold on
                F(k) = getframe(gcf);   % video frame
                drawnow
                break
            end
        end
    end
    if sum(result) ~= 0
        break
    end
end

%---------- save video
writerObj = VideoWriter('myVideo.avi');
writerObj.FrameRate = 2;
open(writerObj);    % open the video writer
% write the frames to the video
for i=1:length(F)
    frame = F(i) ;  % convert the image to a frame
    writeVideo(writerObj, frame);
end
close(writerObj);   % close the writer object




% show photo where the Target was found

% photo A
figure(2)
imshow(photoA); hold on
plot(Tcoord.xA,Tcoord.yA,'ro','LineWidth',2);

% photo B
figure(3)
imshow(photoB); hold on
plot(Tcoord.xB,Tcoord.yB,'bo','LineWidth',2);


