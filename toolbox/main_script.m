clc;
close all;
clear variables; %clear classes;
rand('state',0); % rand('state',sum(100*clock));
dbstop if error;

addpath('autoCornerFinder');


%% input for calibration

% select RGB and depth images
do_select_images();

% Example:
% Path: ../dataset_xw1120/
% Num: 1
% RGB format: %.4d-c1.jpg
% Depth format: %.4d-d.pgm
% Select: [1:20] (or just enter)


% select corner points in checkerboard in RGB images
do_select_rgb_corners();
do_plot_rgb_corners();

% Example:
% Square size: 0.04
% Automatic: just enter
% Corner in X: 10
% Corner in Y: 7
% Window size: 3


% select planes in disparity images
do_select_planes();
do_plot_depth_plane();


%% initial calibration

% RGB calibration
do_initial_rgb_calib();


% depth calibration
do_initial_depth_calib(true);
global calib0
print_calib_depth(calib0);


%% final calibration

% RGB and depth calibration
use_depth_distorsion = true;
do_calib(use_depth_distorsion);


%% visualization

% overlay depth image over RGB image
do_rgb_depthmap();

% Example:
% depth image: ../dataset_xw1120/0003-d.pgm
% RGB image: ../dataset_xw1120/0003-c1.jpg





do_useful_fcn();
do_save_calib();
do_load_calib();





