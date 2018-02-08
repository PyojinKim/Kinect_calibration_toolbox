%[params_error]=calibrate_kinect_cov2error(raw_params_error, options, params)
% Converts a params covariance array into an param error struct.
%
% Kinect calibration toolbox by DHC
function [params_error]=calibrate_kinect_cov2error(raw_params_error, options, params)

ccount = length(params.rR);
image_count = length(params.Rext);

error_list = 3*diag(raw_params_error).^0.5;
base=1;

%Depth distortion parameters
if(length(options.use_fixed_dkc) == 1)
  options.use_fixed_dkc = repmat(options.use_fixed_dkc,1,5);
end
params_error.dkc = zeros(1,5);
for i=1:5
  if(~options.use_fixed_dkc(i))
    params_error.dkc(i) = error_list(base);
    base = base+1;
  end
end

%Depth internal matrix
params_error.dK = zeros(3,3);
if(~options.use_fixed_dK)
  params_error.dK = [error_list(base), 0, error_list(base+2);
    0, error_list(base+1), error_list(base+3);
    0, 0, 1];
  base=base+4;
end

%Depth
dc_length = length(params.dc);
if(length(options.use_fixed_dc) == 1)
  options.use_fixed_dc = repmat(options.use_fixed_dc,1,dc_length);
end
params_error.dc = zeros(1,dc_length);
for i=1:dc_length
  if(~options.use_fixed_dc(i))
    params_error.dc(i) = error_list(base);
    base = base+1;
  end
end

%Depth distortion
params_error.dc_alpha = zeros(1,2);
if(~options.use_fixed_dc_alpha)
  params_error.dc_alpha = [error_list(base),error_list(base+1)];
  base = base+2;
end

params_error.rkc = cell(1,ccount);
params_error.rK = cell(1,ccount);
params_error.dR = zeros(1,3);
params_error.dt = zeros(1,3);
params_error.Rext = cell(1,image_count);
params_error.text = cell(1,image_count);
params_error.rR = cell(1,ccount);
params_error.rt = cell(1,ccount);
for k=1:ccount
  params_error.rK{k} = zeros(3,3);
  params_error.rkc{k} = zeros(1,5);
  params_error.Rext{k} = zeros(3,1);
  params_error.text{k} = zeros(3,1);
  params_error.rR{k} = zeros(3,1);
  params_error.rt{k} = zeros(3,1);
end

%RGB distortion parameters
if(length(options.use_fixed_rkc) == 1)
  options.use_fixed_rkc = repmat(options.use_fixed_rkc,1,5);
end
for k=1:ccount
  for i=1:5
    if(~options.use_fixed_rkc(i))
      params_error.rkc{k}(i) = error_list(base);
      base = base+1;
    end
  end
end

%Internal matrix
if(~options.use_fixed_rK)
  for k=1:ccount
    params_error.rK{k} = [error_list(base), 0, error_list(base+2);
      0, error_list(base+1), error_list(base+3);
      0, 0, 1];
    base=base+4;
  end
end

%External matrices
if(~options.use_fixed_dR)
  params_error.dR = error_list(base : base+2);
  base = base+3;
end
if(~options.use_fixed_dt)
  params_error.dt = error_list(base : base+2)';
  base = base+3;
end

if(~options.use_fixed_pose)
  for i=1:image_count
    if(~isempty(params.Rext{i}))
      params_error.Rext{i} = error_list(base:base+2);
      base = base+3;
      params_error.text{i} = error_list(base:base+2)';
      base = base+3;
    end
  end
end
if(~options.use_fixed_rRt)
%   params_error.rR{1} = error_list(base:base+2);
%   base = base+3;
  for k=2:ccount
    params_error.rR{k} = error_list(base:base+2);
    base = base+3;
    params_error.rt{k} = error_list(base:base+2)';
    base = base+3;
  end
end