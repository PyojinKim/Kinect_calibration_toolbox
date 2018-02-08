%cost=rgb_calib_cost(raw,params0,rgb_grid_p,rgb_grid_x,use_fixed_intrinsic)
% Cost function for rgb_calib(). Reprojects corners onto image and compares
% pixel positions.
%
% Kinect calibration toolbox by DHC
function cost=rgb_calib_cost(raw,params0,rgb_grid_p,rgb_grid_x,use_fixed_intrinsic)

params = rgb_calib_r2p(raw,params0,use_fixed_intrinsic);

cost=[];
for i=find(~cellfun(@(x) isempty(x),rgb_grid_p))
  p = project_points_k(rgb_grid_x{i},params.K,params.kc,params.R{i},params.t{i});

  error = p-rgb_grid_p{i};
  cost = [cost; reshape(error,[numel(error),1])];  
end