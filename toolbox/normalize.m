%This function adapted from Bouguet's camera calibration toolbox.
function [xn] = normalize(x_kk,K,kc)
%
%normalize
%
%[xn] = normalize(x_kk,fc,cc,kc,alpha_c)
%
%Computes the normalized coordinates xn given the pixel coordinates x_kk
%and the intrinsic camera parameters fc, cc and kc.
%
%INPUT: x_kk: Feature locations on the images
%       fc: Camera focal length
%       cc: Principal point coordinates
%       kc: Distortion coefficients
%       alpha_c: Skew coefficient
%
%OUTPUT: xn: Normalized feature locations on the image plane (a 2XN matrix)
%
%Important functions called within that program:
%
%undistort: undistort pixel coordinates.

%Check K matrix
if(any([K(1,2) K(2,1) K(3,1) K(3,2) K(3,3)-1]))
  error('normalize:inputs','Matrix K has more non-zero elements than expected.');
end

% First: Subtract principal point, and divide by the focal length:
cc = [K(1,3) K(2,3)];
fc = [K(1,1) K(2,2)];
x_distort = [(x_kk(1,:) - cc(1))/fc(1);(x_kk(2,:) - cc(2))/fc(2)];

% Second: undo skew
% x_distort(1,:) = x_distort(1,:) - alpha_c * x_distort(2,:);

xn = undistort(x_distort,kc);
