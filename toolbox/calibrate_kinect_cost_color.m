% cost=calibrate_kinect_cost_color(params,options,rgb_grid_p,rgb_grid_x)
% Cost for color images, used by calibrate_kinect_cost.
%
% Kinect calibration toolbox by DHC
function cost=calibrate_kinect_cost_color(params,options,rgb_grid_p,rgb_grid_x)

ccount = length(rgb_grid_p);

cost=cell(1,ccount);
for k=1:ccount
  total_count = sum( cellfun(@numel, rgb_grid_p{k}) );
  cost{k} = zeros(total_count,1);
  base = 1;
  
  for i=find(~cellfun(@(x) isempty(x),rgb_grid_p{k}))
    X = rgb_grid_x{k}{i};
    R = params.rR{k}'*params.Rext{i};
    t = params.rR{k}'*(params.text{i} - params.rt{k});
    p = project_points_k(X,params.rK{k},params.rkc{k},R,t);

    error = p-rgb_grid_p{k}{i};
    cost{k}(base:base+numel(error)-1) = error(:);
    base = base+numel(error);
  end
end