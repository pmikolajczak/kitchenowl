# Wdrożenie rodzinnego KitchenOwl

## Publiczne i prywatne pliki
Ta instrukcja jest uniwersalna. Rzeczywiste adresy, porty, UID/GID, ścieżki VM,
konfiguracja Serve, wyniki audytu innych usług i backupy są przechowywane lokalnie
poza publicznym repozytorium. Szczegóły własnej instalacji: config/DEPLOYMENT_LOCAL.md
w prywatnym katalogu projektu. Nigdy nie publikować config, data, backups ani state.

## Układ projektu
Wybierz prywatny katalog runtime, oznaczany dalej KITCHENOWL_ROOT:

```text
<project-root>/
  repo/                 # ten fork, branch family/deployment
  config/               # prywatne środowisko i sekret JWT
  data/                 # SQLite oraz uploady
  backups/              # prywatne archiwa
  state/                # lokalny audyt, kontrole, snapshot Serve
```

Oryginał: https://github.com/TomBursch/kitchenowl (AGPL-3.0).
Fork: https://github.com/pmikolajczak/kitchenowl.
origin wskazuje fork, upstream oryginał. Branch family/deployment bazuje na
v0.7.10. Pierwszy zatwierdzony dodatek to wybór języka interfejsu; backend pozostaje upstream.

## Konfiguracja i uruchomienie
Używamy jednego oficjalnego obrazu all-in-one, przypiętego do stabilnego wydania
v0.7.10 i digestu linux/arm64. SQLite i pliki są w /data. Nie potrzeba zewnętrznej
bazy, nowych usług ani modeli. Własny obraz można później zbudować z głównego
Dockerfile w CI i podmienić tylko image w deploy/family/compose.yaml.

Po sprawdzeniu portów, zasobów i istniejących usług utwórz config/deployment.env:

```dotenv
KITCHENOWL_ROOT=/path/to/private/project
KITCHENOWL_PORT=CHOOSE_FREE_LOCAL_PORT
KITCHENOWL_UID=YOUR_UID
KITCHENOWL_GID=YOUR_GID
```

Powyższe wartości są placeholderami, trzeba je zastąpić. Skonfiguruj prywatny
config/kitchenowl.env z FRONT_URL (dokładny HTTPS URL), OPEN_REGISTRATION=false,
EMAIL_MANDATORY=false, DISABLE_ONBOARDING=false i
`UWSGI_ADD_HEADER=Strict-Transport-Security: max-age=31536000`.
Wygeneruj losowy config/jwt-secret, np. Python secrets.token_hex(64), zapisując
bezpośrednio do pliku bez drukowania. Katalogi runtime 0700, pliki config 0600;
dane muszą być zapisywalne przez wybrany UID/GID. Sekret jest montowany read-only
jako plik i odczytywany przez JWT_SECRET_KEY_FILE, nie jako wartość w repozytorium.

Z katalogu repo, po ustawieniu KITCHENOWL_ROOT:

```bash
export KITCHENOWL_ROOT=/path/to/private/project
docker compose --env-file "$KITCHENOWL_ROOT/config/deployment.env" -f deploy/family/compose.yaml config --quiet
docker compose --env-file "$KITCHENOWL_ROOT/config/deployment.env" -f deploy/family/compose.yaml up -d
```

Port wiąże wyłącznie 127.0.0.1. Restart policy unless-stopped uruchamia kontener
po restarcie Dockera/VM, o ile nie zatrzymano go celowo. Pierwszy start/restart
może trwać kilkadziesiąt sekund przez migracje/import katalogu i biblioteki.
Logi mają limit 3 × 10 MB. Nie używaj globalnego down/prune.

## Restart i diagnostyka
W poleceniach Compose zawsze podawaj prywatny --env-file i jawny -f, jak wyżej:
- `ps` — stan kontenera i healthcheck.
- `restart app` — restart wyłącznie KitchenOwl.
- `logs --tail=50 app` — logi, które po rozpoczęciu używania mogą zawierać dane prywatne.
- Backend health: `/api/health/8M4F88S8ooi4sMbLBfkkV7ctWwgibW6V`.
- `/api/onboarding` — czy możliwe jest utworzenie pierwszego użytkownika.
- Sprawdzaj wolny dysk przed pobieraniem obrazów, backupem i aktualizacją.

