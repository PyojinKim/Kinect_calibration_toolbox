%[R,t]=plane2extrinsics(N,d)
% Extracts the extrinsics (rotation and translation) from the 
% calibration plane parameters (normal and distance from origin).
% Only the third column of the rotation and one entry of the translation
% are constrained by the plane parameters. The other values are arbitrary.
%
% Kinect calibration toolbox by DHC
function [R,t]=plane2extrinsics(N,d)
  R = zeros(3);
  R(:,3) = N;
  
  [~,i]=sort(N,'descend');
  v = zeros(3,1);
  v(i(3)) = N(i(2)) / (N(i(2))^2 + N(i(3))^2)^0.5;
  v(i(2)) = (1-v(i(3))^2)^0.5;
  if(abs(dot(v,N)) > 1e-8)
    v(i(3)) = -v(i(3));
    if(abs(dot(v,N)) > 1e-8)
      v(i(3)) = -v(i(3));
      v(i(2)) = -v(i(2));
      if(abs(dot(v,N)) > 1e-8)
        error('plane2extrinsics:panic','Algorithm is wrong, vectors are not orthogonal');
      end
    end
  end
  R(:,2) = v';

  R(:,1) = cross(R(:,2),R(:,3));

  t = zeros(3,1);
  t(i(1)) = d/N(i(1));
