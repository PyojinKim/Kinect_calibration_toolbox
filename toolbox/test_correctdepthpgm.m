for i = 0:12
  filename = ['c:\datasets\temp\d-' num2str(i,'%.4d') '.pgm'];
  imd = imread(filename);
  imd=swapbytes(imd);
  imwrite(imd,filename,'MaxValue',2047);
end