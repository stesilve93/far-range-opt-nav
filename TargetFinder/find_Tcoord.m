function [Tcoord,result,diff_cropped] = find_Tcoord(x0,y0,photoA,photoB)

%--------------------------------------------------------------------------
% Compute the difference image and find the coordinate of the two Target
% reflection in the two photos
%--------------------------------------------------------------------------

% crop the second photo in the right coordinate
photoB_cropped = zeros(size(photoA));
photoB_cropped(y0+1:end,x0+1:end) = photoB(1:size(photoB,2)-y0,1:size(photoB,1)-x0);

% compute the difference image
diff = photoA-photoB_cropped;
diff_cropped = diff(y0+1:end,x0+1:end); % this is just the overlapping of 
                                        % the two photos (does not show the 
                                        % border stars

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

    Tcoord.xA = x_A + x0;
    Tcoord.yA = y_A + y0;
end

% find the Target in the second photo
if min(min(diff_cropped(10:end-10,10:end-10)))<-0.2
    result = result + [0 1]; %Target is found
    [y_B,x_B] = find(diff_cropped == min(min(diff_cropped(10:end-10,10:end-10))));
    
    y_B = round(mean(y_B));
    x_B = round(mean(x_B));
    
    Tcoord.xB = x_B;
    Tcoord.yB = y_B;
end
                                







end

