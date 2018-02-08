%%
% Init
global_vars();

dataset_path = 'C:\datasets\kinect_toolbox\calibA1\';

%%
r1_format = '%.4d-c1.pgm';
r2_format = '%.4d-c2.jpg';
d_format = '%.4d-d.pgm';

rfiles = cell(1,2);
rfiles{1} = {};
rfiles{2} = {};
dfiles = {};
i=0;
found = true;
while(found)
  found = false;
  
  filename = sprintf(r1_format,i);
  if(exist([dataset_path filename],'file'))
    rfiles{1}{i+1} = filename;
    found=true;
  else
    rfiles{1}{i+1} = [];
  end
  
  filename = sprintf(r2_format,i);
  if(exist([dataset_path filename],'file'))
    rfiles{2}{i+1} = filename;
    found=true;
  else
    rfiles{2}{i+1} = [];
  end

  filename = sprintf(d_format,i);
  if(exist([dataset_path filename],'file'))
    dfiles{i+1} = filename;
    found=true;
  else
    dfiles{i+1} = [];
  end
  i=i+1;
end
rfiles{1} = rfiles{1}(1:end-1);
rfiles{2} = rfiles{2}(1:end-1);
dfiles = dfiles(1:end-1);

ccount = length(rfiles);
icount = length(dfiles);

%%
do_select_rgb_corners();

%%
%Select plane
do_select_planes();

%%
do_select_depth_corners();

%%
do_save_calib(base_path);

%%
do_initial_rgb_calib();

%%
do_initial_depth_calib();
print_calib_depth(calib0);

%%

%%
for i=1:length(dfiles)
  if(ismember(i,valid)), continue; end
  for k=1:length(rfiles)
    rfiles{k}{i}=[];
  end
  dfiles{i}=[];
  rgb_grid_p{1}{i}=[];
  rgb_grid_p{2}{i}=[];
  rgb_grid_x{1}{i}=[];
  rgb_grid_x{2}{i}=[];
  depth_plane_mask{i}=[];
  depth_plane_poly{i}=[];
  calib0.Rext{i} = [];
  calib0.text{i} = [];
end

%%
range = 1:26;
invalid=[1,8,18,23,26];
valid = range(~ismember(range,invalid));
for k=1:length(rfiles)
  rfiles{k} = rfiles{k}(valid);
  rgb_grid_p{k}=rgb_grid_p{k}(valid);
  rgb_grid_x{k}=rgb_grid_x{k}(valid);
end
dfiles = dfiles(valid);
depth_plane_mask=depth_plane_mask(valid);
depth_plane_poly=depth_plane_poly(valid);
calib0.Rext = calib0.Rext(valid);
calib0.text = calib0.text(valid);

%%
rfiles = rfiles(1);
rgb_grid_p = rgb_grid_p(1);
rgb_grid_x = rgb_grid_x(1);

%%
do_calib

%%
[final_calib.dc_alpha,final_calib.dc_beta]=calib_distortion(final_calib,final_calib.Rext, final_calib.text, dfiles, depth_plane_mask);
print_calib_stats(final_calib);
calib0 = final_calib;

%%
old_depth_std = std( get_depth_error_all(final_calib,dfiles,depth_plane_mask) );
converged=false;
while(~converged)
  do_calib
  
  [final_calib.dc_alpha,final_calib.dc_beta]=calib_distortion(final_calib,final_calib.Rext, final_calib.text, dfiles, depth_plane_mask);
  calib0 = final_calib;
  
  new_depth_std = std( get_depth_error_all(final_calib,dfiles,depth_plane_mask) );
  converged = abs(old_depth_std - new_depth_std) < 0.01;
  old_depth_std = new_depth_std;
end
fprintf('Calibration finished!\n');

%%
% [alpha,im_beta]=calib_distortion(final_calib,final_calib.Rext, final_calib.text, dfiles, depth_plane_mask);
calibA = final_calib;
% calibA.dc_alpha = [];
% calibA.dc_beta = [];
calibB = final_calib;
calibB.dc_alpha = alpha;
calibB.dc_beta = im_beta;
[~,imA,isA]=get_depth_error_all(calibA,dfiles,depth_plane_mask);
[~,imB,isB]=get_depth_error_all(calibB,dfiles,depth_plane_mask);
[imA'-imB', isA'-isB']

%%
calibA = final_calib;
% calibA.dc_alpha = alpha;
% calibA.dc_beta = im_beta;
error = get_depth_error_all(calibA,dataset_path,dfiles,depth_plane_mask);
% for i=find(~cellfun(@isempty,dfiles))
%   imd = read_disparity(dfiles{i});
%   a = get_depth_error(calibA,dfiles{i},depth_plane_poly{i},final_calib.Rext{i},final_calib.text{i});
%   a = a(~isnan(a));
%   error = [error; a(:)];
% end;
[mean(error),std(error)]
hist(error,256)