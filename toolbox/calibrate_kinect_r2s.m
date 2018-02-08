%[params]=calibrate_kinect_r2s(raw_params, options, params0)
% Converts a params array into a params struct. Used by calibrate_kinect()
% 
% Kinect calibration toolbox by DHC
function [params]=calibrate_kinect_r2s(raw_params, options, params0)

%Initializes default values and extra parameters
params = params0;

ccount = length(params0.rK);
image_count = length(params0.Rext);
base=1;

%Depth distortion parameters
for i=1:5
  if(~options.use_fixed_dkc(i))
    params.dkc(i) = raw_params(base);
    base = base+1;
  end
end

%Depth internal matrix
if(~options.use_fixed_dK)
  params.dK = [raw_params(base), 0, raw_params(base+2);
    0, raw_params(base+1), raw_params(base+3);
    0, 0, 1];
  base=base+4;
%   params.K = [raw_params(base), 0, raw_params(base+1);
%     0, raw_params(base), raw_params(base+2);
%     0, 0, 1];
%   base=base+3;
end

%Depth params
dc_length = length(options.use_fixed_dc);
for i=1:dc_length
  if(~options.use_fixed_dc(i))
    params.dc(i) = raw_params(base);
    base = base+1;
  end
end

%Depth distortion
if(~options.use_fixed_dc_alpha)
  params.dc_alpha = [raw_params(base),raw_params(base+1)];
  base = base+2;
end

%RGB distortion parameters
for k=1:ccount
  for i=1:5
    if(~options.use_fixed_rkc(i))
      params.rkc{k}(i) = raw_params(base);
      base = base+1;
    end
  end
end

%RGB internal matrix
if(~options.use_fixed_rK)
  for k=1:ccount
    params.rK{k} = [raw_params(base), 0, raw_params(base+2);
      0, raw_params(base+1), raw_params(base+3);
      0, 0, 1];
    base=base+4;
  end
end

%RGB undistort LUT
%Note: no need to compute it here, it is not used in the cost function
% height = 480;
% width = 640;
% [params.rlut_x,params.rlut_y] = undistort_lut([height,width],params.rK,params.rkc);

%External matrices
if(~options.use_fixed_dR)
  params.dR = rotationmat(raw_params(base : base+2));
  base = base+3;
end
if(~options.use_fixed_dt)
  params.dt = raw_params(base : base+2)';
  base = base+3;
end

if(~options.use_fixed_pose)
  params.Rext = cell(1,image_count);
  params.text = cell(1,image_count);
  for i=1:image_count
    if(~isempty(params0.Rext{i}))
      params.Rext{i} = rotationmat(raw_params(base:base+2));
      base = base+3;
      params.text{i} = raw_params(base:base+2)';
      base = base+3;
    end
  end
end

if(~options.use_fixed_rRt)
  params.rR = cell(1,ccount);
  params.rt = cell(1,ccount);
%   params.rR{1} = rotationmat(raw_params(base:base+2));
%   base = base+3;
  params.rR{1} = eye(3);
  params.rt{1} = zeros(3,1);
  for k=2:ccount
    params.rR{k} = rotationmat(raw_params(base:base+2));
    base = base+3;
    params.rt{k} = raw_params(base:base+2)';
    base = base+3;
  end
end