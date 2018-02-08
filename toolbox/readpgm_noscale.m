function [data,max_value]=readpgm_noscale(filename)

%Read header
[fid, msg] = fopen(filename, 'r', 'ieee-be');
if(fid<0)
  error('kinect_toolbox:readpgm_noscale:fileOpen', ...
        [filename ': ' msg]);
end

magic=fscanf(fid,'%c',2);
if(~strcmp(magic,'P5'))
  warning('kinect_toolbox:readpgm_noscale:magic','Magic number in header is not P5.');
end
width=fscanf(fid,'%d',1);
height=fscanf(fid,'%d',1);
max_value=fscanf(fid,'%d',1);

channels = 1;
numvals = width*height*channels;

%Skip final whitespace
fscanf(fid,'%c',1);

%Read data
[data,count]=fread(fid,numvals,'*uint16');
 % The next read should not return any data.  If it does, then there is
 % trailing garbage at the end of the file.  This may indicate a
 % corrupt image (e.g., that each LF has been converted to CR+LF).
 if length(fread(fid, 1, 'char'));
    warning('kinect_toolbox:readpgm_noscale:extraData', ...
            '%s: file contains extra data.',filename);
 end

fclose(fid);

if count < numvals
  warning('kinect_toolbox:readpgm_noscale:unexpectedEOF', ...
          '%s: file ended while reading image data.',filename);
  % Fill in the missing values with zeros.
  data(numvals) = 0;
end

data = reshape(data, [channels width height]);
data = permute(data, [3 2 1]);
