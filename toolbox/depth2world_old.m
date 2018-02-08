function [Xw,idx]=depth2world(u,v,depth,depth_calib)

%Assume full image if u or v are missing
if(isempty(u) || isempty(v))
  [u,v] = meshgrid(0:size(depth,2)-1,0:size(depth,1)-1);
end

%Filter out invalid disparities
valid = ~isnan(depth) | isnan(depth);
u = u(valid)';
v = v(valid)';
depth = depth(valid)';

count = length(depth);

%Remember indices
idx0 = zeros(size(depth));
idx0(1:numel(idx0)) = 1:numel(idx0);
idx = idx0(valid)';

%Ray direction
height = size(depth_calib.dlut_x,1);
width = size(depth_calib.dlut_x,2);
ind = sub2ind([height,width],v+1,u+1);
Xn = [depth_calib.dlut_x(ind); depth_calib.dlut_y(ind); ones(1,count)];

%In case of no distortion
% [uu,vv] = meshgrid(0:width-1, 0:height-1);
% u = uu(valid)';
% v = vv(valid)';
%   p = repmat(w,3,1).*[u; v; ones(1,length(u))];
%   x = (K \ p); %K has a simple form, no need to invert the matrix, simply
%                %divide by focal length and substract principal point.

%Final point
Xd = repmat(depth,3,1) .* Xn;
Xw = depth_calib.dR*Xd + repmat(depth_calib.dt,1,count);
