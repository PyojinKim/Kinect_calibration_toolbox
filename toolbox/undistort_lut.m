%[lut_x,lut_y]=undistort_lut(image_size,K,kc)
% Creates a look up table to go from pixel coordinates to normalized world
% coordinates.
%
% image_size [1x2] [height,width]
% K [3x3] intrinsics matrix
% kc [1x5] distortion coefficients
% lut_x [height x width]
% lut_y [height x width]
%       Xn = [lut_x(v,u) lut_y(v,u)]'
%
% Kinect calibration toolbox by DHC
function [lut_x,lut_y]=undistort_lut(image_size,K,kc)

[uu,vv] = meshgrid(0:image_size(2)-1, 0:image_size(1)-1);
p = [uu(:)'; vv(:)'];

if(~any(kc))
  %uv_n = K \ [p; ones(1,size(p,2))];
  uv_n = [(p(1,:)-K(1,3)) / K(1,1); (p(2,:)-K(2,3)) / K(2,2)];
else
  [uv_n] = normalize(p,K,kc);
end

lut_x = reshape(uv_n(1,:), image_size(1), image_size(2));
lut_y = reshape(uv_n(2,:), image_size(1), image_size(2));