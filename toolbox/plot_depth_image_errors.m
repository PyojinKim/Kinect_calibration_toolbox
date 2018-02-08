function plot_depth_image_errors(calib, image_i)
  global dataset_path dfiles depth_plane_mask

  Rext = calib.Rext;
  text = calib.text;
  if(nargin < 2)
    image_i = 1:length(depth_plane_mask);
  end

  fprintf('Plotting disparity reprojection errors for each depth image\n');
  fprintf('(in raw disparity units)\n');
  
  figure();
  clf;
  hold on
  colors = 'brgkcm';
  
  for i=image_i
    if(isempty(depth_plane_mask{i}))
      continue;
    end
    
    [points,disparity]=get_depth_samples(dataset_path, dfiles{i},depth_plane_mask{i});
    if(isempty(disparity))
      continue;
    end
    
    [errors_disp_i] = get_depth_error(calib,points,disparity,Rext{i},text{i});

    min_x = min(errors_disp_i);
    max_x = max(errors_disp_i);
    edges = min_x:0.2:max_x;
    c = histc(errors_disp_i,edges);
    c = c / sum(c);

    s = sprintf('Image #%d: mean=%f, std=%f',i,mean(errors_disp_i(:)),std(errors_disp_i(:)));
    fprintf([s '\n']);
    
    bar(edges,c,colors(rem(i,6)+1),'DisplayName',s);
%     plot(error_disp, i, [colors(rem(i,6)+1) '+'], 'DisplayName',s);
  end
  
  title('Disparity reprojection error normalized histogram.');
  legend('show')
  xlabel('Error (kinect units)');
  ylabel('Normalized pixel count');
end
