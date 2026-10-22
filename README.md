PLIK NIE ZOSTAL PRZETESTOWANY to Upgrade Chatgpt z tbc - > forever 
Addon aktywuje sie kolo mapy (obrazek na guziku lekko zjechal do dolu nie chcialo mi sie czekac kolejne 10min nim chat to zrobi)
Ustawienia zapisuja sie automatycznie ale mozna dac anuluj wtedy wczyta te ustawienia ktore mielismy przed zmianami

 TUTAJ CO NAPISAL CHATGPT PO PRZEROBIENIU 

 Co zmieniłem
- Osobny profil dla aktualnego konta gry. Nie ma wbudowanego profilu Pocotli. Dane są przechowywane w SavedVariables dodatku i rozdzielane przez klienta WoW zgodnie z zakresem konta.
- Wykrywanie ustawień aktualnego klienta. Dodatek sprawdza dostępne CVary zamiast zakładać, że stare ustawienia TBC 2.4.3 nadal istnieją. Suwaki pokazują się tylko wtedy, gdy odpowiednia zmienna jest dostępna.
- Szersze ustawienia grafiki. Dodałem m.in. opcje jakości cieni, oświetlenia, tekstur, wody i osobne ustawienia raidowe, jeżeli klient je udostępnia.
- Skaner CVAR-ów. Przycisk „Skanuj wszystkie CVary” pozwala zobaczyć wykryte zmienne graficzne i ich wartości. Część mniej typowych opcji jest dostępna przez skaner, nawet jeśli nie ma własnego suwaka.
- Zabezpieczenia zgodności. Nie udostępniam starych przełączników TBC, takich jak extShadowQuality czy shadowLOD, ani wyłącznika volumeFog. Ustawienie GI nie pozwala wybrać wartości 0, która może powodować problemy z oświetleniem w Forever.
Jak działa konto „Druszlak”?
Nie trzeba wpisywać ani odczytywać loginu Druszlak. Dodatek korzysta z własnych zapisanych danych aktualnego konta gry:
1. Gracz uruchamia dodatek i otwiera panel komendą /wfft.
2. Kliknięcie „Zapisz ustawienia tego konta” zapisuje wykryte ustawienia graficzne.
3. Przy kolejnych wejściach dodatek może odtwarzać ten zapis automatycznie, jeśli opcja „Auto po wejściu” jest włączona.
Ważne: przy pierwszym użyciu nowego konta trzeba najpierw zapisać jego ustawienia. To nie jest zdalna baza profili i nie synchronizuje zapisów między różnymi komputerami. Samo zainstalowanie dodatku nie pobiera ustawień Pocotli ani nie tworzy profilu dla Druszlak.

Status testów: GitHub Actions zakończył się sukcesem — składnia Lua jest poprawna, a ZIP został utworzony. Nie uruchomiłem jednak klienta WoW: Forever, więc nie mogę jeszcze zagwarantować, że każdy CVar i automatyczne stosowanie ustawień zadziałają identycznie w aktualnym buildzie gry. Po instalacji najlepiej zacząć od /wfft i sprawdzić wykryte zmienne przyciskiem „Skanuj wszystkie CVary”.
