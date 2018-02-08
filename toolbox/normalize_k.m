function [xn] = normalize_k(p,K,kc)
  xd = [(p(1,:) - K(1,3))/K(1,1);(p(2,:) - K(2,3))/K(2,2)];
  
  minimization_options=optimset(...
    'LargeScale','on',...
    'Algorithm','levenberg-marquardt',...
    'Jacobian','on',...
    'Display','none',...
    'TolFun',1e-3,...
    'TolX',1e-3,...
    'MaxFunEvals',20000,...
    'MaxIter',1000);
%   'LargeScale','off',...
%     'Algorithm','levenberg-marquardt',...
%   xn = zeros(2,pcount);
  
  xn = lsqnonlin(@(x) mycost(x,xd,kc), xd,[],[],minimization_options);
end

function [cost,j]=mycost(xn,xd,kc)
  x1 = xn(1,:);
  x2 = x1.*x1;
  x3 = x1.*x2;
  x4 = x1.*x3;
  x5 = x1.*x4;
  x6 = x1.*x5;
  y1 = xn(2,:);
  y2 = y1.*y1;
  y3 = y1.*y2;
  y4 = y1.*y3;
  y5 = y1.*y4;
  y6 = y1.*y5;
  
  r2 = x2+y2;
  r4 = r2.*r2;
  r6 = r4.*r2;
  rc = 1 + kc(1)*r2 + kc(2)*r4 + kc(5)*r6;
  dx = 2*kc(3)*x1.*y1 + kc(4)*(r2 + 2*x2);
  dy = kc(3)*(r2 + 2*y2) + 2*kc(4)*x1.*y1;
  xdd = [rc.*x1 + dx; rc.*y1 + dy];
  %xdd=distort(xn,kc);
  cost = xdd-xd;
  
  pcount = size(xd,2);
  
  jxy0 = kc(1)*2*x1.*y1 + kc(2)*(4*x1.*y3+4*x3.*y1) + ...
    kc(5)*(6*x1.*y5 + 6*x5.*y1+12*x3.*y3) + ...
    2*kc(3)*x1;
  
  iodd = 1:2:2*pcount;
  ieven = 2:2:2*pcount;
  %jxx_i = 1:2:2*pcount;
  %jxx_j = 1:2:2*pcount;
  jxx = 1+kc(1)*(3*x2+y2) + kc(2)*(5*x4+y4+6*x2.*y2) + ...
    kc(5)*(7*x6+y6+15*x4.*y2+9*x2.*y4) + ...
    kc(3)*2*y1 + kc(4)*6*x1;
  %jxy_i = 1:2:2*pcount;
  %jxy_j = 2:2:2*pcount;
  jxy = jxy0 + kc(4)*2*y1;

  %jyx_i = 2:2:2*pcount;
  %jyx_j = 1:2:2*pcount;
  jyx = jxy0 + kc(4)*2*x1;
  %jyy_i = 2:2:2*pcount;
  %jyy_j = 2:2:2*pcount;
  jyy = 1+kc(1)*(x2+3*y2) + kc(2)*(x4+5*y4+6*x2.*y2) + ...
    kc(5)*(x6+7*y6+15*x2.*y4+9*x4.*y2) + ...
    kc(3)*6*y1 + kc(4)*2*x1;
  j = sparse([iodd; iodd; ieven; ieven],...
    [iodd; ieven; iodd; ieven],...
    [jxx; jxy; jyx; jyy],...
    2*pcount,2*pcount,4*pcount);
  %   pp = project_points_kc([xn;1],K,kc);
%   cost = (pp-p);
end