function plot_rgb_corners(camera_k,image_i,p)
  global dataset_path rfiles
  k = camera_k;
  i = image_i;

  if(nargin<3)
    global rgb_grid_p %rgb_grid_x

    p = rgb_grid_p{k}{i};
    %x = rgb_grid_x{k}{i};
  end

  count = size(p,2);

  if(isempty(rfiles{k}{i}))
    fprintf('Camera %d has no image for pose %d.\n',k,i);
    return;
  end
  
  imshow([dataset_path rfiles{k}{i}],'InitialMagnification','fit');

  if(isempty(p))
    fprintf('Camera %d has no corners for image %d.\n',k,i);
    return;
  end

  hold on;
  plot(p(1,:)+1, p(2,:)+1, 'r+','DisplayName','Selected corners');
  title(sprintf('Cam %d, img %d',k,i));
  
  s = cell(1,count);
  for j=1:count
    %s{j} = sprintf('#%d\n(%.3f,%.3f)',j,x(1,j),x(2,j));
    s{j} = sprintf('%d',j);
  end
  h=text(p(1,:)-3, p(2,:)-3,s);
  set(h,'color','red');
  
  min_x = min(p(1,:))-6;
  max_x = max(p(1,:))+6;
  min_y = min(p(2,:))-6;
  max_y = max(p(2,:))+6;
  axis([min_x max_x min_y max_y]);
end