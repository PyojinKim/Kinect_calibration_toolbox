% plot_depth_overlay(calib,k,im,imd,splat_size)
% im - can be an image or the index i into rfiles{k}{i} if it is an index
% imd is not needed.
function plot_depth_overlay(calib,k,im,imd,splat_size)
global dataset_path rfiles dfiles
global rsize

if(nargin <5)
  splat_size = 1;
end

if(ischar(im))
  im = imread(im);
  imd = read_disparity(imd);
else
  i = im;
  im = imread([dataset_path rfiles{k}{i}]);
  imd = read_disparity([dataset_path dfiles{i}]);
end

d = compute_rgb_depthmap(imd,calib,rsize{k},splat_size);

clf;
h = imshow(im);
hold on
h2 = imshow(d,[]);set(h2,'AlphaData',0.5)