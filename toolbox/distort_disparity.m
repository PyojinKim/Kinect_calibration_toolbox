function disp=distort_disparity(u,v,disp_k,calib)
  disp = disp_k;
  if(~(isempty(u) || isempty(v) || isempty(calib.dc_alpha) || isempty(calib.dc_beta)))
    %Distort
    %solve('y=exp(a*y+b)','y') = -lambertw(0, -a*exp(b))/a
    ind = sub2ind([480,640],v+1,u+1);
    beta = calib.dc_beta(ind);

    a=calib.dc_alpha(2)*beta;
    b=calib.dc_alpha(1)-calib.dc_alpha(2)*disp_k;

    lx = -a.*exp(b);
    %distortion = -lambertw(0,v)./dc_alpha(1);

    distortion = lambertw_fast(lx) ./ calib.dc_alpha(2);

    valid = ~isnan(distortion);
    disp(valid) = disp_k(valid)+distortion(valid);
  end
end