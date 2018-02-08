%res=depth_plane_error(depth_calib,depth_plane_points,depth_plane_disparity)
% Reprojects the depth_plane_points to color camera coordinates and
% calculates the distance to the calibration plane (Rext,text).
% 
% Kinect calibration toolbox by DHC
function res=depth_plane_error(depth_calib,depth_plane_points,depth_plane_disparity)

res=[];
for i=find(~cellfun(@(x) isempty(x),depth_plane_points))
  count = size(depth_plane_points{i},2);

  x = disparity2world(depth_plane_points{i}(1,:),...
                      depth_plane_points{i}(2,:),...
                      depth_plane_disparity{i},...
                      depth_calib);

  [N,d] = plane_from_extrinsic(depth_calib.Rext{i},depth_calib.text{i});
  error = dot(repmat(N,1,count), x) - repmat(d,1,count);
  res=[res, error];
end