clc;
close all;
clear variables; %clear classes;
rand('state',0); % rand('state',sum(100*clock));
dbstop if error;


%% check Kinect connection

info = imaqhwinfo('kinect');

% print color camera information
info.DeviceInfo(1)


% print depth camera information
info.DeviceInfo(2)


%% main script

% save directory for color, disparity image
saveDir = '../pjinkim_kinect_calibration_01';
if (~exist(saveDir, 'dir'))
    mkdir(saveDir);
end


% capturing parameters
option.highres = false;
global record_exit
record_exit = false;
imgIdx = 0;


% capture RGB and disparity image from Kinect
h = figure(101);
set(gcf,'Position',[200 300 1500 500]);
while (true)
    
    % obtain color and disparity image
    [colorImage, disparityImage] = capture_kinect(option);
    if (record_exit)
        fprintf('Recording done!\n');
        break;
    end
    
    
    % remap disparity data
    disparityImage = remap_disparity(uint16(disparityImage), 2047);
    
    
    % save color and disparity image
    colorImage_filename = [saveDir sprintf('/%04d-c1.jpg', imgIdx)];
    disparityImage_filename = [saveDir sprintf('/%04d-d.pgm', imgIdx)];
    
    imwrite(colorImage, colorImage_filename, 'jpg');
    imwrite(disparityImage, disparityImage_filename, 'pgm', 'MaxValue', 2047);
    fprintf('recording %04d-th frame...\n', imgIdx);
    
    
    % for next iteration
    imgIdx = imgIdx + 1;
end



