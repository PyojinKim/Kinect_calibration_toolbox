function [Rext,text,cost]=depth_extern_calib(calib, depth_plane_points, depth_plane_disparity)
  %Initial guess
  Xw = disparity2world(depth_plane_points(1,:),...
                        depth_plane_points(2,:),...
                        depth_plane_disparity,...
                        calib);
  [N0,d0] = fit_plane(Xw);

  %Encode params
  params0 = [];
  params0.N = N0;
  params0.d = d0;
  raw0 = s2r(params0);

  %Minimize
  fprintf('Optimizing pose only with depth points...');
  minimization_options=optimset('LargeScale','off','Algorithm','levenberg-marquardt','Display','none', 'TolFun',1e-4,'TolX',1e-8,'MaxFunEvals',20000,'MaxIter',1000);
  [raw_final,~,cost] = lsqnonlin(@(x) cost_fun(x,calib,depth_plane_points,depth_plane_disparity),raw0,[],[],minimization_options);

  fprintf(' Error: Mean=%f, Std=%f\n',mean(cost),std(cost));
  
  params = r2s(raw_final);
  [Rext,text] = plane2extrinsics(params.N,params.d);
end

function raw=s2r(params)
  raw = zeros(3,1);
  raw(1:3) = params.N*params.d;
end

function params=r2s(raw)
  params = [];
  params.d = norm(raw(1:3));
  params.N = raw(1:3)/params.d;
end

function cost=cost_fun(raw,calib,depth_plane_points,depth_plane_disparity)
  params = r2s(raw);
  [R,t] = plane2extrinsics(params.N,params.d);
  calib.Rext = {R};
  calib.text = {t};
  cost = calibrate_kinect_cost_depth(calib,[],{depth_plane_points},{depth_plane_disparity});
end