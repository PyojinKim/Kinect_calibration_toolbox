function ref_w = get_expected_plane_depth(points,calib,Rext,text)
  %Get expected values
  [rN,rd] = extrinsic2plane(Rext,text);
  dN = calib.dR'*rN;
  dd = dot(-calib.dR'*calib.dt,rN) + rd;

  xn = get_dpoint_direction(points(1,:),points(2,:),calib);

  ref_w = dd ./ (dN(1)*xn(1,:)+dN(2)*xn(2,:)+dN(3));
end