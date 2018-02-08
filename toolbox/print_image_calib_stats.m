function print_image_calib_stats(calib)
  global dataset_path rfiles
  global dfiles depth_plane_mask
  
  fprintf('Calib stats per image\n');
  [~,im,is]=get_rgb_errors(calib);
  for i=1:length(dfiles)
    fprintf('#%d ',i);
    
    for k = 1:length(rfiles)
      fprintf('Color %d=(%.3f,%.3f), ',k,abs(im(i,k)),is(i,k));
    end
  
    fprintf('Depth=');
    if(isempty(dfiles{i}))
      fprintf('n/a');
    else
      [points,disparity] = get_depth_samples(dataset_path,dfiles{i},depth_plane_mask{i});
      error_i = get_depth_error(calib,points,disparity,calib.Rext{i},calib.text{i});
      fprintf('(%.3f,%.3f)',abs(mean(error_i)),std(error_i));
    end
    
    fprintf('\n');
  end
end