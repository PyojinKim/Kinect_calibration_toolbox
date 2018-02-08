%[rgb_files,depth_files]=parse_files(rgb_exp, depth_exp)
% Reads the files in the current directory and builds rgb and depth image
% pairs.
%
% Kinect calibration toolbox by DHC
function [rgb_files,depth_files]=parse_files(rgb_exp, depth_exp)

%Scan directory
rgb_list = dir(rgb_exp);
depth_list = dir(depth_exp);

%Extract stamps
rgb_stamps = zeros(size(rgb_list));
for i=1:length(rgb_list)
  rgb_stamps(i) = parse_stamp(rgb_list(i).name);
end

depth_stamps = zeros(size(depth_list));
for i=1:length(rgb_list)
  depth_stamps(i) = parse_stamp(depth_list(i).name);
end

%Sort
[rgb_stamps,i] = sort(rgb_stamps,1,'ascend');
rgb_list = {rgb_list(i).name};
[depth_stamps,i] = sort(depth_stamps,1,'ascend');
depth_list = {depth_list(i).name};

%Match
rgb_files = {};
depth_files = {};

di = 1;
for ri = 1:length(rgb_stamps)
  %Find closest depth timestamp
  while(di<length(depth_stamps))
    if(abs(depth_stamps(di)-rgb_stamps(ri)) < abs(depth_stamps(di+1)-rgb_stamps(ri)))
      break;
    end
    di = di+1;
  end
  
  %Add to list
  rgb_files{end+1,1} = rgb_list{ri};
  depth_files{end+1,1} = depth_list{ri};
end

function stamp=parse_stamp(filename)
  p1 = find(filename=='-',1,'last');
  p2 = find(filename=='.',1,'last');
  stamp = str2double(filename(p1+1:p2-1));
