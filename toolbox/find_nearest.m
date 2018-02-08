%Function from Bouguet's camera calibration toolbox.
function [value,x,y]=find_nearest(im,mask,x0,y0)

if(mask(y0,x0))
  value = im(y0,x0);
  x=x0;
  y=y0;
  return;
end

width = size(im,2);
height = size(im,1);

for i=1:100
  for xi=x0-i:x0+i
    if(xi<1 || xi>width)
      continue;
    end
    yi = y0-i;
    if(yi>=1 && yi<=height && mask(yi,xi))
      value = im(yi,xi);
      x = xi;
      y = yi;
      return;
    end
    yi = y0+i;
    if(yi>=1 && yi<=height && mask(yi,xi))
      value = im(yi,xi);
      x = xi;
      y = yi;
      return;
    end
  end
  for yi=y0-i+1:y0+i-1
    if(yi<1 || yi>height)
      continue;
    end
    xi=x0-i;
    if(xi>=1 && xi<=width && mask(yi,xi))
      value = im(yi,xi);
      x = xi;
      y = yi;
      return;
    end
    xi=x0+i;
    if(xi>=1 && xi<=width && mask(yi,xi))
      value = im(yi,xi);
      x = xi;
      y = yi;
      return;
    end
  end
end

