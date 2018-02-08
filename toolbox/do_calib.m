%do_calib()
% UI function
% Kinect calibration toolbox by DHC
function do_calib(use_depth_kc,use_depth_distortion)

%Inputs
global rgb_grid_p rgb_grid_x
global dataset_path dfiles depth_plane_mask
global calib0
global max_depth_sample_count
%Outputs
global is_validation
global final_calib final_calib_error

%Check previous steps
if(isempty(rgb_grid_p))
  do_select_rgb_corners();
end
if(isempty(depth_plane_mask))
  do_select_planes();
end
if(isempty(calib0))
  do_initial_rgb_calib();
  do_fixed_depth_calib();
end
if(isempty(calib0.rK))
  do_initial_rgb_calib();
end
if(isempty(calib0.dK))
  do_fixed_depth_calib();
end
if(isempty(calib0.dc))
  do_fixed_depth_calib();
end

if(nargin < 1)
  use_depth_kc = false;
end
if(nargin < 2)
  use_depth_distortion = true;
end

ccount = length(rgb_grid_p);
icount = length(dfiles);

%Get depth samples
fprintf('Extracting disparity samples...\n');
[depth_plane_points,depth_plane_disparity] = get_depth_samples(dataset_path,dfiles,depth_plane_mask);
initial_count = sum(cellfun(@(x) size(x,2),depth_plane_points));
[depth_plane_points,depth_plane_disparity] = reduce_depth_samples(depth_plane_points,depth_plane_disparity,max_depth_sample_count);
total_count = sum(cellfun(@(x) size(x,2),depth_plane_points));
fprintf('Initial disparity samples: %d, using %d.\n',initial_count,total_count);

fprintf('-------------------\n');
fprintf('Joint RGB-Depth calibration\n');
fprintf('-------------------\n');

%Joint minimization
options = calibrate_kinect_options();
options.use_fixed_rK = false;
options.use_fixed_rkc = [false false false false false];
options.use_fixed_dK = false;
% options.use_fixed_dkc = [false false false false true];
options.use_fixed_dkc = [true true true true true];
options.use_fixed_dR = false;
options.use_fixed_dt = false;
options.use_fixed_pose = false;
options.display = 'iter';

options2 = calibrate_kinect_options();
options2.use_fixed_rK = true;
options2.use_fixed_rkc = true;
options2.use_fixed_dK = false;
options2.use_fixed_dkc = [false false false false true];
options2.use_fixed_dR = true;
options2.use_fixed_dt = true;
options2.use_fixed_pose = true;
options2.display = 'iter';

converged=false;
i=1;
calib_new = calib0;

%Fixed variances
use_fixed_vars = true;
fixed_color_var = [ 0.18     0.30].^2;
fixed_depth_var = 0.9^2;

%Cost
new_color_cost = calibrate_kinect_cost_color(calib_new,options,rgb_grid_p,rgb_grid_x);
new_color_cost_sum = cellfun(@(x) sum(x.^2), new_color_cost);
new_depth_cost = calibrate_kinect_cost_depth(calib_new,options,depth_plane_points,depth_plane_disparity);
new_depth_cost_sum = sum(new_depth_cost.^2);
fprintf('Initial cost: ');
for k=1:length(new_color_cost)
  fprintf('%.0fpx, ',new_color_cost_sum(k));
end
fprintf('%.0fkdu\n',new_depth_cost_sum);

while(~converged)
  fprintf('-------------------------\n');
  fprintf('Pass #%d\n',i);
  fprintf('-------------------------\n');
  calib_old = calib_new;
  old_color_cost_sum = new_color_cost_sum;
  old_depth_cost_sum = new_depth_cost_sum;

  old_var.color_error_var = calib_old.color_error_var;
  old_var.depth_error_var = calib_old.depth_error_var;
  if(use_fixed_vars)
    calib_old.color_error_var = fixed_color_var;
    calib_old.depth_error_var = fixed_depth_var;
  end
  
  %Calibrate general parameters
