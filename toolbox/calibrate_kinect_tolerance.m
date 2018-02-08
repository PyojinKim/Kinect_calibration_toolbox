function calib_errors=calibrate_kinect_tolerance(options,calib,calib_jacobian,color_error,depth_error)

%Covariance
%   color_var = 0.0681;
%   depth_var = 2.5635;
%   inv_cost_cov = diag(1./[color_var*ones(1,color_sample_count), depth_var*ones(1,depth_sample_count)]);
%   raw_param_cov = inv(J'*inv_cost_cov*J);
inv_cost_cov = [];
if(~isempty(color_error))
  for k=1:length(color_error)
    inv_cost_cov = [inv_cost_cov; calib.color_error_var(k)^-0.5*ones(length(color_error{k}),1)];
  end
end
if(~isempty(color_error))
  inv_cost_cov = [inv_cost_cov; calib.depth_error_var^-0.5*ones(length(depth_error),1)];
end
Jp = repmat(inv_cost_cov,1,size(calib_jacobian,2)).*calib_jacobian;
raw_param_cov = inv(Jp'*Jp);

calib_errors = calibrate_kinect_cov2error(raw_param_cov,options,calib);