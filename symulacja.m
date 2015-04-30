%stale czasu
minuta = 60;
godzina = 60 * minuta;
dzien = 24 * godzina;

%switch czasowy dla ruchu
rushHours = rushHours .* godzina;
endRushHours = endRushHours .* godzina;
emptyHours = emptyHours .* godzina;
endEmptyHours = endEmptyHours .* godzina;
isRushHours = false;
isEmptyHours = false;
rushHourIndex = 1;
emptyHourIndex = 1;

%klienci
nieobsluzeniKlienci = 0;
calkowitaLiczbaKlientow = 0;
iloscKlientow = 0;
oczekujacych = 0;

%przygotowywanie potraw
przygotowanychPotraw = 0;
doUkonczeniaPotrawy = wblrnd(1.158774415699941e+02, 1.3222556979404211, 1,  kucharzy);

%kasy
czasDoNastepnegoKlienta = 0;
czasDoParagonuKas = zeros(1,iloscKas);

%uszkodzenia kas
czasDoUszkodzenia = exprnd(1/(3*godzina), 1, iloscKas);
%naprawy
czasDoNaprawy = zeros(1,iloscKas);
%status 0 - dziala, 1 - nie
statusKas = zeros(1,iloscKas);

%czas
dniSymulacji = 0;
czasDnia = 11 * dzien;

%koszty
placaZaGodzineKasier = 20; %wiadomo, ze brutto
placaZaGodzineKierownik = 28;
placaZaGodzineKuchasz = 20;
kosztKucharzy = kucharzy * placaZaGodzineKuchasz * 11; % 11 - ilosc godzin pracy 
kosztKierownika = placaZaGodzineKierownik * 11;
kosztKasierow = iloscKas * placaZaGodzineKasier * 11;
kosztWynajmuDzien = 500; %nie jestem w stanie tego potwierdzic, ale wiadomo woda, prad, dobre miejsce
kosztProdukcji = 0;
%klasyfikacja produktow
produkt1 = 0;
produkt2 = 0;
produkt3 = 0;
produkt4 = 0;
produkt5 = 0;
produkt6 = 0;
produkt7 = 0;
produkt8 = 0;
%dochody
dochod = 0;

%licznik ludzi znudzonych staniem
klientPoszedl = 0;

%symulacja
while(dniSymulacji < iloscDniSymulacji)
    %koniec dnia
    if(czasDnia > 22 * godzina)
        nieobsluzeniKlienci = nieobsluzeniKlienci + iloscKlientow + klientPoszedl;
        iloscKlientow = 0;
        oczekujacych = 0;
        przygotowanychPotraw = 0;
        doUkonczeniaPotrawy = wblrnd(1.158774415699941e+02, 1.3222556979404211, 1, kucharzy);
        czasDoParagonuKas = zeros(1,iloscKas);
        czasDoNastepnegoKlienta = 0;
        rushHourIndex = 1;
        emptyHourIndex = 1;
        isEmptyHours = false;
        isRushHours = false;
        czasDnia = 11 * godzina;
        dniSymulacji = dniSymulacji + 1;
        %uszkodzenia kas
        czasDoUszkodzenia = exprnd(1/(3*godzina), 1, iloscKas);
        %naprawy
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
            iloscKlientow = iloscKlientow -1;
            oczekujacych = oczekujacych + 1;
            czasDoParagonuKas(1, kasa) = (1+ (oczekujacych )/15) * lognrnd(4.186137273240221, 0.582386104269140);
            
                        %Generowanie dochodow
            aktualneZamowienie = abs(normrnd(15.885,19.406566,1,1));
            dochod = dochod + aktualneZamowienie;
            if(aktualneZamowienie < 10)
                produkt1=produkt1 +1 ;              
            elseif(aktualneZamowienie > 10 && aktualneZamowienie <= 15)
                produkt2 = produkt2 + 1;           
            elseif(aktualneZamowienie > 15 && aktualneZamowienie <= 20)
                produkt3 = produkt3 + 1;            
            elseif(aktualneZamowienie > 20 && aktualneZamowienie <= 25)
                produkt4 = produkt4 +1;
            elseif(aktualneZamowienie > 25 && aktualneZamowienie <= 30)
                produkt5 = produkt5 + 1;
            elseif(aktualneZamowienie > 30 && aktualneZamowienie <= 35)
                produkt6 = produkt6 + 1;
            elseif(aktualneZamowienie > 35 && aktualneZamowienie <= 40)
                produkt7 = produkt7 + 1;
            elseif(aktualneZamowienie > 40)
                produkt8 = produkt8 + 1;
            end
            %liczbaZamowien = produkt1+produkt2+produkt3+produkt4+produkt5+produkt6+produkt7+produkt8;
            %Ta linjka przekleic do ui.m jezeli taka dana potrzebna
            
        end
        %psucie sie kas
        if(czasDoUszkodzenia(1, kasa) <= 0 && statusKas(1,kasa) == 0)
            %konczy obsluge
            %if(czasDoParagonuKas(1, kasa) > 0)
            %    iloscKlientow = iloscKlientow -1;
            %    oczekujacych = oczekujacych + 1;
            %end
            statusKas(1,kasa) = 1;
            %tylko 1 narazie - paragon
            czasDoNaprawy(1,kasa) = wblrnd(30, 2.1);
        elseif(czasDoNaprawy(1, kasa) <= 0 && statusKas(1,kasa) == 1)
            czasDoUszkodzenia(1, kasa) = exprnd(1/(3*godzina));
            statusKas(1,kasa) = 0;
        end
    end
    
    %przygotowanie potraw
    for kucharz = 1:kucharzy
        if(doUkonczeniaPotrawy(1, kucharz) <= 0)
            przygotowanychPotraw = przygotowanychPotraw + 1;
            dodatkowyCzas = 0;
            gotowe = 1;
            while(gotowe)
                niezawodnoscKucharzy = abs(normrnd(0.94,0.421637,10,1));
                if (niezawodnoscKucharzy <= 0.7)
                     dodatkowyCzas= dodatkowyCzas + abs(normrnd(13,5.142,1,1));
                else
                     doUkonczeniaPotrawy(1, kucharz) = wblrnd(1.158774415699941e+02, 1.3222556979404211) + dodatkowyCzas;
                     gotowe = 0;
                end
            end
        end
    end
    
    %odbieranie potraw
    if(przygotowanychPotraw > 0 && oczekujacych > 0) 
        if(przygotowanychPotraw > oczekujacych)
            przygotowanychPotraw = przygotowanychPotraw - oczekujacych;
            oczekujacych = 0;
        else 
            oczekujacych = oczekujacych - przygotowanychPotraw;
            przygotowanychPotraw = 0;
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
    eventTime = [czasDoNastepnegoKlienta, czasDoParagonuKas, doUkonczeniaPotrawy, czasDoUszkodzenia, czasDoNaprawy];
    nextEvent = min(eventTime(eventTime > 0));
    czasDnia = nextEvent + czasDnia;
    %skrocenie czasow
    doUkonczeniaPotrawy = doUkonczeniaPotrawy - nextEvent;
    czasDoNastepnegoKlienta = czasDoNastepnegoKlienta - nextEvent;
    czasDoParagonuKas = czasDoParagonuKas - nextEvent;
    czasDoNaprawy = czasDoNaprawy - nextEvent;
    czasDoUszkodzenia = czasDoUszkodzenia - nextEvent;
end