%   if(use_depth_kc)
%     %If we're optimizing the geometric distortion, fix the intrinsics to
%     %speed up the general parameter refinement.
%     if(any(calib_old.dkc))
%       options.use_fixed_dK = true;
%     else
%       options.use_fixed_dK = false;
%     end
%   end
  fprintf('Pass #%d: Calibrating general parameters...\n', i);  
  [calib_new,jacobian,cerror,derror]=calibrate_kinect(options,rgb_grid_p,rgb_grid_x,depth_plane_points,depth_plane_disparity,calib_old);

  %Calibrate depth distortion
  if(use_depth_distortion)
    %Calibrate distortion
    fprintf('Pass #%d: Calibrating depth distortion...\n', i);  
    [calib_new.dc_alpha,calib_new.dc_beta]=calib_distortion(calib_new,calib_new.Rext, calib_new.text, dataset_path, dfiles, depth_plane_mask);
%       [calib_new.dc_woffset]=calib_distortion_woffset(calib_new,calib_new.Rext, calib_new.text, dfiles, depth_plane_mask);
  end
  
  %Calibrate depth geometric distortion
  if(use_depth_kc)
%     fprintf('Pass #%d: Calibrating geometric distortion...\n', i);
%     calib_new.color_error_var = calib_old.color_error_var;
%     calib_new.depth_error_var = calib_old.depth_error_var;
%     [calib_new,~,~,~]=calibrate_kinect(options2,rgb_grid_p,rgb_grid_x,depth_plane_points,depth_plane_disparity,calib_new);
  end
  
  %Calculate cost
  new_color_cost = calibrate_kinect_cost_color(calib_new,options,rgb_grid_p,rgb_grid_x);
  new_color_cost_sum = cellfun(@(x) sum(x.^2), new_color_cost);
  new_depth_cost = calibrate_kinect_cost_depth(calib_new,options,depth_plane_points,depth_plane_disparity);
  new_depth_cost_sum = sum(new_depth_cost.^2);
  fprintf('Pass #%d costs: ',i);
  for k=1:length(new_color_cost)
    fprintf('%.0fpx, ',new_color_cost_sum(k));
  end
  fprintf('%.0fkdu\n',new_depth_cost_sum);

  %Get variances
  calib_new.color_error_var = cellfun(@var,new_color_cost);
  calib_new.depth_error_var = var(new_depth_cost);
  
  fprintf('Pass #%d stats:\n',i);
  for k=1:length(new_color_cost)
    [sigma,sigma_lower,sigma_upper] = std_interval(new_color_cost{k},0.99);
    fprintf('Color %d: mean=%f, std=%f [-%f,+%f] (pixels)\n',k,mean(new_color_cost{k}),sigma,sigma_lower,sigma_upper);
  end
  [sigma,sigma_lower,sigma_upper] = std_interval(new_depth_cost,0.99);
  fprintf('mean=%f, std=%f [-%f,+%f] (disparity)\n',mean(new_depth_cost),sigma,sigma_lower,sigma_upper);

  if(~use_depth_distortion && ~use_depth_kc)
    converged = true;
  else
    converged = true;
    
    old_std = [old_var.color_error_var, old_var.depth_error_var].^0.5;
    new_std = [calib_new.color_error_var, calib_new.depth_error_var].^0.5;
    if(any( abs(old_std-new_std)./new_std >= 0.01 ) )
      fprintf('Error variance has changed, will iterate again.\n');
      converged = false;
    end
    
    old_cost = [old_color_cost_sum, old_depth_cost_sum];
    new_cost = [new_color_cost_sum, new_depth_cost_sum];
    if(any( abs(old_cost-new_cost)./new_cost >= 0.01 ))
      fprintf('Error residuals have changed, will iterate again.\n');
      converged = false;
    end
  end
%   converged = true;
  i=i+1;
end

final_calib = calib_new;
final_calib_error = calibrate_kinect_tolerance(options,calib_new,jacobian,cerror,derror);

fprintf('Calibration finished.\n');
print_calib(final_calib, final_calib_error);
print_calib_stats(final_calib);

is_validation = false;