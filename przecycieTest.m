t = 0:0.1:20;
A = 12;
C = 5*3600;
h1 = wblcdf(t,A,0.7);%wblpdf(t,3,0.7) ./ (1-wblcdf(t,3,0.7));
%h2 = %wblpdf(t,11,2.5) ./ (1-wblcdf(t,11,2.5));
h3 = wblcdf(t,A,1);%wblpdf(t,A,1) ./ (1-wblcdf(t,A,1));
plot(t,h1,t, h3);