## Tailscale Serve
Dostęp tylko z tailnetu, HTTPS i poprawny upgrade WebSocket. Bez Funnel i nowych
publicznych portów. Najpierw odczytaj bieżący Serve i zapisz snapshot prywatnie.
Użyj wolnego portu HTTPS; nie zmieniaj istniejących handlerów ani tożsamości hosta.

```bash
tailscale serve status --json
tailscale serve --bg --https=<FREE_HTTPS_PORT> http://127.0.0.1:<LOCAL_APP_PORT>
```

Gdy Tailscale działa w kontenerze, użyj docker exec i faktycznego --socket.
Dokładne polecenia własnej instalacji znajdują się w prywatnej instrukcji lokalnej.
Po dodaniu porównaj wcześniejsze reguły i zweryfikuj brak AllowFunnel. Nie używaj
serve reset ani wgrywania całego starego snapshotu. Wyłączenie tylko własnego
portu: `tailscale serve --https=<FREE_HTTPS_PORT> off`.

Czytelniejszą nazwę może zapewnić Tailscale Services, ale potrzebny jest host
z tagową tożsamością, definicja usługi i zatwierdzenie administracyjne. Alternatywa:
osobny mały kontener Tailscale z nazwą aplikacji i nowym logowaniem. Nie zmieniamy
istniejącego węzła obsługującego inne usługi bez świadomej decyzji właściciela.

## Konto i gospodarstwo — odbiór na dwóch telefonach
Pierwszy użytkownik onboardingu zostaje administratorem. Publiczna rejestracja
pozostaje wyłączona. Nie utworzono fikcyjnych kont produkcyjnych.
1. Otwórz prywatny HTTPS URL w Safari z włączonym Tailscale, utwórz swoje konto.
2. Utwórz gospodarstwo, wybierając język Polski dla katalogu produktów.
3. Ustawienia serwera → Użytkownicy → Dodaj użytkownika: utwórz konto domownika.
4. Gospodarstwo → Członkowie: dodaj istniejące konto drugiej osoby.
5. Zaloguj drugie konto na drugim telefonie w tailnecie; przetestuj dodawanie,
   oznaczanie zakupów, synchronizację w obu kierunkach i odświeżenie.
6. Przetestuj własny przepis, porcje, import publicznego URL oraz dodanie składników.
SMTP nie jest skonfigurowany: nie obiecujemy zaproszenia e-mailem ani resetu hasła
przez e-mail. Konto można dodać z poziomu administracji serwera.

## Safari, ekran początkowy i offline
HTML ma ikonę apple-touch-icon i mobilne metadane, manifest display=standalone.
Safari → Udostępnij → Dodaj do ekranu początkowego. Wygląd i działanie na konkretnym
iOS wymagają testu na rzeczywistym telefonie, samo HTTP 200 nie dowodzi renderowania.
Webapp v0.7.10 używa Socket.IO polling i pomija trwały cache/plikową kolejkę
transakcji w TempStorage oraz TransactionStorage przy kIsWeb. Nie deklarujemy
pełnego offline, szczególnie po odświeżeniu lub zamknięciu Safari. Przerwa sieci
przy otwartej stronie i odzyskanie połączenia wymagają osobnego odbioru.

## Backup
Ustaw KITCHENOWL_ROOT jak wyżej i uruchom:

```bash
./deploy/family/backup.sh
```

Skrypt ma blokadę równoległych uruchomień, zatrzymuje wyłącznie app, archiwizuje
data, config (w tym JWT!) oraz Compose, uruchamia app i zapisuje checksumę.
Trap próbuje wznowić aplikację po błędzie; nieudane .partial sprawdź ręcznie.
Backup jest manualny, bez harmonogramu i automatycznego kasowania. Wykonuj przed
aktualizacją i regularnie po użyciu. Pobieraj prywatną kopię na własny komputer
przez SSH/SCP: backup na tej samej VM nie chroni przed utratą dysku/VM.

