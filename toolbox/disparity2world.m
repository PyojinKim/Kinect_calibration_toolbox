%[Xw,idx]=disparity2world(u,v,disparity,calib)
% Converts a series of points in a depth image to points in world
% coordinate system.
% 
% u [1xP] uv coordinates in the depth image
% v [1xP] uv coordinates in the depth image
% disparity [1xP] disparity values
% calib [struct] calibration values. 
%
% Xw [3xP] points in world coordinate system (same as color camera because
%     Rext and text are assumed to be eye(3) and zero).
%
% Kinect calibration toolbox by DHC
function [Xw,idx]=disparity2world(u,v,disparity,calib)

%Assume full image if u or v are missing
if(isempty(u) || isempty(v))
  [u,v] = meshgrid(0:size(disparity,2)-1,0:size(disparity,1)-1);
end

%Filter out invalid disparities
valid = ~isnan(disparity) | isnan(disparity);

if(nargout > 1)
  %Remember indices
  pcount = numel(disparity);
  idx0 = zeros(1,pcount);
  idx0(1:pcount) = 1:pcount;
  idx = idx0(valid);
end

u = u(valid);
v = v(valid);
disparity = disparity(valid);

%Reshape
pcount = numel(disparity);
u = reshape(u,[1, pcount]);
v = reshape(v,[1, pcount]);
disparity = reshape(disparity,[1, pcount]);

%Depth
w = disparity2depth(u,v,disparity,calib);

%Ray direction
Xn = get_dpoint_direction(u,v,calib);

%Final point
Xd = [bsxfun(@times, Xn, w); w];
Xw = bsxfun(@plus, calib.dR*Xd, calib.dt);
