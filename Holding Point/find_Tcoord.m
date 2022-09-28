function [Tcoord,result,diff_cropped] = find_Tcoord(x0,y0,photoA,photoB)

%--------------------------------------------------------------------------
% Compute the difference image and find the coordinate of the two Target
% reflection in the two photos
%--------------------------------------------------------------------------

% crop the second photo in the right coordinate
photoB_cropped = zeros(size(photoA));

if x0>=0 && y0>=0
    photoB_cropped(y0+1:end,x0+1:end) = photoB(1:size(photoB,2)-y0,1:size(photoB,1)-x0);
    diff = photoA-photoB_cropped;
    diff_cropped = diff(y0+1:end,x0+1:end);
elseif x0>=0 && y0<=0
    photoB_cropped(1:end+y0,x0+1:end) = photoB(abs(y0)+1:size(photoB,2),1:size(photoB,1)-x0);
    diff = photoA-photoB_cropped;
    diff_cropped = diff(1:end+y0-1,x0+1:end);
elseif x0<=0 && y0>=0
    photoB_cropped(y0+1:end,1:end+x0) = photoB(1:size(photoB,1)-y0,abs(x0)+1:size(photoB,2));
    diff = photoA-photoB_cropped;
    diff_cropped = diff(y0+1:end,1:end+x0-1);
elseif x0<=0 && y0<=0
    photoB_cropped(1:end+y0,1:end+x0) = photoB(abs(y0)+1:size(photoB,2),abs(x0)+1:size(photoB,2));
    diff = photoA-photoB_cropped;
    diff_cropped = diff(1:end+y0-1,1:end+x0-1);
end    
   

Tcoord.xA = NaN;
Tcoord.yA = NaN;
Tcoord.xB = NaN;
Tcoord.yB = NaN;
result = [0 0];


% find the Target in the first photo (if the condition is satisfied)
if max(max(diff_cropped(10:end-10,10:end-10))) > 0.2
    result = result + [1 0]; %Target found in second photo
    [y_A,x_A] = find(diff_cropped == max(max(diff_cropped(10:end-10,10:end-10))));

    y_A = round(mean(y_A));
    x_A = round(mean(x_A));

    Tcoord.xA = x_A + max(x0,0);
    Tcoord.yA = y_A + max(y0,0);
end

% find the Target in the second photo
if min(min(diff_cropped(10:end-10,10:end-10)))<-0.2
    result = result + [0 1]; %Target is found
    [y_B,x_B] = find(diff_cropped == min(min(diff_cropped(10:end-10,10:end-10))));
    
    y_B = round(mean(y_B));
    x_B = round(mean(x_B));
    
    Tcoord.xB = x_B + abs(min(x0,0));
    Tcoord.yB = y_B + abs(min(y0,0));
end
                                







end

