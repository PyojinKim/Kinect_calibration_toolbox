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

% capture setting for dataset
maxImgNum = 10000;
colorImage_buffer = cell(1,maxImgNum);
depthDistortedImage_buffer = cell(1,maxImgNum);


% Kinect initialization
colorVid = videoinput('kinect',1,'RGB_640x480');
depthVid = videoinput('kinect',2,'Depth_640x480');
colorVid.FramesPerTrigger = 1;
depthVid.FramesPerTrigger = 1;
colorVid.TriggerRepeat = inf;
depthVid.TriggerRepeat = inf;
triggerconfig([colorVid depthVid],'manual');
start([colorVid depthVid]);


% first color and depth image for display
trigger([colorVid depthVid])
[colorFrameData, ~, ~] = getdata(colorVid);
[depthFrameData, ~, ~] = getdata(depthVid);
firstColor = flipdim(colorFrameData,2);
firstDepth = flipdim(depthFrameData,2);


% collect (plot) RGB and depth_distorted image from Kinect
h = figure(101);
subplot(1,2,1);
h1 = imshow(firstColor,[]);
subplot(1,2,2);
h2 = imshow(firstDepth,[]);
set(gcf,'Position',[200 300 1500 500]);
set(h,'KeyPressFcn',{@figure_keypress});
disp('--------------------------------------------------');
disp('Showing real-time data stream...');
fprintf('\t\t\tpress ''x'' to stop at any time\n');
disp('--------------------------------------------------');
for imgIdx = 1:maxImgNum
    
    % trigger both objects
    pause(1/20);
    trigger([colorVid depthVid])
    
    
    % get the original RGB and depth_distorted frames
    [colorFrameData, ~, ~] = getdata(colorVid);
    [depthFrameData, ~, ~] = getdata(depthVid);
    colorImage = flipdim(colorFrameData,2);
    depthDistortedImage = flipdim(depthFrameData,2);
    
    
    % save color and depth_distorted image
    colorImage_buffer{imgIdx} = colorImage;
    depthDistortedImage_buffer{imgIdx} = depthDistortedImage;
    fprintf('recording %010d-th frame...\n', imgIdx);
    
    
    % update RGB and disparity image
    set(h1, 'CData', colorImage);
    set(h2, 'CData', depthDistortedImage);
    
    
    % detect keyboard stroke 'x'
    ret = get(gcf, 'UserData');
    if (ischar(ret))
        set(gcf, 'UserData', []);
        switch (lower(ret))
            case 'x'
                win_kinect_quit(colorVid, depthVid);
                break;
        end
    end
end
colorImage_buffer((imgIdx+1):end) = [];
depthDistortedImage_buffer((imgIdx+1):end) = [];
recordImgNum = imgIdx;


%% post-processing for saving color and depth image

% load Kinect calibration file
addpath('../toolbox');
do_load_calib('../dataset_pjinkim_02/depth_results');
dc = [3.3309495161 -0.0030711016]; % dc = [2.3958 -0.0022];


% save directory for color, depth image
saveDir = '../rgbd_dataset_302_02_office1';
[saveColorDir, saveDepthDir] = generate_dataset_directory(saveDir);


% save color and depth images
h = figure;
for imgIdx = 1:recordImgNum
    
    % read current color and depth_distorted image
    color_image = colorImage_buffer{imgIdx};
    depth_distorted_mm = depthDistortedImage_buffer{imgIdx};
    
    
    % convert depth image to disparity image
    depth_distorted_m = double(depth_distorted_mm) ./ 1000;
    disparity_distorted = dep2imd(depth_distorted_m, dc);
    disparity_distorted(disparity_distorted == 2047) = NaN;
    
    
    % undistort disparity image
    depth_undistorted_m = undistort_disparitymap(disparity_distorted);
    depth_undistorted_mm = uint16(double(depth_undistorted_m) .* 1000);
    depth_image = depth_undistorted_mm;
    
    
    % save color and depth image
    color_image_filename = [saveColorDir sprintf('/%010d.png', imgIdx)];
    depth_image_filename = [saveDepthDir sprintf('/%010d.png', imgIdx)];
    
    imwrite(color_image, color_image_filename);
    imwrite(depth_image, depth_image_filename);
    fprintf('saving %010d-th frame...\n', imgIdx);
    
    
    % show color and depth superposition
    figure(h);
    clf;
    imshow(color_image,[]); hold on;
    h_depth = imshow(depth_image,[]); hold off;
    set(h_depth, 'AlphaData', 0.5);
    drawnow;
end





