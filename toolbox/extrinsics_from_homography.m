%Computes extrinsic parameters using a homography and the intrinsic params
%Implemented directly from Zhang's '99 paper
% "Flexible Camera Calibration By Viewing a Plane From Unknown
% Orientations"
%
% H is a 3x3 homography
% K is the [3x3] intrinsics matrix
% R is a 3x3 rotation
% t is a 3x1 translation
%
% Kinect calibration toolbox by DHC
function [R,t]=extrinsics_from_homography(K,H)
  R0 = zeros(3,3);

  R0(:,1) = K\H(:,1);
  R0(:,2) = K\H(:,2);
  lambda = 1/norm(R0(:,1));
  R0(:,1:2) = lambda*R0(:,1:2);
  R0(:,3) = cross(R0(:,1),R0(:,2));
  [U,~,V] = svd(R0);
  R = U*V';
  t = lambda*(K\H(:,3));
  
  if(t(3) < 0)
    R(:,1:2) = -R(:,1:2);
    t = -t;
  end
