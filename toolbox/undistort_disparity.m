function disp_k=undistort_disparity(u,v,disp,calib)
  disp_k = disp;
  if(~(isempty(u) || isempty(v) || isempty(calib.dc_alpha) || isempty(calib.dc_beta)))
    ind = sub2ind([480,640],v+1,u+1);
    beta = calib.dc_beta(ind); 

    valid = beta~=0;

    disp_k(valid) = disp(valid) + beta(valid).*exp(calib.dc_alpha(1) - calib.dc_alpha(2)*disp(valid));
  end
end