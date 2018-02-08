function batman()
  ezplot(@batman_values,10*[-1 1 -1 1]);
end

function res=batman_values(x,y)
m= 1e100;

a = abs(x)-3;
valid = (abs(a)./a) >= 0;
b = (x./7).^2;

a = y+3.*33^0.5./7;
valid = valid & (abs(a)./a) >= 0;
c = (y/3).^2;

r = b+c-1;
r = r.*valid + ~valid*m;

a = 1-(abs(abs(x)-2)-1).^2;
valid = a>=0;
s = abs(x./2) - (3*33^0.5-7)/112*x.^2 - 3 + (a).^0.5 - y;
s = s.*valid + ~valid*m;

a = abs((abs(x)-1).*(abs(x)-0.75))./((1-abs(x)).*(abs(x)-0.75));
valid = a>=0;
t = 9.*a.^0.5-8*abs(x)-y;
t = t.*valid + ~valid*m;

a=abs((abs(x)-0.75).*(abs(x)-0.5)) ./ ((0.75-abs(x)).*(abs(x)-0.5));
valid = a>=0;
u=3*abs(x)+0.75*a.^0.5-y;
u = u.*valid + ~valid*m;

a = abs((x-0.5).*(x+0.5)) ./ ((0.5-x).*(0.5+x));
valid = a>=0;
v = 2.25*a.^0.5-y;
v = v.*valid + ~valid*m;

a=abs(abs(x)-1)./(abs(x)-1);
b = 4-(abs(x)-1).^2;
valid = a>=0 & b>=0;
w = 6*10^0.5/7 + (1.5-0.5*abs(x)).*a.^0.5-6*10^0.5/14*b.^0.5-y;
w = w.*valid + ~valid*m;

res = r.*s.*t.*u.*v.*w;
res = r.*s;
end