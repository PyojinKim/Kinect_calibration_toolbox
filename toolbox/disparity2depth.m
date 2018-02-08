%w=disparity2depth(disp,dc)
% Converts a kinect disparity value into a depth value.
% 
% disp kinect disparity value
% calib.dc depth coefficients
% w third coordinate (z) in depth image coordinates
% 
% Kinect calibration toolbox by DHC
function w=disparity2depth(u,v,disp,calib)

disp_k = undistort_disparity(u,v,disp,calib);
w = 1 ./ (calib.dc(2)*disp_k + calib.dc(1));

if(isfield(calib,'dc_woffset') && ~isempty(calib.dc_woffset) && ~isempty(u) && ~isempty(v))
  ind = sub2ind([480,640],v+1,u+1);
  woffset = calib.dc_woffset(ind);
  w = w+woffset;
end
