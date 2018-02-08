function res=read_yaml(filename)
  res=struct();
  fid = fopen(filename);
  
  while(~feof(fid))
    s=fgetl(fid);
    
    %Discard comments
    pos = find(s=='%',1,'first');
    if(~isempty(pos))
      continue;
    end
    
    %Search for var declaration
    tokens=textscan(s,'%s %s','Delimiter',':');
    field_name = strtrim(tokens{1}{1});
    field_type = strtrim(tokens{2}{1});
    if(isequal(field_type(1:2),'!!'))
      if(strcmp(field_type,'!!opencv-matrix'))
        %OpenCV matrix
        s = fgetl(fid);
        tokens=textscan(s,'%s %d','Delimiter',':');
        rows = tokens{2};

        s = fgetl(fid);
        tokens=textscan(s,'%s %d','Delimiter',':');
        cols = tokens{2};

        s = fgetl(fid);
        tokens=textscan(s,'%s %s','Delimiter',':');
        field_elem_type = tokens{2}{1};
        field_elem_type = strrep(field_elem_type,'"','');
        if(field_elem_type(1) >= '1' && field_elem_type(1) <= '9')
          channels = str2num(field_elem_type(1));
        else
          channels = 1;
        end

        %Data
        fscanf(fid,'   data: [');
        data=fscanf(fid,'%f,%f,%f,',[cols*rows*channels])';

        if(channels == 1)
          a = reshape(data,[cols,rows]);
          res.(field_name) = a';
        elseif(channels==3)
          a = reshape(data,[channels,cols,rows]);
          res.(field_name) = cat(3,squeeze(a(1,:,:))',squeeze(a(2,:,:))',squeeze(a(3,:,:))');
        end

        s = fgetl(fid);
      end
    else
      value = str2num(field_type);
      if(isempty(value))
        value = field_type;
      end
      res.(field_name) = value;
    end
  end
  
  fclose(fid);
end