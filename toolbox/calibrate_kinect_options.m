% options=calibrate_kinect_options()
% Creates the options struct for calibrate_kinect().
% Set the different use_fixed_* fields to control the degrees of freedom in
% the minimization.
% 
% Kinect calibration toolbox by DHC
function options=calibrate_kinect_options()

options.use_fixed_dK = false;
options.use_fixed_dkc = [false,false,false,false,true];
options.use_fixed_dc = false;

options.use_fixed_rRt = false;
options.use_fixed_pose = false;

options.use_fixed_rK = false;
options.use_fixed_rkc = [false,false,false,false,true];
options.use_fixed_dR = false;
options.use_fixed_dt = false;
options.use_fixed_dc_alpha = false;

%Same as optimset
% options.display = 'iter'; %Show info on each iteration
options.display = 'none'; %No info