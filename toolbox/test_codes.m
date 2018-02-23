figure;
imshow(im,[]);

figure;
imshow(depthmap,[]);


% assign current parameters
[nrows,ncols] = size(depthmap);
cam.K = final_calib.rK{1};


% recover 3D point cloud and RGB information
x3DptsCam = zeros(3,nrows*ncols);
x3DptsColor = zeros(3,nrows*ncols);
ptsCount = 0;
for v = 1:nrows
    for u = 1:ncols
        
        if (depthmap(v,u) >= 0.5 && depthmap(v,u) <= 8)
            ptsCount = ptsCount + 1;
            
            depth = depthmap(v,u);
            
            x3DptsCam(1,ptsCount) = ((u - cam.K(1,3)) / cam.K(1,1)) * depth;
            x3DptsCam(2,ptsCount) = ((v - cam.K(2,3)) / cam.K(2,2)) * depth;
            x3DptsCam(3,ptsCount) = depth;
            
            x3DptsColor(1,ptsCount) = double(im(v,u,1)) / 255;
            x3DptsColor(2,ptsCount) = double(im(v,u,2)) / 255;
            x3DptsColor(3,ptsCount) = double(im(v,u,3)) / 255;
        end
    end
end
x3DptsCam(:,(ptsCount+1):end) = [];
x3DptsColor(:,(ptsCount+1):end) = [];
x3DptsCam = x3DptsCam(:,1:50:end);
x3DptsColor = x3DptsColor(:,1:50:end);
numPts = size(x3DptsCam,2);


% plot environment's 3D points in inertial (global) frame
figure;
scatter3(x3DptsCam(1,:).', x3DptsCam(2,:).', x3DptsCam(3,:).', 100*ones(numPts,1), x3DptsColor.','.'); grid on;
axis equal; view(-36,30); hold off;
xlabel('X [m]');
ylabel('Y [m]');
zlabel('Z [m]');








