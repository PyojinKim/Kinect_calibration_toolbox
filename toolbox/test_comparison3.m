%%
do_load_calib('C:\datasets\kinect_toolbox\calibA2\validate_A1.mat');
calib = final_calib;
reg_data = read_yaml('C:\datasets\kinect_toolbox\calibA1\registration.yml');
errors_disp={[] []};
ref_disp={[] []};
errors_depth={[] []};
ref_depth={[] []};
ref_beta=[];
for i=find(~cellfun(@isempty,depth_plane_mask))
  [points,disparity]=get_depth_samples(dfiles{i},depth_plane_mask{i});
  if(isempty(disparity))
    continue;
  end
  u = points(1,:);
  v = points(2,:);

  %Distortion beta
  ind = sub2ind(size(calib.dc_beta),v+1,u+1);
  ref_beta_i = calib.dc_beta(ind);
  ref_beta = [ref_beta,ref_beta_i];
  
  %Raw errors
  xw = disparity2world(u,v,disparity,calib);

  [paxes] = princomp(xw');
  N = paxes(:,3);
  d = N' * mean(xw,2);

  xn = bsxfun(@rdivide, xw(1:2,:), xw(3,:));

  ref_depth_i = d ./ (sum(bsxfun(@times, xn, N(1:2)),1)+N(3));
  errors_depth_i = ref_depth_i - xw(3,:);
  
  ref_disp_i = depth2disparity(u,v,ref_depth_i,calib);
  errors_disp_i = ref_disp_i - disparity;

  errors_depth{1} = [errors_depth{1}, errors_depth_i];
  ref_depth{1} = [ref_depth{1}, ref_depth_i];
  errors_disp{1} = [errors_disp{1}, errors_disp_i];
  ref_disp{1} = [ref_disp{1}, ref_disp_i];
  
  %Reg errors
  xw = ms_disparity2world(u,v,disparity,reg_data);

  [paxes] = princomp(xw');
  N = paxes(:,3);
  d = N' * mean(xw,2);

  xn = bsxfun(@rdivide, xw(1:2,:), xw(3,:));
  ref_depth_i = d ./ (sum(bsxfun(@times, xn, N(1:2)),1)+N(3));

  errors_depth_i = ref_depth_i - xw(3,:);

  errors_depth{2} = [errors_depth{2}, errors_depth_i];
  ref_depth{2} = [ref_depth{2}, ref_depth_i];
end

%%
  dataset_labels = {'Our method','Manufacturer calibration'};
  bins = 64;

  hist_std = zeros(3,bins);
  count = zeros(3,bins);
  
  for k=1:2
    step = (max(ref_depth{k})-min(ref_depth{k}))/bins;
    limit = min(ref_depth{k}):step:max(ref_depth{k});
    for i=1:bins
      valid = ref_depth{k} >=limit(i) & ref_depth{k} < limit(i+1); %& abs(ref_beta)<=0.5;
      if(sum(valid) < 50)
        hist_std(k,i) = nan;
      else
        data = errors_depth{k}(valid);
        hist_std(k,i) = nanstd(data);
        count(k,i) = sum(~isnan(data));
      end
    end
    
    %Fit polygon
    x = limit(1:bins);
    y = hist_std(k,:);
    w = count(k,:); w(:)=1;
    valid = ~isnan(y); x=x(valid); y=y(valid); w=w(valid);
    
    A = bsxfun(@times, [x'.^2, x', ones(sum(valid),1)], w'.^2);
    b = y' .* w'.^2;
    p = A\b;
    
    xeval = min(x):0.1:max(x);
%     plot(xeval,polyval(p,xeval),['-' color(k)],'DisplayName', ['Fitted: ' dataset_labels{k}]);
  end
  
  %%
  clf
  hold on
  set(gcf,'Position',[100,100,450,350]);
  color = 'brg';
  marker = '.+o';
  marker_weight = [15,10,10];
  for k=1:2
    %plot(limit(1:bins), 1e3*hist_std(k,:), [marker(k) color(k)], 'DisplayName', dataset_labels{k},'MarkerSize',marker_weight(k));
    a = 0.999;
    lower_limit = hist_std(k,:)-((count(k,:)-1)./chi2inv(a,count(k,:)-1)).^0.5.*hist_std(k,:);
    upper_limit = ((count(k,:)-1)./chi2inv(1-a,count(k,:)-1)).^0.5.*hist_std(k,:) - hist_std(k,:);
    %errorbar(limit(1:bins), 1e3*hist_std(k,:), 1e3*lower_limit, 1e3*upper_limit, [marker(k) color(k)], 'DisplayName', dataset_labels{k},'MarkerSize',marker_weight(k));
    plot(limit(1:bins), 1e3*hist_std(k,:), [marker(k) color(k)], 'DisplayName', dataset_labels{k},'MarkerSize',marker_weight(k));
  end
  grid
  legend('Location','NorthWest');
  xlabel('Depth (m)');
  ylabel('Error std. dev. (mm)');
  title('Depth uncertainty');

  %%
  % Plot expected curve
  sample_count = 100000;
  correct_distortion = true;
  dstd = 0.6;
%   dstd = depth_calib.depth_error_var.^0.5;
  wrange = 0.5:0.01:3.5;
  expected_wstd = zeros(size(wrange));
  for correct_distortion=[true]
    for i=1:length(wrange)
      wtrue = wrange(i);

      u = randi([0,639],[1,sample_count]);
      v = randi([0,479],[1,sample_count]);

      dtrue = depth2disparity(u,v,repmat(wtrue,1,sample_count),calib);
  %     dtrue = depth2disparity([],[],repmat(wtrue,1,sample_count),calib);

      dsamples = round( dtrue + dstd*randn(1,sample_count) );
      if(correct_distortion)
        wsamples = disparity2depth(u,v,dsamples,calib);
      else
        wsamples = disparity2depth([],[],dsamples,calib);
      end

      expected_wstd(i) = std(wtrue-wsamples);
    end
    if(correct_distortion)
      name = ['Simulated, \sigma_d=' num2str(dstd)];
      style = '-k';
    else
      name = ['Uncorrected, Disp. \sigma=' num2str(dstd)];
      style = '--k';
    end
    plot(wrange,1e3*expected_wstd,style,'DisplayName',name,'LineWidth',2);
    drawnow
  end
  legend off
  legend('Location','NorthWest');
  
  %%
  