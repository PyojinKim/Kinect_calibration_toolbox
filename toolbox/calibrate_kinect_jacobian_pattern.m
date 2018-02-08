function jacob_pattern = calibrate_kinect_jacobian_pattern(options,params0,rgb_grid_p,depth_plane_points)

ccount = length(rgb_grid_p);
icount = length(depth_plane_points);

raw_count = length(calibrate_kinect_s2r(params0,options));

%Find indexes of cost items
use_color = ~(options.use_fixed_rK && all(options.use_fixed_rkc) && options.use_fixed_pose);
use_depth = ~(options.use_fixed_dK && all(options.use_fixed_dkc) && all(options.use_fixed_dc) && options.use_fixed_dR && options.use_fixed_dt);

base = 1;
if(use_color)
  color_cost_base_first = zeros(ccount,1);
  color_cost_base_last = zeros(ccount,1);
  color_cost_base = zeros(ccount,icount);
  for k=1:ccount
    color_cost_base_first(k) = base;
    for i=1:icount
      color_cost_base(k,i) = base;
      base = base + 2*size(rgb_grid_p{k}{i},2);
    end
    color_cost_base_last(k) = base-1;
  end
end
if(use_depth)
  depth_cost_base_first = base;
  depth_cost_base = zeros(icount,1);
  for i=1:icount
    depth_cost_base(i) = base;
    base = base + size(depth_plane_points{i},2);
  end
  depth_cost_base_last = base-1;
end
cost_count = base-1;

%Create sparse matrix
% jacob_pattern = sparse(cost_count,raw_count);
jacob_pattern = zeros(cost_count,raw_count);

% Raw parameters
base = 1;

%Depth distortion parameters
% Count=5
for i=1:5
  if(~options.use_fixed_dkc(i))
    raw_idx = base;
    
    [cci,rri] = meshgrid(raw_idx,depth_cost_base_first:depth_cost_base_last);
    ind = sub2ind([cost_count,raw_count],rri,cci);
    jacob_pattern(ind) = 1;

    base = base+1;
  end
end

%Depth internal matrix
if(~options.use_fixed_dK)
  raw_idx = base:base+3;

  [cci,rri] = meshgrid(raw_idx,depth_cost_base_first:depth_cost_base_last);
  ind = sub2ind([cost_count,raw_count],rri,cci);
  jacob_pattern(ind) = 1;

  base = base+4;
end

%Depth
for i=1:length(options.use_fixed_dc)
  if(~options.use_fixed_dc(i))
    raw_idx = base;

    [cci,rri] = meshgrid(raw_idx,depth_cost_base_first:depth_cost_base_last);
    ind = sub2ind([cost_count,raw_count],rri,cci);
    jacob_pattern(ind) = 1;

    base = base+1;
  end
end

%RGB distortion parameters
for k=1:ccount
  for i=1:5
    if(~options.use_fixed_rkc(i))
      raw_idx = base;
      
      [cci,rri] = meshgrid(raw_idx,color_cost_base_first(k):color_cost_base_last(k));
      ind = sub2ind([cost_count,raw_count],rri,cci);
      jacob_pattern(ind) = 1;

      base = base+1;
    end
  end
end

%RGB internal matrix
if(~options.use_fixed_rK)
  for k=1:ccount
    raw_idx = base:base+3;

    [cci,rri] = meshgrid(raw_idx,color_cost_base_first(k):color_cost_base_last(k));
    ind = sub2ind([cost_count,raw_count],rri,cci);
    jacob_pattern(ind) = 1;

    base = base+4;
  end
end

%Relative pose matrices
if(~options.use_fixed_dR)
  raw_idx = base:base+2;

  [cci,rri] = meshgrid(raw_idx,depth_cost_base_first:depth_cost_base_last);
  ind = sub2ind([cost_count,raw_count],rri,cci);
  jacob_pattern(ind) = 1;

  base = base+3;
end
if(~options.use_fixed_dt)
  raw_idx = base:base+2;

  [cci,rri] = meshgrid(raw_idx,depth_cost_base_first:depth_cost_base_last);
  ind = sub2ind([cost_count,raw_count],rri,cci);
  jacob_pattern(ind) = 1;

  base = base+3;
end

%External pose matrices
if(~options.use_fixed_pose)
  for i=1:icount
    raw_idx = base:base+5;

    [cci,rri] = meshgrid(raw_idx,1:cost_count);
    ind = sub2ind([cost_count,raw_count],rri,cci);
    jacob_pattern(ind) = 1;
    
    base = base+6;
  end
  
  for k=2:ccount
    raw_idx = base:base+5;

    [cci,rri] = meshgrid(raw_idx,color_cost_base_first(k):color_cost_base_last(k));
    ind = sub2ind([cost_count,raw_count],rri,cci);
    jacob_pattern(ind) = 1;

    base = base+6;
  end
end

assert(raw_count == base-1);
% jacob_pattern = sparse(rr,cc,1,cost_count,raw_count);
jacob_pattern = sparse(jacob_pattern);