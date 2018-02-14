function [colorImage, disparityImage] = capture_kinect(option)


% invoked by 'record' to detect exit command
global record_exit


% Kinect initialization
if (option.highres)
    colorVid = videoinput('kinect',1,'RGB_1280x960');
else
    colorVid = videoinput('kinect',1,'RGB_640x480');
end
depthVid = videoinput('kinect',2,'Depth_640x480');
colorVid.FramesPerTrigger = 1;
depthVid.FramesPerTrigger = 1;
colorVid.TriggerRepeat = inf;
depthVid.TriggerRepeat = inf;
triggerconfig([colorVid depthVid],'manual');
start([colorVid depthVid]);


% other parameters
show_depth = 0;
dc = [3.3309495161 -0.0030711016]; % dc = [2.3958 -0.0022];


% plot RGB and depth image from Kinect
h = figure(101);
set(gcf,'Position',[200 300 1500 500]);
set(h,'KeyPressFcn',{@figure_keypress});
disp('--------------------------------------------------');
disp('Showing real-time data stream...');
fprintf('\t\t\tpress ''d'' to switch between disparity/depth\n');
fprintf('\t\t\tpress ''space'' to capture data\n');
fprintf('\t\t\tpress ''x'' to stop at any time\n');
while (true)
    
    % trigger both objects
    trigger([colorVid depthVid])
    
    
    % get the acquired frames and metadata
    [colorFrameData, ~, ~] = getdata(colorVid);
    [depthFrameData, ~, ~] = getdata(depthVid);
    colorImage = flipdim(colorFrameData,2);
    depthImage = flipdim(depthFrameData,2);
    
    
    % convert depth image to disparity image
    depthImage = double(depthImage) ./ 1000;
    disparityImage = dep2imd(depthImage, dc);
    
    
    % plot RGB and depth (disparity) image
    figure(h);
    subplot(1,2,1);
    imshow(colorImage,[]);
    title('Color');
    subplot(1,2,2);
    if (show_depth)
        imshow(depthImage,[]);
        title('Depth');
    else
        imshow(im2uint8(mat2gray(disparityImage)),[]);
        title('Disparity');
    end
    set(gcf,'colormap',jet);
    drawnow;
    
    
    % detect keyboard stroke
    ret = get(gcf, 'UserData');
    if (ischar(ret))
        set(gcf, 'UserData', []);
        switch (lower(ret))
            case {27, 'x'}
                win_kinect_quit(colorVid, depthVid);
                if (~isempty(record_exit))
                    record_exit = 1;
                end
                break;
            case 32 % space
                win_kinect_quit(colorVid, depthVid);
                if (~isempty(record_exit))
                    record_exit = 0;
                end
                break;
            case 'd'
                show_depth = (~show_depth);
        end
    end
end

end

