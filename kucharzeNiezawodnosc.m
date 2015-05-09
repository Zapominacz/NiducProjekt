%stale
kucharzy = 5;
typowPotraw = 7;
gotowychNaPoczatku = 5;
sredniCzasPrzygotowania = [5.4, 7.4, 4.3, 2.1, 1.9, 9.5, 11.5] * minuta; %powiazane z typowPotraw
gotowychNaRaz = [5, 5, 1, 5, 3, 10, 4]; %ile po czasie bedzie gotowych

%updatowane
tworzonaPotrawa = zeros(1,kucharzy);
gotowychPotraw = ones(1,typowPotraw) * gotowychNaPoczatku;
czasDoNastepnejPotrawy = zeros(1, typowPotraw);

for kucharz = 1:kucharzy
    potrawaTmp = tworzonaPotrawa(1,kucharz);
    if(potrawaTmp > 0)
        if(czasDoNastepnejPotrawy(1, potrawaTmp) == 0)
           gotowychPotraw(1, potrawaTmp) = gotowychPotraw(1, potrawaTmp) + gotowychNaRaz(potrawaTmp);
           tworzonaPotrawa(1,kucharz) = 0;
        end
    end
    if(potrawaTmp == 0)
       [tmp, tworzonaPotrawa(1,kucharz)] = min(gotowychPotraw);
       potrawaTmp = tworzonaPotrawa(1,kucharz);
       czasDoNastepnejPotrawy(1, potrawaTmp) = wblrnd(sredniCzasPrzygotowania(1, potrawaTmp) * doswiadczenie(1, dzien), 1.3222556979404211);
    end
end




