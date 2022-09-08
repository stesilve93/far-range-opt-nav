function [x_T_A,y_T_A,x_T_B,y_T_B,diff_cropped] = find_Tcoord(x0,y0,photoA,photoB)

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

% find the maximum and the minimum coordinates of the difference image

% photoA
if max(max(diff_cropped)) > 0.5

[y_A,x_A] = find(diff_cropped == max(max(diff_cropped)));


x_T_A = x_A + x0;
y_T_A = y_A + y0;
end

[y_B,x_B] = find(diff_cropped == min(min(diff_cropped)));
x_T_B = x_B;
y_T_B = y_B;


end

