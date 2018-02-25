function [depthmap] = undistort_disparitymap(imd)

global rsize final_calib

if(isempty(final_calib))
    fprintf('Must perform calibration first.\n')
    return
end

if(rsize{1}(1) > 480)
    splat_size = 3;
else
    splat_size = 1;
end
depthmap = compute_rgb_depthmap(imd,final_calib,rsize{1},splat_size);


end
