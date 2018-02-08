%do_load_calib()
% UI function. Loads calibration data from disk.
% Kinect calibration toolbox by DHC
function do_load_calib(path)

global dataset_path rfiles rsize dfiles
global rgb_grid_p rgb_grid_x
global depth_corner_p depth_corner_x
global depth_plane_poly depth_plane_mask
global calib0
global is_validation
global final_calib final_calib_error

%Filename
if(nargin < 1 || isempty(path))
  path = input('Calibration path or filename:','s');
end
[path_dir,path_name,~] = fileparts(path);
if(~exist(path_dir,'dir'))
  mkdir(path_dir);
end
if(isempty(path_name))
  path_name='depth_results';
  %validation_path_name='validation_results.mat'; 
  %Validation must be loaded manually
end

filename = [path_dir filesep() path_name '.mat'];

%Data
fprintf('Loading from: %s\n', filename);
depth_calib = load(filename);

dataset_path = depth_calib.dataset_path;
rfiles = depth_calib.rfiles;
rsize = depth_calib.rsize;
dfiles = depth_calib.dfiles;
rgb_grid_p = depth_calib.rgb_grid_p;
rgb_grid_x = depth_calib.rgb_grid_x;
depth_corner_p = depth_calib.depth_corner_p;
depth_corner_x = depth_calib.depth_corner_x;
depth_plane_poly = depth_calib.depth_plane_poly;
depth_plane_mask = depth_calib.depth_plane_mask;
calib0 = depth_calib.calib0;
is_validation = depth_calib.is_validation;
final_calib = depth_calib.final_calib;
final_calib_error = depth_calib.final_calib_error;