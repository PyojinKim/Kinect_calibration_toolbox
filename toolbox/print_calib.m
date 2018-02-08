function print_calib(calib,calib_error)
if(nargin < 2)
  calib_error = [];
end

for k=1:length(calib.rK)
  print_calib_color(k,calib, calib_error);
end
print_calib_depth(calib, calib_error);
if(~isempty(calib_error))
  fprintf('Note: error is 3 times the standard deviation.\n');
end
