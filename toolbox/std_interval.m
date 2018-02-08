function [sigma,sigma_lower,sigma_upper]=std_interval(samples,confidence)
  sigma = std(samples);
  N = length(samples);
  sigma_lower = sigma-((N-1)./chi2inv(confidence,N-1)).^0.5.*sigma;
  sigma_upper = ((N-1)./chi2inv(1-confidence,N-1)).^0.5.*sigma-sigma;
end