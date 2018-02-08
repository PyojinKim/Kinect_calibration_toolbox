calib_path = 'C:\datasets\kinect_toolbox\calibB1\';
validate_path = 'C:\datasets\kinect_toolbox\validateB1\';
validate_file = 'validate_B1';

do_load_calib([calib_path 'best_calib.mat']);
global_vars;

%%
calib0=[];
final_calib = [];
k=1;
rsize = rsize(k);
rfiles=rfiles(k);
rgb_grid_p=rgb_grid_p(k);
rgb_grid_x=rgb_grid_x(k);

%%
do_initial_rgb_calib();
do_initial_depth_calib(true);
do_calib(true);
do_save_calib([calib_path 'no_external.mat']);

%%
calib_file = [calib_path 'no_external.mat'];
do_load_calib([validate_path validate_file]);

%%
calib0=[];
final_calib = [];
k=1;
rsize = rsize(k);
rfiles=rfiles(k);
rgb_grid_p=rgb_grid_p(k);
rgb_grid_x=rgb_grid_x(k);

%%
do_validate(calib_file);
