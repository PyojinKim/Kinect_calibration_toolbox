%do_select_rgb_corners()
% UI function.
% Kinect calibration toolbox by DHC
function do_select_rgb_corners()

%Input
global dataset_path rfiles
%Output
global rgb_grid_p rgb_grid_x

%Check previous steps
if(isempty(rfiles))
  do_select_images();
end

fprintf('-------------------\n');
fprintf('Selecting rgb corners\n');
fprintf('-------------------\n');

ccount = length(rfiles);
icount = length(rfiles{1});
if(isempty(rgb_grid_p))
  rgb_grid_p = cell(1,ccount);
  rgb_grid_x = cell(1,ccount);
end


%Select pattern dimensions
default = 0.04;
dx = input(['Square size ([]=' num2str(default) 'm): ']);
if(isempty(dx))
  dx = default;
end

%Use automatic corner detector?
use_automatic = input(['Use automatic corner detector? ([]=true, other=false)? '],'s');
if(isempty(use_automatic))
  use_automatic = true;
  corner_count_x = input(['Inner corner count in X direction: ']);
  corner_count_y = input(['Inner corner count in Y direction: ']);
else
  use_automatic = false;
end


for k=1:ccount
  fprintf('Camera %d\n',k);

  %Select search window dimensions
  default = 6;
  win_dx = input(['Corner finder window size ([]=' num2str(default) 'px): ']);
  if(isempty(win_dx))
    win_dx = default;
  end

  %Select images
  if(isempty(rgb_grid_x{k}))
    rgb_grid_p{k} = cell(1,icount);
    rgb_grid_x{k} = cell(1,icount);
    fidx = 1:icount;
  else
    %Check for too small or too big array
    if(length(rgb_grid_x{k}) ~= icount)
      rgb_grid_p{k}{icount} = [];
      rgb_grid_x{k}{icount} = [];
    elseif(length(rgb_grid_x{k}) > icount)
      rgb_grid_p{k} = rgb_grid_p{k}(1:icount);
      rgb_grid_x{k} = rgb_grid_x{k}(1:icount);
    end

    %Select only missing planes
    missing = cellfun(@(x) isempty(x),rgb_grid_x{k}) & ~cellfun(@(x) isempty(x),rfiles{k});
    if(all(missing))
      default = 1:icount;
      fidx = input('Select images to process ([]=all): ');
    else
      default = find(missing);
      fidx = input(['Select images to process ([]=[' num2str(default) ']): ']);
    end
    if(isempty(fidx))
      fidx = default;
    end
  end

  
  figure(1);
  clf;
  figure(2);
  clf;

  %Extract grid for all images
  for i=fidx
    if(isempty(rfiles{k}{i}))
      continue
    end

    fprintf('#%d - %s\n',i,rfiles{k}{i});

    im = imread([dataset_path rfiles{k}{i}]);
    if(size(im,3)==3)
      im = rgb2gray(im);
    end

    p = [];
    if(use_automatic)
      p=click_ima_calib_rufli_k(i,im,true,win_dx,win_dx,corner_count_x-1,corner_count_y-1);
    end
    
    if(isempty(p))
      [p,~,win_dx] = select_rgb_corners_im(im,dx,win_dx);
    end
    
    if(isempty(p))
      pp = [];
      xx = [];
    else
      [pp,xx,cx] = reorder_corners(p,dx);
      figure(2);
      hold off;
      plot_rgb_corners(k,i,pp);
      hold on;
      draw_axes(pp,cx);
      drawnow;
    end
    
    rgb_grid_p{k}{i} = pp;
    rgb_grid_x{k}{i} = xx;

    %fprintf('Press ENTER to continue\n');
    %pause;
  end
  
  fprintf('Finished extracting corners for the selected images.\n');
end
