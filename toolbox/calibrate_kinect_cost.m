% cost=calibrate_kinect_cost(raw_params,options,rgb_grid_p,rgb_grid_x,depth_plane_points,depth_plane_disparity,params0)
% Cost function used by calibrate_kinect.
%
% Kinect calibration toolbox by DHC
function [color_cost,depth_cost]=calibrate_kinect_cost(params,options,rgb_grid_p,rgb_grid_x,depth_plane_points,depth_plane_disparity)

use_color = ~(options.use_fixed_rK && all(options.use_fixed_rkc) && options.use_fixed_rRt && options.use_fixed_pose);
use_depth = ~(options.use_fixed_dK && all(options.use_fixed_dkc) && all(options.use_fixed_dc) && options.use_fixed_dR && options.use_fixed_dt && options.use_fixed_pose) && ~isempty(depth_plane_disparity);

color_cost = cell(1,length(rgb_grid_p));
depth_cost = [];

if(use_color)
  color_error = calibrate_kinect_cost_color(params,options,rgb_grid_p,rgb_grid_x);
  for k=1:length(color_error)
    color_cost{k} = color_error{k}/sqrt(params.color_error_var(k));
  end
end

if(use_depth)
  depth_error = calibrate_kinect_cost_depth(params,options,depth_plane_points,depth_plane_disparity);
  depth_cost = depth_error/sqrt(params.depth_error_var);
end