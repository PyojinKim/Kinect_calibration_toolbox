%[params,params_error]=calibrate_kinect(options,rgb_grid_p,rgb_grid_x,depth_plane_points,depth_plane_disparity,params0)
% Performas a non-linear minimization of the calibration parameters using
% levenberg-marquardt algorithm.
%
% options struct created with calibrate_kinect_options()
% rgb_grid_p {K}{N}[2xP] cell array of color corner locations in image coordinates
% rgb_grid_x {K}{N}[2xP] cell array of color corner locations in world coordinates
% depth_plane_points {N}[2xP] cell array of image coordinates of points in the 
%     depth image that belong to the calibration plane.
% depth_plane_disparity {N}[1xP] cell array of disparity values of points in the 
%     depth image that belong to the calibration plane.
% params0 struct with the following fields:
% 	rK {K}[fx 0 u0; 0 fy v0; 0 0 1] intrinsics for rgb camera 
% 	rkc {K}[1x5] distortion coefficients for rgb camera
% 	rR {K}[3x3] rotation matrix from camera k to camera 1 (r1X = rR{k} * rkX + rt{k})
% 	rt {K}[3x1] translation vector from camera k to camera 1 (r1X = rR{k} *	rkX + rt{k})
% 	dK [fx 0 u0; 0 fy v0; 0 0 1] intrinsics for depth camera 
% 	dkc [1x5] distortion coefficients for depth camera
% 	dc [1x2] coefficients for disparity-depth function
% 	dR [3x3] relative rotation matrix (r1X = dR * dX + dt)
% 	dt [3x1] relative translation vector (r1X = dR * dX + dt)
% 	Rext {N}[3x3] cell array of rotation matrices grid to camera 1
%             one for each image (r1X = Rext * gridX + text)
% 	text {N}[3x1] cell array of translation vectors grid to camera 1
%             one for each image (r1X = Rext * gridX + text)
%
% params calibrated parameters, same structure as params0
% params_error tolerances of the calibration parameters
%
% Kinect calibration toolbox by DHC
function [calib,calib_jacobian,color_error,depth_error]=calibrate_kinect(options,rgb_grid_p,rgb_grid_x,depth_plane_points,depth_plane_disparity,calib0)
  %Fix options
  if(length(options.use_fixed_dkc) == 1)
    options.use_fixed_dkc = repmat(options.use_fixed_dkc,1,5);
  end
  if(length(options.use_fixed_dc) == 1)
    options.use_fixed_dc = repmat(options.use_fixed_dc,1,2);
  end
  if(length(options.use_fixed_rkc) == 1)
    options.use_fixed_rkc = repmat(options.use_fixed_rkc,1,5);
  end

  %Encode params
  raw0 = calibrate_kinect_s2r(calib0,options);


  %Minimize
  minimization_options=optimset('LargeScale','off',...
    'Algorithm','levenberg-marquardt',...
    'Display',options.display, ...
    'OutputFcn', @my_output_fcn, ...
    'TolFun',1e-4,...
    'TolX',1e-8,...
    'MaxFunEvals',20000,...
    'MaxIter',1000);

  % jacob_pattern = calibrate_kinect_jacobian_pattern(options,params0,rgb_grid_p,depth_plane_points);
  % minimization_options=optimset('LargeScale','on','JacobPattern',jacob_pattern,'Display',options.display, 'TolFun',1e-4,'TolX',1e-8,'MaxFunEvals',20000,'MaxIter',1000);

  if(~strcmp(options.display,'off'))
    fprintf('Minimizing cost function over %d parameters...',length(raw0));
  end
  tStart = tic();
  [raw_final,~,~,~,~,~,calib_jacobian] = lsqnonlin(@(x) calibrate_kinect_cost_raw(x,options,rgb_grid_p,rgb_grid_x,depth_plane_points,depth_plane_disparity,calib0),raw0,[],[],minimization_options);
  tElapsed = toc(tStart);
  if(~strcmp(options.display,'off'))
    display(['Done ' num2str(tElapsed) 's']);
  end

  %Decode params
  calib = calibrate_kinect_r2s(raw_final,options,calib0);

  use_color = ~(options.use_fixed_rK && all(options.use_fixed_rkc) && options.use_fixed_pose);
  use_depth = ~(options.use_fixed_dK && all(options.use_fixed_dkc) && all(options.use_fixed_dc) && options.use_fixed_dR && options.use_fixed_dt && options.use_fixed_pose) && ~isempty(depth_plane_disparity);

  %Add error variances
  if(use_depth)
    depth_error = calibrate_kinect_cost_depth(calib,options,depth_plane_points,depth_plane_disparity);
    calib.depth_error_var = var(depth_error);
  else
    depth_error = [];
  end
  if(use_color)
    color_error = calibrate_kinect_cost_color(calib,options,rgb_grid_p,rgb_grid_x);
    calib.color_error_var = cellfun(@(x) var(x),color_error);
  else
    color_error = [];
  end
end

function res=my_output_fcn(cost,optimValues,state)
  fprintf('.');
  res = false;
end