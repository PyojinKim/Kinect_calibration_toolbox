function write_yml_rt(filename,R,T)

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
fprintf(fid,'R: !!opencv-matrix\n');
fprintf(fid,'   rows: 3\n');
fprintf(fid,'   cols: 3\n');
fprintf(fid,'   dt: f\n');
fprintf(fid,'   data: [ ');
fprintf(fid,'%f',R(1));
fprintf(fid,',%f',R(2:end));
fprintf(fid,' ]\n');
fprintf(fid,'T: !!opencv-matrix\n');
fprintf(fid,'   rows: 3\n');
fprintf(fid,'   cols: 1\n');
fprintf(fid,'   dt: f\n');
fprintf(fid,'   data: [ ');
fprintf(fid,'%f',T(1));
fprintf(fid,',%f',T(2:end));
fprintf(fid,' ]\n');
fclose(fid);