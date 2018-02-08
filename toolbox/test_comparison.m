  %%
  base_path = 'C:\datasets\kinect_toolbox\comparison\';
  raw_format = 'freenect\\%.4d-d.pgm';
  reg_format = 'freenect_reg\\%.4d-w.yml';
  ms_format = 'ms\\%.4d-d.pgm';
  burrus_format = 'burrus\\%.4d-mesh.ply';

  data = load('C:\datasets\kinect_toolbox\calibA1\depth_results.mat');
  depth_calib = data.final_calib;

  dataset_labels = {'raw','reg','ms','burrus'};
  dcount = length(dataset_labels);
  
  %Find files
  dfiles = cell(1,dcount);
  i=0;
  found = true;
  while(found)
    found = false;

    %Raw
    filename = [base_path sprintf(raw_format,i)];
    if(exist(filename,'file'))
      dfiles{1}{i+1} = filename;
      found=true;
    else
      dfiles{1}{i+1} = [];
    end

    %Freenect registered
    filename = [base_path sprintf(reg_format,i)];
    if(exist(filename,'file'))
      dfiles{2}{i+1} = filename;
      found=true;
    else
      dfiles{2}{i+1} = [];
    end

    %Microsoft Kinect SDK
    filename = [base_path sprintf(ms_format,i)];
    if(exist(filename,'file'))
      dfiles{3}{i+1} = filename;
      found=true;
    else
      dfiles{3}{i+1} = [];
    end

    %Nicholas Burrus
    filename = [base_path sprintf(burrus_format,i)];
    if(exist(filename,'file'))
      dfiles{4}{i+1} = filename;
      found=true;
    else
      dfiles{4}{i+1} = [];
    end
    i=i+1;
  end
  icount = i-1;

  %% Limits
  limits_px = nan(icount,4); %left,right,top,bottom
  limits_px(7,1) = 40;
  limits_px(7,2) = 600;
  limits_px(7,3) = 1;
  limits_px(7,4) = 415;
  
  limits_px(8,1) = 1;
  limits_px(8,2) = 640;
  limits_px(8,3) = 1;
  limits_px(8,4) = 400;
  
  %%
  %Compute errors for raw
  image_std = zeros(icount,dcount);
  errors{1} = [];
  ref_depth = [];

  for i=1:icount
    imd = read_disparity(dfiles{1}{i});
    
    [xw,idx] = disparity2world([],[],imd,depth_calib);
    if(~isnan(limits_px(i,1)))
      [v,u] = ind2sub(size(imd),idx);
      roi = u >= limits_px(i,1) & ...
        u <= limits_px(i,2) & ...
        v >= limits_px(i,3) & ...
        v <= limits_px(i,4);
      xw(:,~roi) = nan;
    end
    valid = ~isnan(xw(3,:));
    
    [paxes] = princomp(xw(:,valid)');
    pN = paxes(:,3);
    pd = pN' * nanmean(xw,2);
    
    xn = bsxfun(@rdivide, xw(1:2,:), xw(3,:));
    w_ref = pd ./ (sum(bsxfun(@times, xn, pN(1:2)),1)+pN(3));

    e = w_ref - xw(3,:);

    ref_depth = [ref_depth, w_ref];
    
    image_std(i,1) = nanstd(e);
    errors{1} = [errors{1}, e];
  end
      
  %%
  %Compute errors for reg
  errors{2} = [];
  
  for i=1:icount
    data = read_yaml(dfiles{2}{i});
    z = data.xw(:,:,3); z=z(:)'; z(z==0)=nan;
    x = data.xw(:,:,1); x=x(:)';
    y = data.xw(:,:,2); y=y(:)';
    xw = [x; y; z] / 1000;
    if(~isnan(limits_px(i,1)))
      idx = zeros(size(data.xw(:,:,1)));
      idx(1:numel(idx)) = 1:numel(idx);
      idx = idx(:)';

      [v,u] = ind2sub(size(imd),idx);
      roi = u >= limits_px(i,1) & ...
        u <= limits_px(i,2) & ...
        v >= limits_px(i,3) & ...
        v <= limits_px(i,4);
      xw(:,~roi) = nan;
    end
    
    valid = ~isnan(xw(3,:));
    xw(:,~valid) = nan;

    paxes = princomp(xw(:,valid)');
    pN = paxes(:,3);
    pd = pN' * nanmean(xw,2);
    
    xn = bsxfun(@rdivide, xw(1:2,:), xw(3,:));
    w_ref = pd ./ (sum(bsxfun(@times, xn, pN(1:2)),1)+pN(3));

    e = w_ref - xw(3,:);

    image_std(i,2) = nanstd(e);
    errors{2} = [errors{2}, e];
  end
  
  %%
  %Compute errors for ms
  errors{3} = [];
  
  for i=1:icount
    imd = read_disparity(dfiles{3}{i},0) / 1000;
    [xw,idx] = depth2world([],[],imd,depth_calib);
    if(~isnan(limits_px(i,1)))
      [v,u] = ind2sub(size(imd),idx);
      roi = u >= limits_px(i,1) & ...
        u <= limits_px(i,2) & ...
        v >= limits_px(i,3) & ...
        v <= limits_px(i,4);
      xw(:,~roi) = nan;
    end
    valid = ~isnan(xw(3,:));
    
    paxes = princomp(xw(:,valid)');
    pN = paxes(:,3);
    pd = pN' * nanmean(xw,2);
    
    xn = bsxfun(@rdivide, xw(1:2,:), xw(3,:));
    w_ref = pd ./ (sum(bsxfun(@times, xn, pN(1:2)),1)+pN(3));

    e = w_ref - xw(3,:);

    image_std(i,3) = nanstd(e);
    errors{3} = [errors{3}, e];
  end
  
  %%
  %Compute errors for burrus
  errors{4} = [];

  for i=1:icount
    data = ply_read(dfiles{4}{i});
    xw = [data.vertex.x, data.vertex.y, data.vertex.z]';
    
    paxes = princomp(xw');
    pN = paxes(:,3);
    pd = pN' * nanmean(xw,2);
    
    xn = bsxfun(@rdivide, xw(1:2,:), xw(3,:));
    w_ref = pd ./ (sum(bsxfun(@times, xn, pN(1:2)),1)+pN(3));

    e = w_ref - xw(3,:);
%     [~,scores] = princomp(xw');
%     e = scores(:,3);
    image_std(i,4) = std(e);
    errors{4} = [errors{4}, e];
  end
      
  %%
  image_std
  [nanstd(errors{1}), nanstd(errors{2}), nanstd(errors{3}), nanstd(errors{4})]
  
  %%
  bins = 64;
  step = (max(ref_depth)-min(ref_depth))/bins;
  limit = min(ref_depth):step:max(ref_depth);

  hist_std = zeros(3,bins);
  weight = zeros(3,bins);
  
  clf
  hold on
  color = 'brg';
  for k=1:3
    for i=1:bins
      valid = ref_depth >=limit(i) & ref_depth < limit(i+1);
      if(sum(valid) < 50)
        hist_std(k,i) = nan;
      else
        data = errors{k}(valid);
        hist_std(k,i) = nanstd(data);
        weight(k,i) = sum(~isnan(data));
      end
    end
    plot(limit(1:bins), hist_std(k,:), ['.' color(k)], 'DisplayName', dataset_labels{k});
    
    %Fit polygon
%     x = limit(1:bins);
%     y = hist_std(k,:);
%     w = weight(k,:);
%     valid = ~isnan(y); x=x(valid); y=y(valid); w=w(valid);
    
%     A = bsxfun(@times, [x'.^2, x', ones(sum(valid),1)], w'.^2);
%     b = y' .* w'.^2;
%     p = A\b;
    
%     xeval = min(x):0.1:max(x);
%     plot(xeval,polyval(p,xeval),['-' color(k)],'DisplayName', dataset_labels{k});
  end
  grid
  legend('Location','NorthWest');
  
  %% Plot expected curve
  sample_count = 100000;
  correct_distortion = false;
  dstd = 2.5;
%   dstd = depth_calib.depth_error_var.^0.5;
  wrange = 0.5:0.01:5.2;
  expected_wstd = zeros(size(wrange));
  for i=1:length(wrange)
    wtrue = wrange(i);

    u = randi([0,639],[1,sample_count]);
    v = randi([0,479],[1,sample_count]);

%     dtrue = depth2disparity(u,v,repmat(wtrue,1,sample_count),depth_calib.dc,depth_calib.dc_alpha,depth_calib.dc_beta);
    dtrue = depth2disparity([],[],repmat(wtrue,1,sample_count),depth_calib.dc,depth_calib.dc_alpha,depth_calib.dc_beta);
    
    dsamples = dtrue + dstd*rand(1,sample_count);
    if(correct_distortion)
      wsamples = disparity2depth(u,v,dsamples,depth_calib.dc,depth_calib.dc_alpha,depth_calib.dc_beta);
    else
      wsamples = disparity2depth([],[],dsamples,depth_calib.dc,depth_calib.dc_alpha,depth_calib.dc_beta);
    end
    
    expected_wstd(i) = std(wtrue-wsamples);
  end
  if(correct_distortion)
    name = ['Distortion corrected, Disp.Std=' num2str(dstd)];
  else
    name = ['Uncorrected, Disp.Std=' num2str(dstd)];
  end
  plot(wrange,expected_wstd,'-k','DisplayName',name);
  legend off
  legend('Location','NorthWest');
  
%   sample_count = 100000;
% %   dstd = 2;
%   dstd = depth_calib.depth_error_var.^0.5;
%   drange = 200:1:950;
%   wrange = disparity2depth([],[],drange,depth_calib.dc,depth_calib.dc_alpha,depth_calib.dc_beta);
%   expected_std = zeros(size(drange));
%   for i=1:length(drange)
%     dtrue = drange(i);
%     wtrue = wrange(i);
%     
%     dsamples = dtrue + dstd*rand(1,sample_count);
%     u = randi([0,639],[1,sample_count]);
%     v = randi([0,479],[1,sample_count]);
%     wsamples = disparity2depth(u,v,dsamples,depth_calib.dc,depth_calib.dc_alpha,depth_calib.dc_beta);
% %     wsamples = disparity2depth([],[],dsamples,depth_calib.dc,depth_calib.dc_alpha,depth_calib.dc_beta);
%     
%     expected_std(i) = std(wtrue-wsamples);
%   end
%   plot(wrange,expected_std,'-k','DisplayName',['Expected Std=' num2str(dstd)]);
%   legend off
%   legend('Location','NorthWest');
%   

  %%
  wrange = 0.5:0.1:5;
  drange = depth2disparity([],[],wrange,depth_calib.dc,depth_calib.dc_alpha,depth_calib.dc_beta);
  coeff = exp(depth_calib.dc_alpha(1)*drange + depth_calib.dc_alpha(2));
  plot(wrange,coeff);