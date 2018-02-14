function imd  = dep2imd(dep, dc)
% global glb_min glb_max
% Transoform from disparity to depth
nan_value = 0;
dep = double(dep);

dep(dep == nan_value) = NaN;
imd = (1./(dep*dc(2))) - (dc(1)/dc(2)); % transform to disparity
imd = round(imd);

% % change nan and max value according to your disparity content
% max_value = max(imd(:)); min_value = min(imd(:));
% glb_min = min([glb_min min_value]);
% glb_max = max([glb_max max_value]);
% clc
% fprintf('min disparity value: %.4f\n', glb_min);
% fprintf('max disparity value: %.4f\n', glb_max);

% Normalize
% -- note that we can't do "normalize to [0,1] with min and max of current imd"
% -- cause after conversion, the disparity range is fixed and specified to
% -- corresponding distance
% lower_bound = (1./(0.5*dc(2))) - (dc(1)/dc(2)); %678.0987;
% higher_bound = (1./(6.0*dc(2))) - (dc(1)/dc(2)); %1002.6947;
% imd = (imd+1-lower_bound)/(higher_bound-lower_bound+1);
% scale vector into [0, 2047)
% imd = imd * 2047;

imd = uint16(imd);
imd = double(imd);

%Set invalid depths to nan for which we do not want to include such points in masks
imd(imd==nan_value) = 2047; % to be in accordance with Herrera's pgm file content

% t_dep = 1./(dc(2)*double(imd) + dc(1));

end

