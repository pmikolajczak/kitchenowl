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
