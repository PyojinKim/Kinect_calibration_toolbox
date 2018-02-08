%[depthmap,points]=compute_rgb_depthmap(imd,calib,im_size,splat_size)
% Back projects the disparity image to metric coordinates and projects it
% onto the rgb image to compute a depth map with rgb camera pixel
% coordinates.
%
% imd [HxW] kinect disparity image
% calib [struct] calibration data from the toolbox
% im_size [2] size of the resulting depthmap (default is [480,640]).
% splat_size [1] size of the splat kernel for each warped depth point
%   (must be odd, default 1)
%
% depthmap [im_size] depth map for the rgb image
% depthmap [im_size(1)xim_size(2)x3] point map (one 3D point per pixel) for
% the rgb image
%
% Kinect calibration toolbox by DHC
function [depthmap,points]=compute_rgb_depthmap(imd,calib,im_size,splat_size)

if(nargin < 3)
  width = 640;
  height = 480;
else
  width = im_size(2);
  height = im_size(1);
end

if(nargin < 4)
  splat_size = 1;
end
splat_width = (splat_size-1)/2;

x=disparity2world([],[], imd, calib);
p=project_points_k(x,calib.rK{1},calib.rkc{1});

p = round(p);
depthmap = nan(height,width);
if(nargout>1)
  points = nan([height,width,3]);
end
for i=1:size(p,2)
  if(isnan(p(1,i)) || p(1,i) < 1 || p(1,i) > size(depthmap,2) || p(2,i) < 1 || p(2,i) > size(depthmap,1))
    continue;
  end
  if(isnan(depthmap(p(2,i), p(1,i))) || depthmap(p(2,i), p(1,i)) > x(3,i))
%     depthmap(p(2,i), p(1,i)) = x(3,i);
    minx = max([p(1,i)-splat_width, 1]);
    maxx = min([p(1,i)+splat_width, size(depthmap,2)]);
    miny = max([p(2,i)-splat_width, 1]);
    maxy = min([p(2,i)+splat_width, size(depthmap,1)]);
    
    depthmap(miny:maxy, minx:maxx) = x(3,i);
    if(nargout>1)
      points(miny:maxy, minx:maxx, 1) = x(1,i);
      points(miny:maxy, minx:maxx, 2) = x(2,i);
      points(miny:maxy, minx:maxx, 3) = x(3,i);
    end
  end
end
