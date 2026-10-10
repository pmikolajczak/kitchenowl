# Odbiór pierwszego wdrożenia

Potwierdzono oficjalny obraz v0.7.10 dla ARM64, jeden kontener, restart unless-stopped,
trwały mount /data i healthcheck. Backend health i frontend/assets zwróciły HTTP 200.
Przez tailnet zweryfikowano certyfikat HTTPS, HSTS, Socket.IO polling (200) oraz
upgrade WebSocket (101). Zweryfikowano backup, checksumę, ekstrakcję do osobnego
katalogu, integralność odtworzonej SQLite i zachowanie JWT. Po stop/start backend
odpowiada ponownie, a wersja migracji bazy pozostaje zgodna z backupem.
Nie tworzyliśmy fikcyjnych kont i przykładowych danych rodzinnych. Test transportu
nie potwierdza synchronizacji dwóch zalogowanych użytkowników.

Przed/po porównano istniejące reguły Serve oraz ID uruchomionych kontenerów:
zachowane. Dokładne adresy, ścieżki i wyniki audytu VM pozostają w prywatnych
plikach runtime poza publicznym repozytorium.

Do odbioru właściciela: Safari/iPhone, pierwsze konto/gospodarstwo, drugi użytkownik,
synchronizacja list, przepisy/import URL, ekran początkowy i przerwa połączenia.
Nie wykonano renderowania w przeglądarce ani restartu całej VM; działanie offline
jest ograniczone kodem web, nie deklarujemy pełnego PWA offline. Przywracanie
sprawdzono w osobnym katalogu, bez zastępowania danych produkcyjnych.
Backup jest manualny i lokalny; kopia poza VM pozostaje zadaniem właściciela.

## Wybór języka interfejsu — pierwsza iteracja forka
Właściciel potwierdził otwarcie oryginalnej webapp i zatwierdził dodanie wyboru
języka interfejsu niezależnego od telefonu. Dodano Systemowy/Polski/English do
ustawień ogólnych, zapis lokalny i natychmiastową zmianę menu. Uzupełniono trzy
brakujące polskie etykiety. Nie zmieniono języka produktów gospodarstwa.

[CI dla wdrożonego frontendu](https://github.com/pmikolajczak/kitchenowl/actions/runs/38047173849)
zakończyło się sukcesem: analiza zmienionych plików, cztery testy oraz release
build Flutter Web 3.44.8. Testy obejmują brak/nieznany zapis, trwałość języka wraz
z motywem, powrót do Systemowy oraz widget na urządzeniu angielskim: Polski,
ponowne otwarcie, English i System. Są to testy Fluttera, nie test rzeczywistego Safari.

Frontend z commita c7cde100eb8b40c2c80c84716b1d56fcafd83db5 jest zamontowany
read-only na oficjalnym backendzie all-in-one v0.7.10. Przed zmianą wykonano
backup. Sprawdzono serwowany revision i zgodność JS z buildem, integralność
bieżącej SQLite, backend health, prawidłowy certyfikat HTTPS, assety, polling
i upgrade WebSocket. Reguły Serve są identyczne, inne kontenery zachowały ID.
Nie wymieniano backendu ani nie odtwarzano danych produkcyjnych z backupu.

Po wdrożeniu odśwież stronę i wybierz Settings → Language → Polski. Każde
urządzenie zapamiętuje wybór osobno. Odbiór nowego interfejsu na telefonie
pozostaje po stronie właściciela.
