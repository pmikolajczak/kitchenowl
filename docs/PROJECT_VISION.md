# KitchenOwl — rodzinna lista zakupów

## Cel
Prywatna, współdzielona lista zakupów i przepisy dla dwóch osób. Najpierw używamy
oryginalnego KitchenOwl, potem rozwijamy własny fork na podstawie realnych potrzeb.
Projekt rodzinny, bez płatnych usług w pierwszej iteracji.

## Stan i założenia
- Bazowe wydanie: v0.7.10, oficjalny obraz ARM64 all-in-one, bez zmian funkcjonalnych.
- Frontend Flutter, backend Flask/Python, SQLite i obrazy w /data.
- Polski interfejs i bazowy katalog produktów/kategorii już istnieją upstream.
- Wspólne gospodarstwo, listy, przepisy, import URL i rekomendacje są funkcjami upstream;
  ich odbiór przez rodzinę wymaga kont i testów opisanych w DEPLOYMENT.md.
- Prywatny dostęp HTTPS przez Tailscale Serve; bez Funnel i publicznych portów.
- Jedna usługa Compose, bez zewnętrznej bazy, Redis, Kafka ani Kubernetes.
- Sekrety i dane rodzinne pozostają poza publicznym repozytorium.
- LLM to przyszła opcjonalna warstwa semantyczna; nie jest instalowany teraz.

## Planowane funkcje — jeszcze niezaimplementowane w forku
1. **Smart Polish Input:** wiele produktów w jednym wpisie, ilości i jednostki,
   tolerowanie literówek, nazwy potoczne, aliasy oraz zapamiętywanie ręcznych poprawek.
   Przykłady: „mleko 2l, jajka 10 szt, chleb”, „te jogurty co zwykle”. Najpierw
   deterministyczne reguły i historia gospodarstwa, opcjonalnie semantyka LLM.
2. **Przepisy z obrazów:** zdjęcie książki, screenshot i galeria; OCR/vision,
   składniki i jednostki, zmiana porcji, dopasowanie do katalogu i zatwierdzenie
   przed dodaniem do listy. Zapis przepisu opcjonalny. Instagram/TikTok wymagają
   osobnej oceny możliwości. Obecny import URL pozostaje punktem wyjścia.
3. **Profile sklepów:** własna kolejność kategorii dla Biedronki, Lidla i konkretnej
   placówki, ręczne korekty i ewentualne uczenie kolejności; bez zakładania map alejek.
4. **Kupowane razem:** ocena istniejących association rules/Apriori, odrzucenie
   przypadkowych zależności i wygodne, nienatarczywe sugestie.
5. **Regularne zakupy:** odstępy między rzeczywistymi zakupami, opcjonalne ilości,
   odrzucanie sugestii; bez pełnego magazynu domowego i natarczywych powiadomień.
6. **Gospodarstwo:** wspólne preferencje, historia i aliasy; odporność na chwilowe
   przerwy połączenia. Trwały offline webapp wymaga osobnej pracy, patrz niżej.
7. **Modele lokalne:** przyszły benchmark małego modelu polskiego na ARM64 CPU,
   Ollama lub llama.cpp, OCR/vision i ewentualnie bardzo tanie API jako fallback.
   Nie zakładamy akceptowalnej szybkości CPU bez pomiaru.

## Punkty rozszerzeń
- kitchenowl/lib/pages/recipe_scraper_page.dart
- kitchenowl/lib/cubits/recipe_scraper_cubit.dart
- kitchenowl/lib/services/api/recipe.dart
- backend/app/service/recipe_scraping.py
- backend/app/service/ingredient_parsing.py
- backend/app/controller/recipe/recipe_controller.py

Potencjalny endpoint importu obrazu powinien zwracać strukturę kompatybilną z
RecipeScrape, żeby ponownie użyć ekranu zatwierdzania. To propozycja, nie wdrożenie.
Nie tworzymy osobnych mikroserwisów bez konkretnej potrzeby i pomiarów.

## Iteracje
0. Wdrożenie, fork, Tailscale, dokumentacja; odbiór iPhone/dwóch kont przez rodzinę.
1. Test funkcji upstream, polskiej kategoryzacji i importu przepisów; lista braków.
2. Polski input, aliasy i zapamiętywanie kategorii.
3. OCR/vision, porcje, składniki prosto do listy.
4. Profile sklepów i kolejność działów.
5. Predykcja i lepsze sugestie, opcjonalne modele AI.
Kolejność zmieniamy na podstawie użytkowania.

## Webapp i offline
W v0.7.10 TempStorage i TransactionStorage pomijają lokalne pliki przy kIsWeb.
Web używa transportu Socket.IO polling. Manifest deklaruje display=standalone,
a HTML ma ikonę i metadane mobilne. Nie jest to dowód pełnego offline na iOS:
nie polegamy na zachowaniu listy/niezsynchronizowanych zmian po zamknięciu lub
odświeżeniu Safari. Dodanie do ekranu początkowego i przerwy połączenia wymagają
odbioru na rzeczywistym iPhonie. Nie deklarujemy testu Safari, którego nie wykonano.

## VM i koszty
Oracle ARM64: ograniczone zasoby CPU i dysku, współdzielone z innymi usługami.
Aktualny stan zasobów i zapas miejsca sprawdzamy lokalnie przed zmianami.
Nie budujemy lokalnie Fluttera/obrazów przy małym zapasie dysku; preferujemy obrazy
upstream, a w przyszłości CI dla własnego forka. Nie instalujemy nowych modeli.
Brak płatnych usług, otwartych portów i publicznego DNS w pierwszej iteracji.
Monitorujemy dysk i wielkość backupów; nie usuwamy danych innych projektów.
Backup na tej samej VM chroni przed pomyłką, ale nie przed utratą VM/dysku.
Kopię poza VM pobiera właściciel bez kupowania nowej usługi.

## Git i upstream
origin: https://github.com/pmikolajczak/kitchenowl (publiczny fork, zgoda właściciela).
upstream: https://github.com/TomBursch/kitchenowl.
Licencja: AGPL-3.0; zachowujemy LICENSE i informacje upstream.
Branch family/deployment bazuje na v0.7.10; main pozostaje bazą upstream.
Przyszłe zmiany na osobnych branchach, bez mieszania z sekretami i danymi.
Przed aktualizacją fetch upstream, przegląd wydania, merge wybranego stabilnego
tagu do brancha rodzinnego, backup i test. Nie śledzimy automatycznie main/dev.
Konfiguracja wdrożenia jest w deploy/family; aktualizacja obrazu nie wymaga
budowania forka. Sposób aktualizacji i przywracania: DEPLOYMENT.md.
