function plot_depth_reprojection(calib, image_i)
  global dataset_path dfiles
  global depth_plane_poly depth_plane_mask
  i = image_i;
  
  imd = read_disparity([dataset_path dfiles{i}]);
  [height,width] = size(imd);
  
  im_rgb = visualize_disparity(imd);
  
  figure();
  clf;
  
  imshow(im_rgb);
  hold on;
  polygon = depth_plane_poly{i};
  plot(polygon(1,:),polygon(2,:),'ow');
  plot([polygon(1,:) polygon(1,1)],[polygon(2,:) polygon(2,1)],'-w');
  
  mask_img = cat(3, 1*ones(height,width),0*zeros(height,width),0*ones(height,width));
  h = imshow(mask_img);
  set(h,'AlphaData',0.3*depth_plane_mask{i});

  [points,disp] = get_depth_samples(dataset_path,dfiles{i},depth_plane_mask{i});
  [errors] = get_depth_error(calib,points,disp,calib.Rext{i},calib.text{i});
  figure();
  min_x = min(errors);
  max_x = max(errors);
  edges = min_x:0.2:max_x;
  c = histc(errors,edges);
  bar(edges,c);
  s= sprintf('Image #%d: mean=%f, std=%f\n',i,mean(errors(:)),std(errors(:)));
  title(s);
  
  im_error = nan(size(imd));
  %im_error(sub2ind(size(imd),points(2,:)+1,points(1,:)+1)) = abs(errors);
  %imtool(im_error,[0 3*calib.depth_error_var.^0.5]);
  im_error(sub2ind(size(imd),points(2,:)+1,points(1,:)+1)) = errors;
  imtool(im_error,[-3*calib.depth_error_var.^0.5 3*calib.depth_error_var.^0.5]);
end