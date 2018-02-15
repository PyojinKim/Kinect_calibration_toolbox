

% get the acquired frames and metadata.
[rgb_img, ts_color, metaData_Color] = getdata(vid1);
[dep_img, ts_depth, metaData_Depth] = getdata(vid2);
rgb_img = flipdim(rgb_img,2);
dep_img = flipdim(dep_img,2);



figure;
imshow(dep_img,[])


d_img = double(dep_img)./1000; % depth in m


imd  = dep2imd(d_img, dc);


figure;
imshow(d_img,[]);


cam.K = eye(3);
cam.K(1,1) = 525;
cam.K(2,2) = 525;
cam.K(1,3) = 319.5;
cam.K(2,3) = 239.5;


imageHeight = size(d_img,1);
imageWidth = size(d_img,2);

x3DptsCam = zeros(4,imageHeight*imageWidth);
ptsCount = 0;
for v = 1:imageHeight
    for u = 1:imageWidth
        
        if (d_img(v,u) >= 0.4 && d_img(v,u) <= 8)
            ptsCount = ptsCount + 1;
            
            depth = d_img(v,u);
            
            x3DptsCam(1,ptsCount) = ((u - cam.K(1,3)) / cam.K(1,1)) * depth;
            x3DptsCam(2,ptsCount) = ((v - cam.K(2,3)) / cam.K(2,2)) * depth;
            x3DptsCam(3,ptsCount) = depth;
            x3DptsCam(4,ptsCount) = 1;
        end
    end
end
x3DptsCam(:,(ptsCount+1):end) = [];
x3DptsCam = x3DptsCam(:,1:100:end);
numPts = size(x3DptsCam,2);


% plot environment's 3D points in inertial (global) frame
figure;
scatter3(x3DptsCam(1,:).', x3DptsCam(2,:).', x3DptsCam(3,:).', 100*ones(numPts,1).','.'); grid on;
axis equal; view(-36,30); hold off;
xlabel('X [m]');
ylabel('Y [m]');
zlabel('Z [m]');


%%

% depth to disparity relationship
dc = [3.3309495161 -0.0030711016]; % dc = [2.3958 -0.0022];
depth = 0.4:0.01:8.0;
disparity = (1./(depth*dc(2))) - (dc(1)/dc(2));

figure;
plot(depth,disparity); grid on;
xlabel('depth'); ylabel('disparity');


% disparity to depth relationship
dc = [3.3309495161 -0.0030711016]; % dc = [2.3958 -0.0022];
disparity = 380:1:1010;
depth = 1./(dc(2)*disparity + dc(1));

figure;
plot(disparity,depth); grid on;
xlabel('disparity'); ylabel('depth');




imd = read_disparity('../pjinkim_kinect_calibration_01/0000-d.pgm');

imd = read_disparity('../smallset/0003-d.pgm');

imd = read_disparity('../data/0006-d.pgm');




temp = uint16(imread(filename));

%Set invalid depths to NaN
imd = double(imd);
tempfordebug(tempfordebug==2047) = nan;


tempfordebug(isnan(tempfordebug)) = 0;
imd(isnan(imd)) = 0;

tempfordebug == imd



figure;
imshow(disparityImage,[]);



figure;
imshow(imd,[]);














