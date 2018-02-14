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


%% extract RGB and depth image

% basic setup for Kinect camera
colorVid = videoinput('kinect',1,'RGB_640x480');
depthVid = videoinput('kinect',2,'Depth_640x480');
srcColor = getselectedsource(colorVid);
srcDepth = getselectedsource(depthVid);


% change Kinect trigger setting for acquiring simultaneously
colorVid.FramesPerTrigger = 1;
depthVid.FramesPerTrigger = 1;
colorVid.TriggerRepeat = inf;
depthVid.TriggerRepeat = inf;
triggerconfig([colorVid depthVid],'manual');
start([colorVid depthVid]);


% plot RGB and depth image from Kinect
h = figure;
set(gcf,'Position',[200 300 1500 500]);
set(h,'KeyPressFcn',{@figure_keypress});
while (true)
    
    % trigger both objects
    trigger([colorVid depthVid])
    
    
    % get the acquired frames and metadata
    [colorFrameData, colorTimeData, colorMetaData] = getdata(colorVid);
    [depthFrameData, depthTimeData, depthMetaData] = getdata(depthVid);
    colorFrameData = flipdim(colorFrameData,2);
    depthFrameData = flipdim(depthFrameData,2);
    
    
    % plot RGB and depth image
    subplot(1,2,1);
    imshow(colorFrameData,[]);
    subplot(1,2,2);
    imshow(depthFrameData,[]);
    
    
    % detect keyboard stroke 'x'
    ret = get(gcf, 'UserData');
    if (ischar(ret))
        set(gcf, 'UserData', []);
        switch (lower(ret))
            case 32
                win_kinect_quit(colorVid, depthVid);
                break;
            case 'x'
                win_kinect_quit(colorVid, depthVid);
                break;
        end
    end
end


