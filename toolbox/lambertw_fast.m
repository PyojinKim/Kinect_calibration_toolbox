function res=lambertw_fast(x)
  global lambertw_lut
  lw_x_min = -0.1;
  lw_x_max = 0.15;
  lw_x_step = 0.00001;
  
  if(isempty(lambertw_lut))
    fprintf('[calculating lambertw LUT...');
    lambertw_lut = lambertw(lw_x_min:lw_x_step:lw_x_max);
    fprintf('done]');
  end
  

  xi = round( (x-lw_x_min)/lw_x_step ) + 1;
  use_manual = xi < 1 | xi > length(lambertw_lut);
  use_nan = isnan(xi);
  use_lut = ~use_manual & ~use_nan;
  
  res = zeros(size(x));
  res(use_lut) = lambertw_lut(xi(use_lut));
  if(any(use_nan))
    res(use_nan) = nan;
  end
  if(any(use_manual))
    fprintf('[%d outside lambertw_lut range',sum(use_manual));
%     res(use_manual) = lambertw(x(use_manual));
    res(use_manual) = 0;
    fprintf(',done]');
  end
  
%   max_xi = max(xi);
%   if(max_xi > length(lambertw_lut))
%     fprintf('[expanding lambertw LUT (%d)...',max_vi);
%     
%     lut_last = length(lambertw_lut);    
%     range = ((lut_last+1:max_vi)-1)*lw_x_step + lw_x_min;
%     lambertw_lut(lut_last+1:max_vi) = lambertw(range);
% 
%     fprintf('done]');
%   end
  