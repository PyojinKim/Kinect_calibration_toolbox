% cost=calibrate_kinect_cost(raw_params,options,rgb_grid_p,rgb_grid_x,depth_plane_points,depth_plane_disparity,params0)
% Cost function used by calibrate_kinect.
%
% Kinect calibration toolbox by DHC
function cost=calibrate_kinect_cost_raw(raw_params,options,rgb_grid_p,rgb_grid_x,depth_plane_points,depth_plane_disparity,params0)
  params = calibrate_kinect_r2s(raw_params,options,params0);
  [color_cost,depth_cost] = calibrate_kinect_cost(params,options,rgb_grid_p,rgb_grid_x,depth_plane_points,depth_plane_disparity);
  
  cost = [];
  for k=1:length(color_cost)
    cost = [cost; color_cost{k}];
  end
  cost = [cost; depth_cost];
end