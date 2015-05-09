%stale czasu
minuta = 60;
godzina = 60 * minuta;
dzien = 24 * godzina;
miesiac = 30 * dzien;

%switch czasowy dla ruchu
rushHours = rushHours .* godzina;
endRushHours = endRushHours .* godzina;
emptyHours = emptyHours .* godzina;
endEmptyHours = endEmptyHours .* godzina;

%klienci
nieobsluzeniKlienci = 0;
calkowitaLiczbaKlientow = 0;
iloscKlientow = 0;
%licznik ludzi znudzonych staniem
klientPoszedl = 0;

%przygotowywanie potraw
czasPrzystosowaniaKucharzy = 1 * miesiac;
typowProduktow = 8;
gotowychNaPoczatku = 5;
sredniCzasPrzygotowania = [5.4, 7.4, 4.3, 2.1, 1.9, 9.5, 11.5, 7] * minuta; %powiazane z typowProduktow
gotowychNaRaz = [5, 5, 1, 5, 3, 10, 4, 3]; %ile po czasie bedzie gotowych
doswiadczenieKucharzy = [linspace(2,1,czasPrzystosowaniaKucharzy), ones(1, iloscDniSymulacji - czasPrzystosowaniaKucharzy)];

%prawdopodobieñstwo uszkodzenia
poczatekU = 0.9;
normalneU = 0.2;
koncoweU = 0.8;
%punkty "prze³omowe"
dotarcieKas = 100;
staroscKas = 540;
%skala czasu - sredni czas zycia
skalaKas = 160;
%uszkodzenia kas
uszk63procKas = 3*godzina;
pbUszkodzen = linspace(poczatekU, normalneU, dotarcieKas);
pbUszkodzen = [pbUszkodzen, linspace(normalneU, normalneU, staroscKas - dotarcieKas)];
pbUszkodzen = [pbUszkodzen, linspace(normalneU, koncoweU, iloscDniSymulacji - staroscKas)];
%status 0 - dziala, 1 - nie
statusKas = zeros(1,iloscKas);

%koszty
placaZaGodzineKasier = 20; %wiadomo, ze brutto
placaZaGodzineKierownik = 28;
placaZaGodzineKuchasz = 20;
kosztKucharzy = kucharzy * placaZaGodzineKuchasz * 11; % 11 - ilosc godzin pracy 
kosztKierownika = placaZaGodzineKierownik * 11;
kosztKasierow = iloscKas * placaZaGodzineKasier * 11;
kosztWynajmuDzien = 500; %nie jestem w stanie tego potwierdzic, ale wiadomo woda, prad, dobre miejsce
kosztProdukcji = 0;
%dochody
dochod = 0;

%czas
dniSymulacji = 0; %nie potrzeba inicjalizowaæ na 1 dzien
czasDnia = 23 * godzina;

