%[N,d]=fit_plane(X)
% Finds the best fit plane for a set of points using PCA.
% Kinect calibration toolbox by DHC
function [N,d]=fit_plane(X)
  center = mean(X,2);
  vecs = princomp(X');
  
  N = vecs(:,3);
  d = dot(N,center);
end