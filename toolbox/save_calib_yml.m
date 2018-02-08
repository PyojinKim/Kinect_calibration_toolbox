%save_calib_yml  Saves the calibration in YAML format so that it can be loaded from C++.
%  save_calib_yml(filename,calib,rsize)
%
% Kinect calibration toolbox by DHC
function save_calib_yml(filename,calib,rsize)

%It should look like this:
% %YAML:1.0
% R: !!opencv-matrix
%    rows: 3
%    cols: 3
%    dt: f
%    data: [ 1., 0., 0., 0., 1., 0., 0., 0., 1. ]
% T: !!opencv-matrix
%    rows: 3
%    cols: 1
%    dt: f
%    data: [ 0., 0., 0. ]

fid=fopen(filename,'w+');
fprintf(fid,'%%YAML:1.0\n');
for k=1:length(calib.rK)
  write_mat(fid,sprintf('rsize%d',k),rsize{k});
  write_mat(fid,sprintf('rK%d',k),calib.rK{k});
  write_mat(fid,sprintf('rkc%d',k),calib.rkc{k});
end
write_mat(fid,'color_error_var',calib.color_error_var);

write_mat(fid,'dK',calib.dK);
write_mat(fid,'dkc',calib.dkc);

write_mat(fid,'dR',calib.dR);
write_mat(fid,'dt',calib.dt);

write_mat(fid,'dc',calib.dc);
write_mat(fid,'dc_alpha',calib.dc_alpha);
write_mat(fid,'dc_beta',calib.dc_beta);

write_mat(fid,'depth_error_var',calib.depth_error_var);
fclose(fid);
end

function write_mat(fid,name,m)
  fprintf(fid,'%s: !!opencv-matrix\n',name);
  fprintf(fid,'   rows: %d\n',size(m,1));
  fprintf(fid,'   cols: %d\n',size(m,2));
  fprintf(fid,'   dt: f\n');
  fprintf(fid,'   data: [ ');
  
  data = m';
  data = data(:);
  
  max_per_line = 4;
  line_count = ceil(length(data)/max_per_line);
  for l = 1:line_count-1
    base = (l-1)*max_per_line+1;
    if(l > 1)
      fprintf(fid,'      ');
    end
    fprintf(fid,' %f,',data(base:base+max_per_line-1));
    fprintf(fid,'\n');
  end
  l = line_count;
  
  base = (l-1)*max_per_line+1;
  if(l > 1)
    fprintf(fid,'      ');
  end
  if(base < length(data))
    fprintf(fid,' %f,',data(base:end-1));
  end
  
  fprintf(fid,' %f',data(end));
  
  fprintf(fid,' ]\n');
end