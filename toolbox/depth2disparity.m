%disp_d=depth2disparity(u,v,w,dc,dc_alpha,dc_beta)
% Converts a depth value into a kinect disparity value.
% 
% u pixel column coordinate (zero based)
% v pixel row coordinate (zero based)
% w third coordinate (z) in depth image coordinates (in meters)
% calib.dc depth coefficients
%
% disp disparity (distorted, as would be returned by Kinect)
% 
% Kinect calibration toolbox by DHC
function disp=depth2disparity(u,v,w,calib)

if(isfield(calib,'dc_woffset') && ~isempty(calib.dc_woffset) && ~isempty(u) && ~isempty(v))
  ind = sub2ind([480,640],v+1,u+1);
  woffset = calib.dc_woffset(ind);
  w = w-woffset;
end

disp_k = 1./(w*calib.dc(2)) - calib.dc(1)/calib.dc(2);
disp = distort_disparity(u,v,disp_k,calib);
