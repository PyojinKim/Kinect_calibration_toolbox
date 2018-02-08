function [dK,dR,dt,R0,t0]=estimate_depth_calib_from_corners(depth_corner_x,depth_corner_p, Rext, text)
  %Get files with plane corner info
  valid = cellfun(@(x) ~isempty(x),depth_corner_p);
  valid_idx = find(valid);
  dcount = sum(valid);

  %Extract plane parameters from RGB
  rplaneN = zeros(3,dcount);
  rplaned = zeros(1,dcount);
  for i=1:length(valid_idx)
    [rplaneN(:,i), rplaned(i)] = extrinsic2plane(Rext{valid_idx(i)},text{valid_idx(i)});
  end

  %Compute homographies for depth images
  corners = depth_corner_p(valid);

  dH = cell(1,dcount);
  for i=1:dcount
    dH{i} = homography_from_corners(corners{i},depth_corner_x);
  end

  %Closed form calibration using homographies
  [dK,R0,t0]=calib_from_homographies(dH);
  if(any(imag(dK(:))))
    error('kinect_toolbox:estimate_depth_calib_from_corners','Calibration using depth corners failed catastrophically, the intrinsics matrix is imaginary!!! Re-select the corners or use well-known initial values.');
  end

  %Extract plane parameters from extrinsics
  dplaneN = zeros(3,dcount);
  dplaned = zeros(1,dcount);
  for i=1:dcount
    [dplaneN(:,i),dplaned(i)] = extrinsic2plane(R0{i},t0{i});
    %Fix sign
    dplaned(i) = sign(rplaned(i)).*sign(dplaned(i)).*dplaned(i); 
  end

  %Calculate relative transformation
  dt = (rplaneN*rplaneN') \ (rplaneN*(rplaned-dplaned)');
  [u,~,v] = svd(dplaneN*rplaneN');
  dR = v*u';

  %Fix sign
  if(det(dR)<0)
    dR = -dR;
  end
end