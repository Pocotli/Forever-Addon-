WOW FOREVER GRAPHICS TUNER 1.1.0
=================================

Cel
---
Osobny dodatek pod WoW: Forever (Interface 16001). Nie jest przerobionym klientem 2.4.3 i nie zawiera profilu Pocotli.

Profil konta
------------
- /wfft otwiera panel.
- „Zapisz ustawienia tego konta” skanuje bieżący klient i zapisuje wszystkie wykryte, czytelne CVary związane z grafiką (także ukryte, jeśli klient je ujawnia) do SavedVariables bieżącego konta Battle.net.
- „Wczytaj mój profil” stosuje wyłącznie profil zapisany przez aktualne konto.
- „Auto po wejściu” odtwarza własny zapis po wejściu do świata.
- Nowe konto zaczyna bez gotowego profilu. Najpierw trzeba zapisać jego bieżące ustawienia.

Tożsamość konta
---------------
Dodatek nie próbuje czytać loginu Battle.net i nie potrzebuje go znać. WoW ładuje SavedVariables addonu z przestrzeni aktualnego konta; konto Druszlak i konto Pocotli mają osobne dane SavedVariables. Żaden profil Pocotli nie jest dostarczany w paczce.

Zgodność z Forever
------------------
Stare zmienne z TBC 2.4.3, takie jak extShadowQuality i shadowLOD, nie są wykorzystywane. Panel sprawdza C_CVar.GetCVarInfo i pokazuje tylko suwaki dla zmiennych, które istnieją w uruchomionym kliencie. /wfft scan pokazuje pozostałe wykryte CVary związane z grafiką; w oknie skanera można wpisać nazwę i wartość, a dodatek sprawdzi, czy klient udostępnia i pozwala ustawić tę zmienną.

Ważne:
- Część ustawień może być ograniczona przez klienta lub wymagać ponownego uruchomienia.
- GI jest ograniczone do wartości 1–3; wartość 0 nie jest oferowana, bo może zepsuć oświetlenie w Forever.
- Przełącznik wyłączający volumetric fog nie jest oferowany, ponieważ Blizzard usunął ten sposób sterowania w aktualizacji beta.
- Ustawienia rajdowe są oddzielone od ustawień zwykłej gry, jeżeli klient je udostępnia.
- Nie da się potwierdzić działania w grze bez testu z aktualnym buildem Forever.

Komendy
-------
/wfft        otwórz/zamknij panel
/wfft save   zapisz ustawienia tego konta
/wfft load   wczytaj ustawienia tego konta
/wfft scan   lista CVars grafiki wykrytych w bieżącym buildzie
/wfft help   pomoc

Instalacja
----------
Skopiuj cały folder WoWForeverGraphicsTuner do:
World of Warcraft\_classic_beta_\Interface\AddOns\
Po zmianie folderu klienta po premierze sprawdź w launcherze właściwy katalog gry.
