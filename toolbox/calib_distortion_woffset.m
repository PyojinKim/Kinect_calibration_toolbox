function [woffset]=calib_distortion_woffset(depth_calib, Rext, text, dfiles, depth_plane_mask)
  width = 640;
  height = 480;

  if(~isfield(depth_calib,'dc_woffset'))
    depth_calib.dc_woffset = [];
  end

  %Remove distortion correction from depth_calib
  woffset = depth_calib.dc_woffset;
  depth_calib.dc_alpha = [];
  depth_calib.dc_beta = [];
  depth_calib.dc_woffset = [];
  
  fprintf('Gathering samples...');   
  
  %Get errors
  points_ind = [];
  errors = [];
  for i=find(~cellfun(@isempty,dfiles))
    [points_i,disparity_i] = get_depth_samples(dfiles{i},depth_plane_mask{i});
    points_ind_i = sub2ind([height,width],points_i(2,:)+1,points_i(1,:)+1);
    [~,~,error_i] = get_depth_error(depth_calib,points_i,disparity_i,Rext{i},text{i});

    points_ind = [points_ind, points_ind_i];
    errors = [errors, error_i];
  end
  
  %Sort for per pixel optimization
  [points_ind,i]=sort(points_ind);
  errors = errors(i);
  
  %
  fprintf('Done.\n');

  fprintf('Minimizing...\n');

  %Initial value
  if(isempty(woffset))
    woffset = zeros(480,640);
  end
  
  minimization_options=optimset('LargeScale','off',...
    'Algorithm','levenberg-marquardt',...
    'Display','none',...
    'OutputFcn', @my_output_fcn, ...
    'TolFun',1e-6,...
    'TolX',1e-9,...
    'MaxFunEvals',20000,...
    'MaxIter',1000);

  %Optimize woffsets
  fprintf('Optimizing woffset...');
  counter=0;
  i=1;
  while(i<=length(points_ind))
    ind = points_ind(i);
    j=i;
    while(j<=length(points_ind) && points_ind(j)==ind)
      j=j+1;
    end

    dc = errors(i:j-1);
    i=j;

    woffset(ind) = -mean(dc);

    if((i-counter)/(length(points_ind)) > 0.1)
      fprintf('.');
      counter=i;
    end
  end
end