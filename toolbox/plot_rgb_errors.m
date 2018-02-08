function plot_rgb_errors(calib,camera_k,grid_p,grid_x,Rext,text)
  if(nargin < 4)
    global rgb_grid_p rgb_grid_x
    grid_p = rgb_grid_p;
    grid_x = rgb_grid_x;
  end
  if(nargin < 6)
    Rext = calib.Rext;
    text = calib.text;
  end  
  icount = length(grid_p{1});
  
  figure();
  clf;
  title(sprintf('Reprojection errors (in pixels) for color camers #%d',camera_k));
  colors = 'brgkcm';
  hold on
  
  k = camera_k;
  errors = [];
  for i=find(~cellfun(@(x) isempty(x),grid_p{k}))
    R = calib.rR{k}'*Rext{i};
    t = calib.rR{k}'*(text{i} - calib.rt{k});
    p = project_points_k(grid_x{k}{i},calib.rK{k},calib.rkc{k},R,t);

    %errors_i = sum((p-rgb_grid_p{k}{i}).^2,1).^0.5;
    errors_i = p-grid_p{k}{i};

    s = sprintf('Image #%d',i);
    plot(errors_i(1,:), errors_i(2,:), [colors(rem(i,6)+1) '+'],'DisplayName', s);

    fprintf('Image #%d: mean=%f, std=%f\n',i,mean(errors_i(:)),std(errors_i(:)));

    errors = [errors, errors_i(:)'];
  end
  fprintf('Total: mean=%f, std=%f\n',mean(errors(:)),std(errors(:)));
  
  figure();
  edges = min(errors):0.05:max(errors);
  hist(errors,edges);
  title(sprintf('Corner reprojecton histogram over all images. Total mean=%f, total std=%f', mean(errors),std(errors)));
  xlabel('Errors (pixels)');
  ylabel('Count');
end
 