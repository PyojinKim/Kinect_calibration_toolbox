% function plot_distortion_distribution
%   data = load('data_distortion.mat');
  
%   min_y = -1;
%   max_y = 5;
%   y_steps = 500;
%   
%   min_x = 400;
%   max_x = 1000;
%   x_steps = 500;
%   
%   im = zeros(y_steps+1,x_steps+1);
%   m = zeros(1,x_steps+1);
%   count = zeros(1,x_steps+1);
%   
%   x = disp;
%   y = (disp_k-disp)./dc_beta(points_ind);
% 
%   u = round((x-min_x)/(max_x-min_x)*x_steps) + 1;
%   v = round((y-min_y)/(max_y-min_y)*y_steps) + 1;
% 
%   for i=1:length(y)
%     if(u(i) < 1 || u(i) > x_steps+1)
%       continue;
%     end
% %     count(u(i)) = count(u(i))+1;
% %     m(u(i)) = m(u(i)) + v(i);
%     if(v(i) < 1 || v(i) > y_steps+1)
%       continue;
%     end
%     im(v(i),u(i)) = im(v(i),u(i))+1;
%   end
% %   m = m./count;
% 
% %   for i=1:size(im,2)
% %     valid = u==i;
% %     vv = v(valid);
% %     count(i) = length(vv);
% %     m(i) = median(vv);
% %   end
% % 
% %   mi = round(m);
% %   for i=1:length(m)
% %     if(count(i) < 100)
% %       continue
% %     end
% %     if(mi(i) < 1 || mi(i) > y_steps+1)
% %       continue;
% %     end
% %     
% %     im(mi(i),i) = 1e4;
% %   end
%   
%   x = min_x:max_x;
%   y = exp(dc_alpha(1)-dc_alpha(2)*x);    
%   u = round((x-min_x)/(max_x-min_x)*x_steps) + 1;
%   v = round((y-min_y)/(max_y-min_y)*y_steps) + 1;
%   for i=1:length(u)
%     im(v(i),u(i)) = 1e4;
%   end
%   
%   imtool(im,[]);


%Get means
  max_x = 1000;
  xstep = 1;
  xrange = 350:xstep:max_x;
  count = zeros(1,length(xrange));
  m = zeros(1,length(xrange));
  s = zeros(1,length(xrange));
  
  for a = 1:length(xrange)
    x = xrange(a);
%     i = disp>=(x-xstep) & disp < x;
    i = disp == x;
%     if(sum(i) > 10000)
    count(a) = sum(i);

    di = disp(i);
    dk = disp_k(i);
    pi = points_ind(i);
    y = (dk-di)./dc_beta(pi);

      m(a) = median(y);
      s(a) = median(abs(y-m(a)));
%     end
  end
  
  %%
  figure(1);
  clf;
  valid = count >100;
%   plot(xrange(valid)-xstep/2,m(valid),'.');
  plot(xrange(valid),m(valid),'-');
%   h=errorbar(xrange(valid),m(valid),s(valid),'.');
%   set(h,'DisplayName','Normalized error $\frac{d-d_k}{D_\delta(u,v)}$ (kdu)','interpreter','latex');
  
  xref = 300:1000;
  yref = exp(dc_alpha(1)-dc_alpha(2)*xref);
  hold on
  plot(xref,yref,'r--')
  
%   xlabel('Measured disparity \textit{d} (kdu)','interpreter','latex');
  xlabel('Measured disparity (kdu)');
%   h=legend({'Normalized error','Fitted curve: $exp(\alpha_0 - \alpha_1d)$'})
  h=legend({'Median of normalized error','Fitted exponential'})
%   subh=findobj(get(h,'Children'),'Interpreter','tex');
%   set(subh,'Interpreter','latex');
%   ylabel(,'interpreter','latex');
% end