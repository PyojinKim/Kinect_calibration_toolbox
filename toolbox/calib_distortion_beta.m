function [dc_beta]=calib_distortion_beta(calib, Rext, text, path, dfiles, depth_plane_mask)
  width = 640;
  height = 480;
  
  %Remove distortion correction from calib
  dc_alpha = calib.dc_alpha;
  dc_beta = calib.dc_beta;
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
    [points_i,disparity_i] = get_depth_samples(path,dfiles{i},depth_plane_mask{i});
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
  
  %Optimize betas
  fprintf('Minimizing dc_beta...');
  counter=0;
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

    A = exp(dc_alpha(1)-dc_alpha(2)*di);
    %A = [ones(length(d0),1)*alpha(1) + d0*alpha(2) + d0.^2*alpha(3)];
    b = (dki-di);
    dc_beta(ind) = A\b;

    if((i-counter)/(length(points_ind)) > 0.1)
      fprintf('.');
      counter=i;
    end
  end    

  if(any( abs(dc_beta(:)) > 40) )
    warning('calib_distortion:beta','Calculated beta seems to be too high, possibly unstable.');
  end
end