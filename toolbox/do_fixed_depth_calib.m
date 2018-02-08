%do_fixed_depth_calib()
% UI function
% Kinect calibration toolbox by DHC
function do_fixed_depth_calib()

%Outputs
global calib0

fprintf('-------------------\n');
fprintf('Using known values for initial depth camera calibration\n');
fprintf('-------------------\n');

calib0.dK = [  590 0  320;
         0  590 230;
         0  0    1];
calib0.dkc = [0 0 0 0 0];
calib0.depth_error_var = 3^2; %0.2324;
calib0.dR = eye(3);
calib0.dt = [-0.025 0 0]';
calib0.dc = [ -0.0028525         1091];
calib0.dc_alpha = [1,1];
calib0.dc_beta = zeros(480,640);