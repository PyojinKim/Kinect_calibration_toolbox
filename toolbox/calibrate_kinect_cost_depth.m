% cost=calibrate_kinect_cost_depth(params,options,depth_plane_points,depth_plane_disparity)
% Cost for depth images, used by calibrate_kinect_cost.
%
% Kinect calibration toolbox by DHC
function cost=calibrate_kinect_cost_depth(params,options,depth_plane_points,depth_plane_disparity)

total_count = sum( cellfun(@length, depth_plane_disparity) );
cost=zeros(total_count,1);

base = 1;
for i=find(~cellfun(@(x) isempty(x),depth_plane_points))
  u = depth_plane_points{i}(1,:);
  v = depth_plane_points{i}(2,:);

  ref_w = get_expected_plane_depth(depth_plane_points{i},params,params.Rext{i},params.text{i});
  if(isfield(params,'dc_woffset') && ~isempty(params.dc_woffset))
    ind = sub2ind([480,640],v+1,u+1);
    woffset = params.dc_woffset(ind);
    ref_w = ref_w-woffset;
  end

  ref_disp_k = depth2disparity([],[],ref_w,params);
  
  disp_k = undistort_disparity(u,v,depth_plane_disparity{i},params);  
  disp_error = disp_k - ref_disp_k;

%   ref_disp = distort_disparity(u,v,ref_disp_k,params);
%   disp_error = depth_plane_disparity{i} - ref_disp;
  
  cost(base:base+length(disp_error)-1) = disp_error';
  base = base+length(disp_error);
end
