function Xw=ms_disparity2world(u,v,disparity,reg_data)
  wz = reg_data.raw_to_mm_shift(disparity+1);

  DEPTH_X_RES = 640;
  DEPTH_Y_RES = 480;
  
  ref_pix_size = reg_data.reference_pixel_size;
  ref_distance = reg_data.reference_distance;
  xfactor = 2*ref_pix_size * wz / ref_distance;
	yfactor = (1024/480)*ref_pix_size * wz / ref_distance;
%   xfactor = ref_pix_size * wz / ref_distance;
  yfactor = xfactor;
  wx = (u - DEPTH_X_RES/2) .* xfactor;
  wy = (v - DEPTH_Y_RES/2) .* yfactor;

  Xw = [wx;wy;wz]/1e3;
end