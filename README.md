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
Tutaj gdy spytalem czy to legalne

a jak z legalnoscia programu?
W przypadku WoW Forever Graphics Tuner rozróżniłbym dwie rzeczy: czy sam dodatek jest legalny oraz czy sposób jego działania jest zgodny z regulaminem Blizzarda.

Dobra wiadomość: to dodatek Lua uruchamiany wewnątrz gry, a nie osobny program ingerujący w pamięć procesu czy podmieniający pliki wykonywalne. Ma też być darmowy, bez reklam i bez płatnych funkcji. To przemawia na jego korzyść.

Blizzard dopuszcza dodatki interfejsu, ale wymaga m.in. bezpłatnej dystrybucji, jawnego kodu źródłowego i zgodności z EULA. Jednocześnie zastrzega sobie możliwość blokowania nieautoryzowanego oprogramowania, które zmienia działanie gry. 

World of Warcraft Forums
+2

Co sprawdziłem i dodatkowo poprawiłem
W wersji 1.1.1 ograniczyłem ręczny edytor CVar-ów: nie pozwala już zmieniać dowolnej zmiennej klienta, tylko te wykryte przez skaner jako związane z grafiką. Nadal respektuje ograniczenia klienta. Kontrola składni Lua i budowanie paczki zakończyły się sukcesem. Zobacz wyniki kontroli.

Żeby utrzymać niskie ryzyko, dodatek powinien pozostać w obecnym modelu:

korzysta z API dodatków udostępnionego przez grę;

dotyczy ustawień graficznych, nie automatyzuje walki ani działań postaci;

jest bezpłatny, bez reklam i bez próśb o dotacje w interfejsie;

zawiera jawny kod źródłowy Lua, bez ukrywania go i bez podmiany plików wykonywalnych klienta.

To odpowiada głównym wymaganiom opublikowanej przez Blizzard polityki dodatków. 

World of Warcraft Forums
+1

Ważna sprawa przed publicznym rozdaniem
Repozytorium Pocotli/EcieNieB jest prywatne. Link do artefaktu GitHub Actions nie jest więc automatycznie publicznym linkiem dla wszystkich graczy. Żeby przekazać dodatek społeczności bezpłatnie, trzeba umieścić go w publicznie dostępnym miejscu, z czytelnym kodem źródłowym.

Mój wniosek: nie widzę w obecnym przeznaczeniu dodatku oczywistego powodu, by uznać go za cheat lub niedozwolony program ingerujący w klienta. Nie mogę jednak zagwarantować, że Blizzard uzna każdą funkcję za dozwoloną. W swoich zasadach Blizzard zastrzega możliwość podjęcia działań wobec nieautoryzowanego oprogramowania. 

World of Warcraft Forums
+1

Jeśli zależy Ci na możliwie jednoznacznym potwierdzeniu przed rozdaniem dodatku wielu graczom, najbezpieczniej wysłać opis jego działania i kod do zespołu Blizzard pod wskazany w polityce adres WoWUI@blizzard.com. 

World of Warcraft Forums

to co mi dales to z kodem zrodlowym tak?
Tak. WoW Forever Graphics Tuner 1.1.1 zawiera kod źródłowy — nie jest to skompilowany ani zaciemniony program.

W paczce ZIP znajdują się:

WoWForeverGraphicsTuner.lua — pełny kod źródłowy dodatku;

WoWForeverGraphicsTuner.toc — metadane i konfiguracja ładowania;

README_PL.txt — instrukcja instalacji i obsługi;

CHANGELOG.txt — historia zmian.

Jedna ważna uwaga: repozytorium Pocotli/EcieNieB jest prywatne, więc link do paczki GitHub Actions nie musi działać dla innych graczy. Jeżeli chcesz rozdawać dodatek całej społeczności WoW Forever, trzeba udostępnić ZIP i kod źródłowy w publicznie dostępnym miejscu.
