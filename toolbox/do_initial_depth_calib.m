%do_initial_depth_calib()
% UI function
% Kinect calibration toolbox by DHC
function do_initial_depth_calib(use_well_known)

%Inputs
global dataset_path dfiles
global rgb_grid_p rgb_grid_x
global depth_corner_p depth_corner_x
global depth_plane_mask
global max_depth_sample_count
%Outputs
global calib0

if(nargin < 1)
  use_well_known = false;
end

if(isempty(depth_plane_mask))
  do_select_planes();
end
if(isempty(calib0) || isempty(calib0.Rext))
  do_initial_rgb_calib();
end

icount = length(dfiles);
ccount = length(rgb_grid_p);

fprintf('-------------------\n');
fprintf('Initial depth camera calibration\n');
fprintf('-------------------\n');

if(use_well_known)
  fprintf('Using well known values for initial depth camera calibration\n');
  calib0.dK = [  590 0  320;
           0  590 230;
           0  0    1];
  calib0.dkc = [0 0 0 0 0];
  calib0.dR = eye(3);
  calib0.dt = [-0.025 0 0]';
  %calib0.dc = [ -0.0028525         1091];
  calib0.dc = [3.1121, -0.0028525];
else
  fprintf('Estimating initial calibration from depth plane corners.\n');

  %Check previous steps
  if(isempty(depth_corner_p))
    do_select_depth_corners();
  end

  [calib0.dK,calib0.dR,calib0.dt,R0,t0]=estimate_depth_calib_from_corners(depth_corner_x, depth_corner_p, calib0.Rext, calib0.text);
  calib0.dkc = [0 0 0 0 0];
  calib0.dc = estimate_initial_dc(dataset_path,dfiles,depth_corner_p,depth_corner_x,depth_plane_mask,R0,t0);
end
%calib0.dc(3) = 0;
calib0.dc_alpha = [0,0];
calib0.dc_beta = zeros(480,640);
calib0.depth_error_var = 1; %3^2   0.2324;

%Initial pose for depth-only images
fprintf('Estimating initial pose for depth-only images...\n');
missing_rgb = true(1,icount);
for k=1:ccount
  missing_rgb = missing_rgb & cellfun(@(x) isempty(x),rgb_grid_p{k});
end
missing_depth = cellfun(@(x) isempty(x),dfiles);

for i=find(missing_rgb & ~missing_depth)
  [points,disp]=get_depth_samples(dataset_path,dfiles{i},depth_plane_mask{i});
  [points,disp] = reduce_depth_samples(points,disp,max_depth_sample_count);

  fprintf('#%d ',i);
  [calib0.Rext{i},calib0.text{i}] = depth_extern_calib(calib0,points,disp);
end

%Initial minimization
fprintf('Optimizing depth camera parameters...\n');
fprintf('Stats with initial values:\n');
print_calib_stats(calib0);

fprintf('Obtaining samples...');
[depth_plane_points,depth_plane_disparity] = get_depth_samples(dataset_path,dfiles,depth_plane_mask);
[depth_plane_points,depth_plane_disparity] = reduce_depth_samples(depth_plane_points,depth_plane_disparity,max_depth_sample_count);
fprintf('done\n');

options = calibrate_kinect_options();
options.use_fixed_rK = true;
options.use_fixed_rkc = true;
options.use_fixed_dkc = true;
options.use_fixed_rRt = true;
options.use_fixed_dR = false;
options.use_fixed_dt = false;
options.use_fixed_pose = true;

calib0=calibrate_kinect(options,rgb_grid_p,rgb_grid_x,depth_plane_points,depth_plane_disparity,calib0);
fprintf('Stats after depth params optimization:\n');
print_calib_stats(calib0);
