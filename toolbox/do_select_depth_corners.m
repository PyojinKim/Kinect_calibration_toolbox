%do_select_depth_corners()
% UI function.
% Kinect calibration toolbox by DHC
function do_select_depth_corners()

%Input
global dataset_path dfiles
%Output
global depth_corner_p depth_corner_x

%Check previous steps
if(isempty(dfiles))
  do_select_images();
end
icount = length(dfiles);

fprintf('-------------------\n');
fprintf('Selecting depth corners\n');
fprintf('-------------------\n');

%Select images
if(isempty(depth_corner_p))
  depth_corner_p = cell(1,length(dfiles));
  fidx = 1:length(dfiles);
else
  %Check for too small or too big array
  if(length(depth_corner_p) < icount)
    depth_corner_p{icount} = [];
  elseif(length(depth_corner_p) > icount)
    depth_corner_p = depth_corner_p(1:icount);
  end
  
  missing = cellfun(@(x) isempty(x),depth_corner_p);
  if(all(missing))
    default = 1:length(dfiles);
    fidx = input('Select images to process ([]=all): ');
  else
    default = find(missing);
    fidx = input(['Select images to process ([]=[' num2str(default) ']): ']);
  end
  if(isempty(fidx))
    fidx = default;
  end
end

%Select plane dimensions
default = 0.75;
dx = input(['Plane size in X ([]=' num2str(default) 'm): ']);
if(isempty(dx))
  dx = default;
end

default = 1.2;
dy = input(['Plane size in Y ([]=' num2str(default) 'm): ']);
if(isempty(dy))
  dy = default;
end

depth_corner_x = [0,0;dx,0;dx,dy;0,dy]';

%Extract corners for all images
fprintf('LMB=select corner, RMB or Esc=skip image\n');
for i=fidx
  if(isempty(dfiles{i}))
    continue
  end
  fprintf('#%d ',i);

  imd = read_disparity([dataset_path dfiles{i}]);
  
  depth_corner_p{i} = select_plane_corners(imd);
end
fprintf('done.\n');