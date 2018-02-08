%do_rgb_depthmap()
% UI function.
% Kinect calibration toolbox by DHC
function do_rgb_depthmap()

global rsize final_calib

if(isempty(final_calib))
  fprintf('Must perform calibration first.\n')
  return
end

filename = input('Depth image to project to rgb coordinates: ','s');
if(isempty(dir(filename)))
  fprintf('File not found.');
  return
end

imd = read_disparity(filename);

if(rsize{1}(1) > 480)
  splat_size = 3;
else
  splat_size = 1;
end
depthmap = compute_rgb_depthmap(imd,final_calib,rsize{1},splat_size);

%Show pure depthmap so that it can be stored
imtool(depthmap,[]);

%Find rgb file
rfilename = input('RGB image for visualization: ','s');
if(isempty(dir(rfilename)))
  fprintf('File not found.\n');
  return
end
im = imread(rfilename);

%Show superposition of depth map and rgb
figure(1);
clf;
imshow(im);
hold on;
h = imshow(mat2gray(depthmap));
set(h, 'AlphaData', 0.4);
