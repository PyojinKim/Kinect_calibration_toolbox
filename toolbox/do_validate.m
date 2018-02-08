%do_validate()
% UI function.
% Kinect calibration toolbox by DHC
function do_validate(calib)

%Inputs
global dataset_path dfiles
global rgb_grid_p rgb_grid_x
global depth_plane_mask
%Outputs
global is_validation
global final_calib final_calib_error;

%Check previous steps
if(isempty(rgb_grid_p))
  do_select_rgb_corners();
end
if(isempty(depth_plane_mask))
  do_select_planes();
end

icount = length(dfiles);
ccount = length(rgb_grid_p);
width = 640;
height = 480;

%Load calibration file
if(nargin < 1)
  calib = [];
end
if(isempty(calib))
  calib=input('Enter path to calibration data ([]=depth_results.mat):','s');
  if(isempty(calib))
    calib = 'depth_results.mat';
  end
end
if(ischar(calib))
  data = load(calib);
  calib = data.final_calib;
end

final_calib = calib;
final_calib.color_error_var = [ 0.18     0.30].^2;
final_calib.depth_error_var = 0.9^2;

% Refine external parameters
options = calibrate_kinect_options();
options.use_fixed_rK = true;
options.use_fixed_rkc = true;
options.use_fixed_dK = true;
options.use_fixed_dkc = true;
options.use_fixed_dc = true;
options.use_fixed_dR = true;
options.use_fixed_dt = true;
options.use_fixed_rRt = true;
options.use_fixed_pose = false;
options.display = 'none';

params0 = final_calib;
final_calib.Rext = cell(1,icount);
final_calib.text = cell(1,icount);
for i=1:icount
  %Placeholder values
  final_calib.Rext{i} = eye(3);
  final_calib.text{i} = zeros(3,1);
end

fprintf('Refining positions...');

[uu,vv] = meshgrid(0:width-1,0:height-1);
for i=1:icount
  fprintf('Image #%d...\n',i);
  
  %Extract relevant data
  rgb_grid_p_i = cell(1,ccount);
  rgb_grid_x_i = cell(1,ccount);
  for k=1:ccount
    rgb_grid_p_i{k} = rgb_grid_p{k}(i);
    rgb_grid_x_i{k} = rgb_grid_x{k}(i);
  end

  %Use all points from depth image
  [points,disparity] = get_depth_samples(dataset_path,dfiles{i},depth_plane_mask{i});

  %Initial extrinsics from first available rgb camera
  k = find(cellfun(@(x) ~isempty(x{i}), rgb_grid_p),1,'first');
  if(isempty(k))
      [final_calib.Rext{i},final_calib.text{i}] = depth_extern_calib(final_calib,points,disparity);
  else
    %Closed form extrinsics
    H = homography_from_corners(rgb_grid_p{k}{i},rgb_grid_x{k}{i});
    [R0,t0] = extrinsics_from_homography(final_calib.rK{k},H);

    Rext0 = final_calib.rR{k}*R0;
    text0 = final_calib.rR{k}*t0 + final_calib.rt{k};

    %Refine
    params0.Rext = {Rext0};
    params0.text = {text0};
    [params]=calibrate_kinect(options,rgb_grid_p_i,rgb_grid_x_i,{points},{disparity},params0);
    final_calib.Rext{i} = params.Rext{1};
    final_calib.text{i} = params.text{1};
  end
  
  %Report
  [~,im_mean,im_std]=get_rgb_errors(final_calib,rgb_grid_p_i,rgb_grid_x_i,final_calib.Rext(i),final_calib.text(i));
  for k=1:length(im_mean)
    fprintf('Color %d: mean=%f, std=%f (pixels)\n',k,im_mean(k),im_std(k));
  end
  a = get_depth_error(final_calib,points,disparity,final_calib.Rext{i},final_calib.text{i});
  fprintf('Depth  : mean=%f, std=%f (disparity)\n',nanmean(a(:)),nanstd(a(:)));
end
fprintf('done.\n');

%%
% Validate
fprintf('Validation stats\n');
% plane_error = depth_plane_error(final_calib,depth_plane_points,depth_plane_disparity);
% color_error = calibrate_kinect_cost_color(final_calib,options,rgb_grid_p,rgb_grid_x);
% depth_error = calibrate_kinect_cost_depth(final_calib,options,depth_plane_points,depth_plane_disparity);
% fprintf('Distance from plane: mean=%fmm, std dev=%fmm\n',mean(1000*plane_error),std(1000*plane_error));
% fprintf('Error std dev: color=%fpx, depth=%f\n',std(color_error),std(depth_error));
print_calib_stats(final_calib);
is_validation = true;
