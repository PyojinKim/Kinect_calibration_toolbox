function [alpha,im_beta]=calib_distortion(calib, Rext, text, dataset_path, dfiles, depth_plane_mask)
  width = 640;
  height = 480;
  
  %Remove distortion correction from calib
  alpha0 = calib.dc_alpha;
  beta0 = calib.dc_beta;
  calib.dc_alpha = [];
  calib.dc_beta = [];
  
  fprintf('Gathering samples...');   
  
  %Get errors
  points_ind = [];
  disp = [];
  disp_k = [];
  %Relation between disp and disp_k:
  %  disp_k = disp + beta*exp(a1-a2*disp)
  for i=find(~cellfun(@isempty,dfiles))
    [points_i,disparity_i] = get_depth_samples(dataset_path,dfiles{i},depth_plane_mask{i});
    points_ind_i = sub2ind([height,width],points_i(2,:)+1,points_i(1,:)+1);

    ref_w = get_expected_plane_depth(points_i,calib,Rext{i},text{i});
    disparity_k_i = depth2disparity([],[],ref_w,calib);

    if(any(disparity_k_i < 0))
      error('calib_distortion:samples','Reference depth is negative.');
    end
    
    points_ind = [points_ind, points_ind_i];
    disp = [disp,disparity_i];
    disp_k = [disp_k, disparity_k_i];
  end
  
  %Sort for beta optimization
  [points_ind,i]=sort(points_ind);
  disp = disp(i);
  disp_k = disp_k(i);
  
  fprintf('Done.\n');
  
  fprintf('Minimizing...\n');

  %Initial beta value
  if(isempty(alpha0) || all(alpha0==1) || isempty(beta0) || all(beta0(:)==0))
    im_beta = ones(height,width);

    A = ones(length(disp),2);
    A(:,2) = -disp;
    b = log((disp_k - disp)'./im_beta(points_ind)');

    valid_alpha = ~any(isnan(A),2) & ~isinf(b) & ~isnan(b) & imag(b)==0;
    A = A(valid_alpha,:);
    b = b(valid_alpha);
    alpha = A\b;
  else
    im_beta = beta0;
    alpha = alpha0;
  end
  
  cost = cost_alpha(alpha,im_beta,points_ind,disp,disp_k);
  resnorm0 = sum(cost.^2);
  fprintf('Initial residual norm=%e\n',resnorm0);
  
  quit = false;
  iter=0;
  
  minimization_options=optimset('LargeScale','off',...
    'Algorithm','levenberg-marquardt',...
    'Display','none',...
    'TolFun',1e-6,...
    'TolX',1e-9,...
    'MaxFunEvals',20000,...
    'MaxIter',1000);
    %'OutputFcn', @my_output_fcn, ...
  %Too much for alpha estimation!
  maxcount = 700000;
  if(length(disp) > maxcount)
    ai = randperm(length(disp));
    ai = ai(1:maxcount);
  else
    ai = true(size(points_ind));
  end
  while(~quit)
    alpha0 = alpha;
    im_beta0 = im_beta;
    iter=iter+1;
    
    %Optimize betas
    fprintf('Optimizing beta...');
    counter=0;
    %A = exp(alpha*(1:icount)');
    i=1;
    while(i<=length(points_ind))
      ind = points_ind(i);
      j=i;
      while(j<=length(points_ind) && points_ind(j)==ind)
        j=j+1;
      end
      
      di = disp(i:j-1)';
      dki = disp_k(i:j-1)';
      i=j;
      
      A = exp(alpha(1)-alpha(2)*di);
      %A = [ones(length(d0),1)*alpha(1) + d0*alpha(2) + d0.^2*alpha(3)];
      b = (dki-di);
      im_beta(ind) = A\b;

      if(abs(im_beta(ind)) > 40)
        warning('calib_distortion:beta','Calculated beta seems to be too high, possibly unstable.');
      end

      if((i-counter)/(length(points_ind)) > 0.1)
        fprintf('.');
        counter=i;
      end
    end
    
    cost = cost_alpha(alpha,im_beta,points_ind,disp,disp_k);
    resnorm = sum(cost.^2);
    fprintf('done. Residual norm=%e\n',resnorm);

    %Optimize alpha
    fprintf('Optimizing alpha (iter #%d)...',iter);


    alpha = lsqnonlin(@(x) cost_alpha(x,im_beta,points_ind(ai),disp(ai),disp_k(ai)),alpha0,[],[],minimization_options);
    
    %Residual must be calculated again because only partial data is used
    %for alpha minimization
    cost = cost_alpha(alpha,im_beta,points_ind,disp,disp_k);
    resnorm = sum(cost.^2);
    fprintf('done. Residual norm=%e\n',resnorm);
    
    if(resnorm>resnorm0)
      alpha = alpha0;
      im_beta = im_beta0;
      fprintf('Residual increased, exiting.\n');
      quit=true;
      break;
    elseif((resnorm0-resnorm) < 0.01*resnorm0)
      fprintf('Residual change is too small, exiting.\n');
      quit = true;
      break;
    end
    resnorm0 = resnorm;
  end
end

function cost=cost_alpha(alpha,im_beta,points_ind,disp,disp_k)
  %icount = size(imd,3);
  %ind = sub2ind([480,640],points(2,:),points(1,:));
  cost = disp_k - disp - im_beta(points_ind) .* exp(alpha(1)-alpha(2)*disp);
%   cost = [];
%   for i=1:icount
%     %im_fix = im_beta .* (alpha(1)+alpha(2)*imd(:,:,i)+alpha(3)*imd(:,:,i).^2);
%     %im_fix = im_beta .* polyval(alpha,imd(:,:,i));
%     im_fix = im_beta .* exp(polyval(alpha,imd(:,:,i)));
%     c = im_error(:,:,i)-im_fix;
%     
%     cost = [cost; c(:)];
%   end
%   
%   cost = cost(~isnan(cost));
end

function res=my_output_fcn(cost,optimValues,state)
  fprintf('.');
  res=false;
end