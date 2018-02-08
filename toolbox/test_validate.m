%%
% Init
global_vars();

calib_file = 'C:\datasets\kinect_toolbox\calibA2\best_calib.mat';
base_path = 'C:\datasets\kinect_toolbox\validateA1\';
do_load_calib([base_path 'validate_A1']);
% base_path = 'C:\datasets\kinect_toolbox\calibA2\';
% do_load_calib([base_path 'best_calib']);

for i=1:length(dfiles); 
  rgb_grid_p{2}{i} = []; 
  rgb_grid_x{2}{i} = []; 
end

do_validate(calib_file);

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
  
  filename = [base_path sprintf(r1_format,i)];
  if(exist(filename,'file'))
    rfiles{1}{i+1} = filename;
    found=true;
  else
    rfiles{1}{i+1} = [];
  end
  
  filename = [base_path sprintf(r2_format,i)];
  if(exist(filename,'file'))
    rfiles{2}{i+1} = filename;
    found=true;
  else
    rfiles{2}{i+1} = [];
  end

  filename = [base_path sprintf(d_format,i)];
  if(exist(filename,'file'))
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

% data = load([calib_path 'depth_results_dist.mat']);
% calib_dist = data.final_calib;
% data = load([calib_path 'depth_results_nodist.mat']);
% calib_nodist = data.final_calib;
is_validation = true;

%%
do_select_rgb_corners();

%%
do_select_planes();

%%
do_validate(calib_file);

%%
