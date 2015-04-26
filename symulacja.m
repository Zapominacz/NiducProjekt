minuta = 60;
godzina = 60 * minuta;
dzien = 24 * godzina;

nieobsluzeniKlienci = 0;

rushHours = [12.5, 16] .* godzina;
endRushHours = [13, 18] .* godzina;
isRushHours = false;
rushHourIndex = 1;

%przygotowywanie potraw
przygotowanychPotraw = 0;
oczekujacych = 0;
doUkonczeniaPotrawy = wblrnd(1.158774415699941e+02, 1.3222556979404211, 1,  kucharzy);


iloscKlientow = 0;
calkowitaLiczbaKlientow = 0;
czasDoNastepnegoKlienta = 0;
czasDoParagonuKas = zeros(1,iloscKas);
dniSymulacji = 0;
czasDnia = 11 * dzien;

while(dniSymulacji < iloscDniSymulacji)
    %koniec dnia
    if(czasDnia > 22 * godzina)
        nieobsluzeniKlienci = nieobsluzeniKlienci + iloscKlientow;
        iloscKlientow = 0;
        oczekujacych = 0;
        przygotowanychPotraw = 0;
        doUkonczeniaPotrawy = wblrnd(1.158774415699941e+02, 1.3222556979404211, 1, kucharzy);
        czasDoParagonuKas = zeros(1,iloscKas);
        czasDoNastepnegoKlienta = 0;
        rushHourIndex = 1;
        isRushHours = false;
        czasDnia = 11 * godzina;
        dniSymulacji = dniSymulacji + 1;
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
    
    %obsluga kas
    for kasa = 1:iloscKas
        if(czasDoParagonuKas(1, kasa) <= 0 && iloscKlientow > 0)
            iloscKlientow = iloscKlientow -1;
            oczekujacych = oczekujacych + 1;
            czasDoParagonuKas(1, kasa) = (1+ (oczekujacych )/15) * lognrnd(4.186137273240221, 0.582386104269140);
        end
    end
    
    %przygotowanie potraw
    for kucharz = 1:kucharzy
        if(doUkonczeniaPotrawy(1, kucharz) <= 0)
            przygotowanychPotraw = przygotowanychPotraw + 1;
            doUkonczeniaPotrawy(1, kucharz) = wblrnd(1.158774415699941e+02, 1.3222556979404211);
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
        %wartosci dystrybucji wyciagnac na gore
        if(isRushHours)
            czasDoNastepnegoKlienta = exprnd(16.714285714285715);
        else
            czasDoNastepnegoKlienta = gamrnd(1.340581399238857, 39.044569969524230);
        end
    end
    
    %nastepny event
    eventTime = [czasDoNastepnegoKlienta, czasDoParagonuKas, doUkonczeniaPotrawy];
    nextEvent = min(eventTime(eventTime > 0));
    czasDnia = nextEvent + czasDnia;
    %skrocenie czasow
    doUkonczeniaPotrawy = doUkonczeniaPotrawy - nextEvent;
    czasDoNastepnegoKlienta = czasDoNastepnegoKlienta - nextEvent;
    czasDoParagonuKas = czasDoParagonuKas - nextEvent;
end