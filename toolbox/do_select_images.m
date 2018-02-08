%do_select_images()
% UI function.
% Kinect calibration toolbox by DHC
function do_select_images()

%Clear globals
clear global dataset_path rfiles rsize dfiles
clear global rgb_grid_p rgb_grid_x
clear global depth_corner_p depth_corner_x
clear global depth_plane_poly depth_plane_mask
clear global calib0
clear global is_validation
clear global final_calib final_calib_error
global_vars(); %Initialize them again

global dataset_path rfiles rsize dfiles

fprintf('-------------------\n');
fprintf('Selecting images\n');
fprintf('-------------------\n');

s = sprintf('Path to image directory ([]=current dir):');
dataset_path = input(s,'s');
if(~isempty(dataset_path) && dataset_path(end) ~= '\' || dataset_path(end) ~= '/')
  dataset_path = [dataset_path '/'];
end

ccount = input('Number of color cameras ([]=1):');
if(isempty(ccount))
  ccount = 1;
end

rfile_format = cell(1,ccount);
for k=1:ccount
  default = sprintf('%%.4d-c%d.jpg',k);
  s = sprintf('Filename format for camera %d images ([]=''%s''):',k,default);
  rfile_format{k} = input(s,'s');
  if(isempty(rfile_format{k}))
    rfile_format{k} = default;
  end
end

default = sprintf('%%.4d-d.pgm');
s = sprintf('Filename format for depth images ([]=''%s''):',default);
dfile_format = input(s,'s');
if(isempty(dfile_format))
  dfile_format = default;
end

[rfiles,rsize,dfiles] = find_images(dataset_path,rfile_format,dfile_format);
icount = length(dfiles);

fprintf('%d plane poses found.\n',icount);
if(icount == 0)
  return;
end

%Show thumbnails
plot_all_images(dataset_path,rfiles,dfiles);

%Ask user
calib_idx=input('Select poses to use for calibration ([]=all):');
if(isempty(calib_idx))
  calib_idx = 1:icount;
end
for k=1:ccount
  rfiles{k} = rfiles{k}(calib_idx);
end
dfiles = dfiles(calib_idx);
