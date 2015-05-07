%prawdopodobieñstwo uszkodzenia
poczatekU = 1;
normalneU = 0.2;
koncoweU = 0.9;

dni = 720;
%punkty "prze³omowe"
dotarcie = 100;
starosc = 540;

pbUszkodzen = [linspace(poczatekU, normalneU, dotarcie), linspace(normalneU, normalneU, starosc - dotarcie), linspace(normalneU, koncoweU, dni - starosc)];
X = zeros(1, dni);
Y = zeros(1, dni + 10); %fix dla MA
W = zeros(1, dni);
Z = zeros(1, dni);
%skala czasu - sredni czas zycia
skala = 160;

for i = 1:dni
    Y(1, i+10) =  wblrnd(((1 + normalneU) * skala) * (1- pbUszkodzen(1,i)), 3.4); %wewnatrz rozklad normalny
    %MA
    Z(1,i) = (Y(1, i + 10) + Y(1, i + 9) + Y(1, i + 8) + Y(1, i + 7)+ Y(1, i +6) + Y(1, i +5) + Y(1, i +4) + Y(1, i +3) + Y(1, i +2) + Y(1, i +1))/10;
end
figure(2);
stem(Y);
figure(1);
plot(Z);
%h1 = wblcdf(t,dni,0.7);%wblpdf(t,3,0.7) ./ (1-wblcdf(t,3,0.7));
%h2 = %wblpdf(t,11,2.5) ./ (1-wblcdf(t,11,2.5));
%h3 = wblcdf(t,dni,1);%wblpdf(t,dni,1) ./ (1-wblcdf(t,dni,1));
%plot(t,h1,t, h3);

