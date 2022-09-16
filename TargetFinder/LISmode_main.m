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
size_T = 5;     % pixel size
I_T = 1;        % intensity

% setting of the photo
l = 480;

% time vector of the photos
t = 1:1:800;

% save photos of the sky with moving Target
sky_container = zeros(size(sky,1),size(sky,2),size(t,2));
[sky_container(:,:,1),~] = Paste_moving_T(sky,t(1),I_T,size_T);


%% Scan setting 

Tcoordsky_real = zeros(2,size(t,2));
step = 100;     % step between two photos (coordinate of the top left corner)

% top-left corner coordinates
y_vec = 1:step:(size(sky,1)-l);
x_vec = 1:step:(size(sky,2)-(l+step));

k = 0;


for n = 1:size(y_vec,2)-1
    
    if rem(n,2) == 1
        for m = 1:size(x_vec,2)-1
            
            k = k+1;
            
            [sky_container(:,:,m+1),Tcoordsky_real(:,m+1)] = Paste_moving_T(sky,t(k),I_T,size_T);
            
            xA = x_vec(m);
            yA = y_vec(n);
            xB = x_vec(m+1);
            yB = y_vec(n);
            
    
            % photoA
            photoA = sky_container(yA:yA+l-1,xA:xA+l-1,m); 
            
            % photoB
            photoB = sky_container(yB:yB+l-1,xB:xB+l-1,m+1);
    
            [result,Tcoord,plots] = TargetFinder(photoA,photoB);
    
            if result ~= [0 0]
                break
            end

            figure(1)
            imshow(sky_container(:,:,m+1)); hold on
            if ~isnan(Tcoord.xB)
            plot(Tcoord.xB+xB,Tcoord.yB+yB,'bo','LineWidth',2); hold on
            end
            rectangle('Position',[xA,yA,l,l],'LineWidth',2,'EdgeColor','r'); hold on
            rectangle('Position',[xB,yB,l,l],'LineWidth',2,'EdgeColor','b');
        
            F(k) = getframe(gcf) ;
            drawnow

           
        end
    else
            for m = 1:size(x_vec,2)-1
            
                k = k+1;
            
            [sky_container(:,:,m+1),Tcoordsky_real(:,m+1)] = Paste_moving_T(sky,t(k),I_T,size_T);
            
            flipped_x_vec = flip(x_vec);
            xA = flipped_x_vec(m);
            yA = y_vec(n);
            xB = flipped_x_vec(m+1);
            yB = y_vec(n);
            
    
            % photoA
            photoB = sky_container(yA:yA+l-1,xA:xA+l-1,m); 
            
            % photoB
            photoA = sky_container(yB:yB+l-1,xB:xB+l-1,m+1);
    
            [result,Tcoord,plots] = TargetFinder(photoA,photoB);
    
            if result ~= [0 0]
                break
            end

            figure(1)
            imshow(sky_container(:,:,m+1)); hold on
            if ~isnan(Tcoord.xB)
            plot(Tcoord.xB+xB,Tcoord.yB+yB,'bo','LineWidth',2); hold on
            end
            rectangle('Position',[xA,yA,l,l],'LineWidth',2,'EdgeColor','r'); hold on
            rectangle('Position',[xB,yB,l,l],'LineWidth',2,'EdgeColor','b');
           
            F(k) = getframe(gcf) ;
            drawnow
            end
    end
     
    



    if result ~= [0 0]
        break
    end
end




writerObj = VideoWriter('myVideo.avi');
writerObj.FrameRate = 2;

% open the video writer
open(writerObj);
% write the frames to the video
for i=1:length(F)
    % convert the image to a frame
    frame = F(i) ;    
    writeVideo(writerObj, frame);
end
% close the writer object
close(writerObj);





figure(2)
imshow(photoA); hold on
plot(Tcoord.xA,Tcoord.yA,'ro','LineWidth',2);

figure(3)
imshow(photoB); hold on
plot(Tcoord.xB,Tcoord.yB,'bo','LineWidth',2);



