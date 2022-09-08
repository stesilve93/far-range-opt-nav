function [pos_T_found,result,diff_cropped] = find_Tcoord(x0,y0,photoA,photoB)

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

pos_T_found.xA = NaN;
pos_T_found.yA = NaN;
pos_T_found.xB = NaN;
pos_T_found.yB = NaN;
result = 0;

% find the Target in the second photo
if min(min(diff_cropped))<-0.2
    result = 1; %Target is found
    [y_B,x_B] = find(diff_cropped == min(min(diff_cropped)));
    
    y_B = round(mean(y_B));
    x_B = round(mean(x_B));
    
    pos_T_found.xB = x_B;
    pos_T_found.yB = y_B;


    % find the Target in the first photo (if the condition is satisfied)
    if max(max(diff_cropped)) > 0.2
        result = 2; %Target found in both photos
    
        [y_A,x_A] = find(diff_cropped == max(max(diff_cropped)));
    
        y_A = round(mean(y_A));
        x_A = round(mean(x_A));
    
        pos_T_found.xA = x_A + x0;
        pos_T_found.yA = y_A + y0;
    end
end
                                        


    




end

