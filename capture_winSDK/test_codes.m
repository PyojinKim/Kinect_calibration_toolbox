

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
