function [rgb_errors,image_mean,image_std] = get_rgb_errors(calib,grid_p,grid_x,Rext,text)
  if(nargin < 3)
    global rgb_grid_p rgb_grid_x
    grid_p = rgb_grid_p;
    grid_x = rgb_grid_x;
  end
  if(nargin < 5)
    Rext = calib.Rext;
    text = calib.text;
  end  
  ccount = length(grid_p);
  icount = length(grid_p{1});
  
  rgb_errors = cell(1,ccount);
  image_mean = nan(icount,ccount);
  image_std = nan(icount,ccount);
  
  for k=1:ccount
    rgb_errors{k} = [];
    for i=find(~cellfun(@(x) isempty(x),grid_p{k}))
      R = calib.rR{k}'*Rext{i};
      t = calib.rR{k}'*(text{i} - calib.rt{k});
      x = grid_x{k}{i};
      p = project_points_k(x,calib.rK{k},calib.rkc{k},R,t);
      
      errors_i = [p(1,:)-grid_p{k}{i}(1,:), p(2,:)-grid_p{k}{i}(2,:)];
      image_mean(i,k) = mean(errors_i);
      image_std(i,k) = std(errors_i);
      
      rgb_errors{k} = [rgb_errors{k}, errors_i];
    end
  end
end