## Przywracanie
Zastępuje dane — wykonuj świadomie po backupie obecnego stanu.
1. `sha256sum -c <archive>.sha256`; obejrzyj `tar -tzf <archive>`.
2. Używaj tylko własnego backupu, bez ścieżek absolutnych, ../ i nieoczekiwanych
   symlinków. Rozpakuj do nowego prywatnego katalogu z wystarczającym miejscem.
3. SQLite `PRAGMA integrity_check` odtworzonej bazy ma zwrócić ok. Zachowaj wszystkie
   pliki SQLite razem, nie kopiuj samej żywej bazy pomijając WAL.
4. Zatrzymaj tylko app przez jawny Compose; zachowaj bieżące data/config jako rollback.
5. Umieść odtworzone data/config pod dotychczasowymi ścieżkami, z odpowiednim UID/GID
   i uprawnieniami. Zachowaj JWT z backupu. Przywróć pasujący Compose/obraz.
6. Uruchom `up -d`, sprawdź health, logowanie, listy i przepisy. Nie usuwaj rollbacku
   przed odbiorem. Nie przywracaj globalnej konfiguracji Tailscale snapshotem.

## Aktualizacja
Sprawdź zasoby i stabilne release notes, wykonaj backup i kopię poza VM.
`git fetch upstream --tags`, merge wybranego stabilnego tagu na osobnym branchu,
przegląd konfliktów; bez force push. Sprawdź manifest ARM64, zmień wersję/digest
obrazu w Compose, wykonaj jawne `pull` i `up -d`, sprawdź health i dwa konta.
Po migracji DB rollback może wymagać starego obrazu ORAZ backupu sprzed migracji.
Nie aktualizujemy automatycznie do main/dev, nie budujemy Fluttera na VM z małym
dyskiem. W przyszłości własne obrazy linux/arm64 buduj istniejącym Dockerfile w CI,
publikuj do GHCR i przypinaj digest; dane/sekrety/Serve nie wymagają przebudowy.

## Źródła
- https://docs.kitchenowl.org/latest/self-hosting/
- https://docs.kitchenowl.org/latest/self-hosting/advanced/
- https://github.com/TomBursch/kitchenowl/releases/tag/v0.7.10
- https://tailscale.com/docs/reference/tailscale-cli/serve
- https://tailscale.com/docs/features/tailscale-services

## Własny frontend: wybór języka interfejsu
Branch family/ui-language dodaje Ustawienia → Język (Systemowy, Polski, English).
Wybór jest zapamiętywany lokalnie w SharedPreferences/localStorage i od razu
zmienia interfejs, niezależnie od języka gospodarstwa i katalogu produktów.
Systemowy usuwa override i przywraca wybór urządzenia. Każdy telefon wybiera język
osobno; usunięcie danych witryny resetuje ustawienie. Uzupełniono trzy brakujące
polskie etykiety. Nie zmieniono bazy, modeli ani backendu.

Workflow Family web build buduje frontend Flutter 3.44.8 poza VM, po analizie
i testach trwałości preferencji oraz widgetu na angielskim urządzeniu. Wynik
jest artefaktem kitchenowl-family-web z family-revision.txt zawierającym commit.
Pobierz tylko artefakt udanego runu właściwego commita do prywatnego katalogu
web-releases/<commit>, dodaj KITCHENOWL_WEB_DIR do config/deployment.env i do
poleceń Compose dodaj `-f deploy/family/web-override.yaml` po głównym pliku.
Override montuje zweryfikowany frontend read-only do istniejącego obrazu;
liczba kontenerów, baza i porty pozostają te same. Przed recreacją app wykonaj
backup. Zachowaj wcześniejszy frontend jako rollback; po wdrożeniu sprawdź
revision, HTTPS, health i możliwość logowania. Backup powinien zawierać również
aktualny build frontendowy. Nie kopiuj danych VM do publicznych artefaktów CI.
