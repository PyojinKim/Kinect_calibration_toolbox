%raw_params = calibrate_kinect_s2r(params, options)
% Converts a params struct into a params array. Used by calibrate_kinect()
%
%Inputs:
% Fields of params:
% 	rK {K}[fx 0 u0; 0 fy v0; 0 0 1] intrinsics for rgb camera 
% 	rkc {K}[1x5] distortion coefficients for rgb camera
% 	rR {K}[3x3] rotation matrix from camera k to camera 1 (r1X = rR{k} * rkX + rt{k})
% 	rt {K}[3x1] translation vector from camera k to camera 1 (r1X = rR{k} *	rkX + rt{k})
% 	dK [fx 0 u0; 0 fy v0; 0 0 1] intrinsics for depth camera 
% 	dkc [1x5] distortion coefficients for depth camera
% 	dc [1x2] coefficients for disparity-depth function
% 	dR [3x3] relative rotation matrix (r1X = dR * dX + dt)
% 	dt [3x1] relative translation vector (r1X = dR * dX + dt)
% 	Rext {N}[3x3] cell array of rotation matrices grid to camera 1
%             one for each image (r1X = Rext * gridX + text)
% 	text {N}[3x1] cell array of translation vectors grid to camera 1
%             one for each image (r1X = Rext * gridX + text)
% 
% Kinect calibration toolbox by DHC
function raw_params = calibrate_kinect_s2r(params, options)

ccount = length(params.rK);
image_count = length(params.Rext);
raw_params = [];
base = 1;

%Depth distortion parameters
for i=1:5
  if(~options.use_fixed_dkc(i))
    raw_params(base) = params.dkc(i);
    base = base+1;
  end
end

%Depth internal matrix
if(~options.use_fixed_dK)
  raw_params(base:base+3) = [params.dK(1,1) params.dK(2,2) params.dK(1,3) params.dK(2,3)];
  base = base+4;
%   raw_params(base:base+2) = [params.K(1,1) params.K(1,3) params.K(2,3)];
%   base = base+3;
end

%Depth
dc_length = length(options.use_fixed_dc);
for i=1:dc_length
  if(~options.use_fixed_dc(i))
    raw_params(base) = params.dc(i);
    base = base+1;
  end
end

%Depth distortion
if(~options.use_fixed_dc_alpha)
  raw_params(base:base+1) = params.dc_alpha(1:2);
  base = base+2;
end

%RGB distortion parameters
for k=1:ccount
  for i=1:5
    if(~options.use_fixed_rkc(i))
      raw_params(base) = params.rkc{k}(i);
      base = base+1;
    end
  end
end

%RGB internal matrix
if(~options.use_fixed_rK)
  for k=1:ccount
    raw_params(base:base+3) = [params.rK{k}(1,1) params.rK{k}(2,2) params.rK{k}(1,3) params.rK{k}(2,3)];
    base = base+4;
  end
end

%Relative pose matrices
if(~options.use_fixed_dR)
  raw_params(base:base+2) = rotationpars(params.dR);
  base = base+3;
end
if(~options.use_fixed_dt)
  raw_params(base:base+2) = params.dt;
  base = base+3;
end

%External pose matrices
if(~options.use_fixed_pose)
  for i=1:image_count
    if(~isempty(params.Rext{i}))
      raw_params(base:base+2) = rotationpars(params.Rext{i});
      base = base+3;
      
      raw_params(base:base+2) = params.text{i};
      base = base+3;
    end
  end
end

%Relative pose matrices
if(~options.use_fixed_rRt)
%   raw_params(base:base+2) = rotationpars(params.rR{1});
%   base = base+3;
  for k=2:ccount
    raw_params(base:base+2) = rotationpars(params.rR{k});
    base = base+3;
    raw_params(base:base+2) = params.rt{k};
    base = base+3;
  end
end

