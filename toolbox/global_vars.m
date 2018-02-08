%This file lists all the global variables used
%Run this file to link all variables to the current workspace and access
%the results.
%
% Kinect calibration toolbox by DHC
global dataset_path rfiles rsize dfiles
global rgb_grid_p rgb_grid_x
global depth_corner_p depth_corner_x
global depth_plane_poly depth_plane_mask
global calib0
global is_validation
global final_calib final_calib_error

%max_depth_sample_count: The maximum number of disparity samples used for
%   full calibration. Used to limit memory usage.
global max_depth_sample_count 
max_depth_sample_count = 60000;

if(isempty(calib0))
% Fields of calib0 and final_calib:
% 	rK {K}[fx 0 u0; 0 fy v0; 0 0 1] intrinsics for rgb camera K
% 	rkc {K}[1x5] distortion coefficients for rgb camera K
% 	rR {K}[3x3] rotation matrix from camera K to camera 1 (r1X = rR{k} * rkX + rt{k})
% 	rt {K}[3x1] translation vector from camera K to camera 1 (r1X = rR{k} *	rkX + rt{k})
% 	dK [fx 0 u0; 0 fy v0; 0 0 1] intrinsics for depth camera 
% 	dkc [1x5] distortion coefficients for depth camera
% 	dc [1x2] coefficients for disparity-depth function
%   dc_alpha [3x1] distortion decay coefficients for the disparity-depth function
%   dc_beta [480x640] distortion per-pixel coefficients for the disparity-depth function
% 	dR [3x3] relative rotation matrix (r1X = dR * dX + dt)
% 	dt [3x1] relative translation vector (r1X = dR * dX + dt)
% 	Rext {N}[3x3] cell array of rotation matrices grid to camera 1
%             one for each image (r1X = Rext * gridX + text)
% 	text {N}[3x1] cell array of translation vectors grid to camera 1
%             one for each image (r1X = Rext * gridX + text)
  calib0.rK = {};               %Color camera intrinsics matrix
  calib0.rkc = {};              %Color camera distortion coefficients
  calib0.rR = {};               %Rotation matrix depth camera to color camera (first is always identity)
  calib0.rt = {};               %Translation vector depth camera to color camera (first is always zero)
  calib0.color_error_var = [];  %Error variance for color camera corners

  calib0.dK = [];               %Depth camera intrinsics matrix
  calib0.dkc = [];              %Depth camera distortion coefficients
  calib0.dc = [];               %Depth camera depth2disparity coefficients
  calib0.dc_alpha = [];         %Depth camera depth2disparity coefficients
  calib0.dc_beta = [];          %Depth camera depth2disparity coefficients
  calib0.depth_error_var = [];  %Error variance for disparity
  calib0.dR = [];               %Rotation matrix depth camera to color camera
  calib0.dt = [];               %Translation vector depth camera to color camera
  calib0.Rext = [];             %Cell array of rotations world to color camera
  calib0.text = [];             %Cell array of translations world to color camera
end

if(isempty(is_validation))
  is_validation = false;
end