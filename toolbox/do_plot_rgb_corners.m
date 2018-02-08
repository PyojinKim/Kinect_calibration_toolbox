function do_plot_rgb_corners
  global rfiles
  global rgb_grid_p
  
  if(isempty(rgb_grid_p))
    fprintf('No corners have been selected yet. Nothing to show.\n');
    return;
  end

  ccount = length(rfiles);
  icount = length(rfiles{1});
  
  %Show thumbnails
  rows = floor(icount^0.5);
  cols = ceil(icount/rows);
  for k=1:ccount
    figure(k);
    clf;
    haxes = tight_subplot(rows,cols,0.01,0,0);

    for i=1:icount
      axes(haxes(i));
      if(~isempty(rfiles{k}{i}))
        plot_rgb_corners(k,i);
      else
        imshow(0);
      end
    end
  end

end