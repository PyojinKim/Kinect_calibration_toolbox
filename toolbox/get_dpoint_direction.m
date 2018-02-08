function xn=get_dpoint_direction(u,v,calib)
  xn = [(u-calib.dK(1,3)) / calib.dK(1,1); 
       (v-calib.dK(2,3)) / calib.dK(2,2)];
  if(any(calib.dkc~=0))
    xn = distort(xn,calib.dkc);
  end
%   return
%   if(all(calib.dkc==0))
%     xn = [(u-calib.dK(1,3)) / calib.dK(1,1); 
%          (v-calib.dK(2,3)) / calib.dK(2,2)];
%   else
%     idx = sub2ind(size(calib.dlut_x),v+1,u+1);
%     xn = [calib.dlut_x(idx); calib.dlut_y(idx)];
%   end
end