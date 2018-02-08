%find_images - Searches the given path to find the calibration images.
%Input
%  path [string] the path where images are located
%  rfile_format {1xK}[string] format of the filenames for the K color
%               cameras. Used with sprintf(rfile_format{k},image_number).
%  dfile_format [string] format of the filenames for the depth cameras.  
%               Used with sprintf(dfile_format,image_number).
%Output
%  rfiles {1xK}{1xN}[string] fully qualified filename of the 
%         color images.
%  rsize  {1xK}[1x3] size of the images for each camera
%  dfiles {1xN}[string] fully qualified filename of the 
%         depth images.
function [rfiles,rsize,dfiles]=find_images(path, rfile_format, dfile_format)
  ccount = length(rfile_format); %Color camera count
  rfiles = cell(1,ccount);
  [rfiles{:}] = deal({});
  rsize = cell(1,ccount);
  dfiles = {}; %Only one depth camera supported

  i=0;
  found=true;
  while(found)
    found = false;
    %Look for rgb files
    for k=1:ccount
      filename = sprintf(rfile_format{k},i);
      if(exist([path filename],'file'))
        rfiles{k}{i+1} = filename;
        found=true;
        
        %Store size
        if(isempty(rsize{k}))
          rsize{k} = size(imread([path filename]));
        end
      else
        rfiles{k}{i+1} = [];
      end
    end

    %Look for depth files
    filename = sprintf(dfile_format,i);
    if(exist([path filename],'file'))
      dfiles{i+1} = filename;
      found=true;
    else
      dfiles{i+1} = [];
    end
    i=i+1;
  end
  %Remove empty entry
  for k=1:ccount
    rfiles{k} = rfiles{k}(1:end-1);
  end
  dfiles = dfiles(1:end-1);
end