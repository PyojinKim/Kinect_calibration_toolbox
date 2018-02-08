function do_plot_depth_plane()
  global dataset_path dfiles
  global depth_plane_mask depth_plane_poly
  
  if(isempty(depth_plane_mask))
    fprintf('No planes have been selected yet. Nothing to show.\n');
    return;
  end

  icount = length(dfiles);

  %Show thumbnails
  rows = floor(icount^0.5);
  cols = ceil(icount/rows);

  figure(1);
  clf;
  haxes = tight_subplot(rows,cols,0.01,0,0);

  for i=1:icount
    axes(haxes(i));
    if(~isempty(dfiles{i}))
      imd = read_disparity([dataset_path dfiles{i}]);
      [height,width] = size(imd);

      mask_img = cat(3, 1*ones(height,width),0*zeros(height,width),0*ones(height,width));
      
      imshow(visualize_disparity(imd));
      hold on;

      polygon = depth_plane_poly{i}+1;
      if(size(polygon,2) > 0)
        plot(polygon(1,:),polygon(2,:),'ow');
      end
      if(size(polygon,2) > 1)
        plot([polygon(1,:) polygon(1,1)],[polygon(2,:) polygon(2,1)],'-w');
      end
      if(size(polygon,2) > 2)
        h = imshow(mask_img);
        set(h,'AlphaData',0.3*depth_plane_mask{i});
      end
    else
      imshow(0);
    end
  end

end