%%
calib_data = load('C:\datasets\kinect_toolbox\calibA1\calib_woffset.mat');
reg_data = read_yaml('C:\datasets\kinect_toolbox\calibA1\registration.yml');
calib = calib_data.final_calib;
base_path = 'C:\datasets\kinect_toolbox\cube_comparison\raw\';
filename = '0000-d.pgm';
width = 640;
height = 480;

%%
%Get samples
imd = read_disparity(filename);
[u,v] = meshgrid(0:width-1,0:height-1);
for k=1:3
  poly{k} = select_plane_polygon(imd);
  mask{k} = inpolygon(u,v,poly{k}(1,:),poly{k}(2,:)) & ~isnan(imd);
end

%%
[points,disparity]=get_depth_samples(base_path,{filename, filename, filename},mask);

%% Raw
N = {};
d = {};
% figure();
% hold on;
color='rgb';
for k=1:3
  xw = disparity2world(points{k}(1,:),points{k}(2,:),disparity{k},calib);
%   xw = ms_disparity2world(points{k}(1,:),points{k}(2,:),disparity{k},reg_data);
  [N{k},d{k}] = fit_plane(xw);
%   plot3(xw(1,:),xw(2,:),xw(3,:),['.' color(k)]);
  
  center = mean(xw,2);
  tip = center + 0.5*N{k};
%   plot3([center(1),tip(1)], [center(2),tip(2)], [center(3),tip(3)], ['-' color(k)]);
end
% axis equal

angles = 90-[acos(dot(N{1},N{2})),acos(dot(N{1},N{3})),acos(dot(N{2},N{3}))]' * 180/pi;
fprintf('Angles=[%.1f, %.1f, %.1f]\n',angles);