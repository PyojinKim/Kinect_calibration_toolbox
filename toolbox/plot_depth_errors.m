function plot_depth_errors(calib, Rext, text)
  global dataset_path dfiles depth_plane_mask

  if(nargin < 3)
    Rext = calib.Rext;
    text = calib.text;
  end  

  errors_disp=[];
  errors_w=[];
  ref_w=[];
  for i=find(~cellfun(@isempty,depth_plane_mask))
    [points,disparity]=get_depth_samples(dataset_path,dfiles{i},depth_plane_mask{i});
    if(isempty(disparity))
      continue;
    end
    
    [errors_disp_i,~,errors_w_i,ref_w_i] = get_depth_error(calib,points,disparity,Rext{i},text{i});
    errors_disp = [errors_disp,errors_disp_i];
    errors_w = [errors_w,errors_w_i];
    ref_w = [ref_w,ref_w_i];
  end
  
  %Plot disparity reprojection errors over all images
  figure()
  edges = min(errors_disp):0.2:max(errors_disp);
  hist(errors_disp,edges);
  title(sprintf('Disparity reprojecton histogram over all images. Total mean=%f, total std=%f', mean(errors_disp),std(errors_disp)));
  xlabel('Error (kinect units)');
  ylabel('Pixel count');
  
  %Plot depth uncertainty in meters
  bins = 64;
  min_sample_count = 50;
  hist_std = zeros(1,bins);

  step = (max(ref_w)-min(ref_w))/bins;
  limit = min(ref_w):step:max(ref_w);
  for i=1:bins
    valid = ref_w >=limit(i) & ref_w < limit(i+1);
    if(sum(valid) < min_sample_count)
      hist_std(i) = nan;
    else
      data = errors_w(valid);
      hist_std(i) = nanstd(data);
    end
  end

  %Fit polygon
  x = limit(1:bins);
  y = hist_std;
  w = ones(size(y));
  valid = ~isnan(y); x=x(valid); y=y(valid); w=w(valid);

  A = bsxfun(@times, [x'.^2, x', ones(sum(valid),1)], w'.^2);
  b = y' .* w'.^2;
  p = A\b;
  
  fprintf('Fitted uncertainty curve is:\n');
  fprintf('%f*x^2%+f*x%+f\n',p);

  figure()
  plot(limit(1:bins), hist_std, '.b', 'DisplayName', 'Error samples');
  hold on
  xeval = min(x):0.1:max(x);
  plot(xeval,polyval(p,xeval),'-b','DisplayName', 'Fitted curve');
  grid
  legend('Location','NorthWest');
  xlabel('Depth (m)');
  ylabel('Error std. dev. (m)');
  title('Uncertainty of the Kinect device');

end
