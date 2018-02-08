function plot_rgb_reprojection(calib, camera_k, image_i)
global dataset_path rfiles
global rgb_grid_p rgb_grid_x

k = camera_k;
i = image_i;

im = imread([dataset_path rfiles{k}{i}]);

%figure();
figure(gcf());
clf;
imshow(im,'InitialMagnification','fit');
hold on;

plot(rgb_grid_p{k}{i}(1,:)+1,rgb_grid_p{k}{i}(2,:)+1,'ob','DisplayName','Selected points');


R = calib.rR{k}'*calib.Rext{i};
t = calib.rR{k}'*(calib.text{i} - calib.rt{k});

x = project_points_k(rgb_grid_x{k}{i},calib.rK{k},calib.rkc{k},R,t);
plot(x(1,:)+1,x(2,:)+1,'+r','DisplayName','Reprojection');

title(sprintf('Reprojection error, camera #%d, image %d. Error std=%f\n',camera_k,image_i,std(x(:) - rgb_grid_p{k}{i}(:))));
xlim([min(x(1,:))-10, max(x(1,:))+10]);
ylim([min(x(2,:))-10, max(x(2,:))+10])
legend('show','Location','SouthOutside');