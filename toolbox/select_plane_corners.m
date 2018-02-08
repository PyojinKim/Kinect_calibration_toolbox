%corners=select_plane_corners(imd)
% UI function. Asks the user to select the plane corners for the depth
% images.
%
% Kinect calibration toolbox by DHC
function corners=select_plane_corners(imd)

corners = zeros(2,4);

%Show img
im_rgb = visualize_disparity(imd);
figure(1);
clf;
imshow(im_rgb);
title('LMB=select corner, RMB or Esc=skip image');
hold on
for i=1:4
  [x,y,b] = ginput(1);
  if(b==1)
    corners(:,i) = [x;y];

    plot(x,y,'ow','MarkerSize',8,'LineWidth',2);
    if(i>1)
      plot([corners(1,i-1) x], [corners(2,i-1) y], '-w', 'LineWidth',2);
    end
    if(i==1)
      text(x,y-20,'O','Color','white','FontSize',12,'FontWeight','bold');
    elseif(i==2)
      text(mean(corners(1,[1,2]))-20, mean(corners(2,[1,2])), 'X', 'Color','white','FontSize',12,'FontWeight','bold');
    elseif(i==3)
      text(mean(corners(1,[2,3])), mean(corners(2,[2,3]))-20, 'Y', 'Color','white','FontSize',12,'FontWeight','bold');
    elseif(i==4)
      plot([corners(1,1) x], [corners(2,1) y], '-w', 'LineWidth',2);
    end
  elseif(b==3 || b==27)
    corners = [];
    return;
  end
end
hold off

%Correct index
corners = corners-1;