%symulacja
while(dniSymulacji <= iloscDniSymulacji)
    %koniec dnia
    if(czasDnia > 22 * godzina)
        %zwijamy klientów, dodajemy do puli nieobs³u¿onych
        nieobsluzeniKlienci = nieobsluzeniKlienci + iloscKlientow + klientPoszedl;
        iloscKlientow = 0;
        oczekujacych = zeros(1, typowProduktow);
        %zerujemy kolejkê, zak³adamy, ¿e przy nowym dniu od razu przychodzi
        %klient
        czasDoParagonuKas = zeros(1,iloscKas);
        czasDoNastepnegoKlienta = 0;
        %zerowanie wskaŸników godzin szczytu
        rushHourIndex = 1;
        emptyHourIndex = 1;
        isEmptyHours = false;
        isRushHours = false;
        %przekrêcam licznik czasu
        czasDnia = 11 * godzina;
        dniSymulacji = dniSymulacji + 1;
        %kucharze - nowy dziêñ - nowa ¿ywnoœæ
        tworzonaPotrawa = zeros(1,kucharzy);
        gotowychPotraw = ones(1,typowProduktow) * gotowychNaPoczatku;
        czasDoNastepnejPotrawy = zeros(1, typowProduktow);
        %uszkodzenia kas - zak³adam, ¿e przez noc naprawi¹
        tmp = ((1 + normalneU) * skalaKas) * (1- pbUszkodzen(1,dniSymulacji));
        czasDoUszkodzenia = wblrnd(tmp, 3.4, 1, iloscKas);
        %naprawy - jw.
        czasDoNaprawy = zeros(1,iloscKas);
        continue;
    end
    
    %sprawdzanie, czy sa godziny szczytu
    if(rushHourIndex <= length(rushHours))
        if(isRushHours)
           if(czasDnia > endRushHours(rushHourIndex))
               isRushHours = false;
               rushHourIndex = rushHourIndex + 1;
           end
        else 
           if(czasDnia > rushHours(rushHourIndex))
               isRushHours = true;
               
           end
        end
    end
    %lub ich brak
    if(emptyHourIndex <= length(emptyHours))
        if(isEmptyHours)
           if(czasDnia > endEmptyHours(emptyHourIndex))
               isEmptyHours = false;
               emptyHourIndex = emptyHourIndex + 1;
           end
        else 
           if(czasDnia > emptyHours(emptyHourIndex))
               isEmptyHours = true;
           end
        end
    end
    
    %obsluga kas
    for kasa = 1:iloscKas
        if(czasDoParagonuKas(1, kasa) <= 0 && iloscKlientow > 0 && statusKas(1, kasa) == 0)
            iloscKlientow = iloscKlientow - 1;
            
            %Generowanie dochodow
            aktualneZamowienie = abs(normrnd(15.885,19.406566,1,1));
            dochod = dochod + aktualneZamowienie;
            potrawa = ceil(aktualneZamowienie/5) - 2;
            if(potrawa < 1)
                potrawa = 1;
            elseif(potrawa > 8)
                potrawa = 8;
            end
            %oczekuj¹cy spowalniaj¹ kolejkê
            oczekujacych(1, potrawa) = oczekujacych(1, potrawa) + 1;
            czasDoParagonuKas(1, kasa) = (1 + sum(oczekujacych)/15) * lognrnd(4.186137273240221, 0.582386104269140);

            gotowychPotraw(1, potrawa) = gotowychPotraw(1, potrawa) - 1;
        end
        %psucie sie kas
        if(czasDoUszkodzenia(1, kasa) <= 0 && statusKas(1,kasa) == 0)
            %konczy obsluge
            %if(czasDoParagonuKas(1, kasa) > 0)
            %    iloscKlientow = iloscKlientow -1;
            %    oczekujacych = oczekujacych + 1;
            %end
            statusKas(1,kasa) = 1;
            %TODO ulepszyc czas napraw
            czasDoNaprawy(1,kasa) = wblrnd(10*minuta, 2.1);
        elseif(czasDoNaprawy(1, kasa) <= 0 && statusKas(1,kasa) == 1)
            tmp = wblrnd(((1 + normalneU) * skalaKas) * (1- pbUszkodzen(1,dniSymulacji)), 3.4);
            czasDoUszkodzenia(1, kasa) =  tmp;%wewnatrz rozklad normalny
            statusKas(1,kasa) = 0;
        end
    end
    
    %przygotowanie potraw
    for kucharz = 1:kucharzy
        potrawaTmp = tworzonaPotrawa(1,kucharz);
        if(potrawaTmp > 0)
            if(czasDoNastepnejPotrawy(1, potrawaTmp) <= 0)
               gotowychPotraw(1, potrawaTmp) = gotowychPotraw(1, potrawaTmp) + gotowychNaRaz(potrawaTmp);
               tworzonaPotrawa(1,kucharz) = 0;
            end
        end
        if(potrawaTmp == 0)
           [tmp, tworzonaPotrawa(1,kucharz)] = min(gotowychPotraw);
           potrawaTmp = tworzonaPotrawa(1,kucharz);
           czasDoNastepnejPotrawy(1, potrawaTmp) = wblrnd(sredniCzasPrzygotowania(1, potrawaTmp) * doswiadczenieKucharzy(1, dzien), 1.3222556979404211);
        end
    end
    
    %odbieranie potraw
    if(sum(gotowychPotraw) > 0 && sum(oczekujacych) > 0) 
        for potrawa = 1:typowProduktow
            if(gotowychPotraw(1, potrawa) > oczekujacych(1, potrawa))
                gotowychPotraw(1, potrawa) = gotowychPotraw(1, potrawa) - oczekujacych(1, potrawa);
                oczekujacych(1, potrawa) = 0;
            else 
                oczekujacych(1, potrawa) = oczekujacych(1, potrawa) - gotowychPotraw(1, potrawa);
                gotowychPotraw(1, potrawa) = 0;
            end
        end
    end
    
    %Generowanie ludzi
    if(czasDoNastepnegoKlienta <= 0)
        calkowitaLiczbaKlientow = calkowitaLiczbaKlientow + 1;
        iloscKlientow = iloscKlientow + 1;
        %przypadki, kiedy klienci rezygnuja
        if(iloscKlientow>(iloscKas*12))
            if(abs(normrnd(0.6,0.2)) < 0.3)
                iloscKlientow = iloscKlientow - 1;
                klientPoszedl = klientPoszedl + 1;
            end
            %wartosci dystrybucji wyciagnac na gore
            if(isRushHours)
                czasDoNastepnegoKlienta = exprnd(16.714285714285715);
            elseif(isEmptyHours)
                czasDoNastepnegoKlienta = wblrnd(96.753113901444380, 1.105276393431296);
            else
                czasDoNastepnegoKlienta = gamrnd(1.340581399238857, 39.044569969524230);
            end
        else
            if(isRushHours)
                czasDoNastepnegoKlienta = exprnd(16.714285714285715);
            elseif(isEmptyHours)
                czasDoNastepnegoKlienta = wblrnd(96.753113901444380, 1.105276393431296);
            else
                czasDoNastepnegoKlienta = gamrnd(1.340581399238857, 39.044569969524230);
            end
        end
    end
   
    
    %nastepny event
    eventTime = [czasDoNastepnegoKlienta, czasDoParagonuKas, czasDoNastepnejPotrawy, czasDoUszkodzenia, czasDoNaprawy];
    nextEvent = min(eventTime(eventTime > 0));
    czasDnia = nextEvent + czasDnia;
    %skrocenie czasow
    czasDoNastepnejPotrawy = czasDoNastepnejPotrawy - nextEvent;
    czasDoNastepnegoKlienta = czasDoNastepnegoKlienta - nextEvent;
    czasDoParagonuKas = czasDoParagonuKas - nextEvent;
    czasDoNaprawy = czasDoNaprawy - nextEvent;
    czasDoUszkodzenia = czasDoUszkodzenia - nextEvent;
end
