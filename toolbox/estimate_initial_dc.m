% Kinect calibration toolbox by DHC
function dc=estimate_initial_dc(path,dfiles,depth_corner_p,depth_corner_x,depth_plane_mask,R0,t0)

width = 640;
height = 480;

%Images with valid plane corners
valid = cellfun(@(x) ~isempty(x),depth_corner_p);
valid_idx = find(valid);
dcount = sum(valid);

%Depth parameters
A = zeros(0,2);
B = zeros(0,1);
eq_idx=1;
for ii=1:dcount
  i = valid_idx(ii);
  imd = read_disparity([path,dfiles{i}]);
  
  %Get mask
  for k=1:4
    x = round(depth_corner_p{i}(1,k));
    if(x<0 || x>width-1); continue; end
    y = round(depth_corner_p{i}(2,k));
    if(y<0 || y>height-1); continue; end
    
    corner_disp=find_nearest(imd,depth_plane_mask{i},x+1,y+1);

    %Calculate depth
    points_image = R0{ii}*[depth_corner_x(:,k); 0] + t0{ii};
    depth = abs(points_image(3,:));

    A(eq_idx, :) = [1,corner_disp];
    B(eq_idx,1) = 1./depth;
    eq_idx=eq_idx+1;
  end
end
depth_coeff = A\B;
dc = [depth_coeff(1),depth_coeff(2)];