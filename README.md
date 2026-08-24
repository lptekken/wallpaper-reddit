# Reddit Wallpaper Rotator für Wallpaper Engine

Leichtgewichtiges Web-Wallpaper mit lokalem Node.js-OAuth-Helper, Bild-Pool, Preloading und Crossfade.

## Requirements

Windows 10/11, Wallpaper Engine, Node.js 18.17+ und ein Reddit-Konto mit einer für die Data API freigeschalteten klassischen OAuth-App.

## Reddit API Setup

Stand August 2026 nutzt der Helper das offizielle Application-only OAuth mit grant_type=client_credentials. Das ist für einen vertraulichen lokalen Prozess ohne Benutzerkontext vorgesehen. Token bleiben im RAM, werden vor Ablauf erneuert und Requests gehen mit Bearer-Token an oauth.reddit.com.

1. Bei Reddit anmelden und https://www.reddit.com/prefs/apps öffnen.
2. Create another app und Typ script wählen.
3. Name/Beschreibung vergeben. Als Redirect URI kann http://127.0.0.1:3847 dienen; dieser Flow verwendet keinen Redirect.
4. Client ID unter dem App-Namen und den Wert secret übernehmen.
5. Offizielle Quellen: https://github.com/reddit-archive/reddit/wiki/OAuth2 und https://redditinc.com/policies/data-api-terms

Reddit kann neue klassische Data-API-Apps kontenabhängig einschränken oder eine Freigabe verlangen. Devvit verwendet ein anderes Modell und ersetzt den externen localhost-Helper nicht. Ohne von Reddit ausgestellte Zugangsdaten ist keine Live-Abfrage möglich; ein gespeicherter Pool rotiert weiterhin.

## Helper Setup

PowerShell im Projektordner:

    Copy-Item .\helper\.env.example .\helper\.env
    notepad .\helper\.env

In .env REDDIT_CLIENT_ID, REDDIT_CLIENT_SECRET und einen eindeutigen REDDIT_USER_AGENT wie windows:reddit-wallpaper-engine:1.0.0 (by /u/DEIN_NAME) eintragen. .env wird von Git ignoriert.

## Starting the Helper

    node .\helper\src\server.js

Alternativ:

    powershell -ExecutionPolicy Bypass -File .\helper\start-helper.ps1
    Invoke-RestMethod http://127.0.0.1:3847/health

Optionaler Windows-Autostart:

    powershell -ExecutionPolicy Bypass -File .\helper\start-helper.ps1 -InstallAutostart

Entfernen mit Unregister-ScheduledTask -TaskName "Reddit Wallpaper Helper". Wallpaper Engine startet aus Sicherheitsgründen keine beliebigen Prozesse; das wird nicht umgangen.

## Importing into Wallpaper Engine

1. Helper starten.
2. Wallpaper Engine → Wallpaper-Editor → Create Wallpaper → Open offline wallpaper.
3. wallpaper\project.json beziehungsweise den Ordner wallpaper auswählen.
4. Speichern und anwenden.

wallpaper\index.html kann als Browser-Vorschau geöffnet werden. Ohne Helper erscheint eine dezente Meldung; ein gespeicherter Pool rotiert weiter.

## Wallpaper Engine Settings

Subreddits (kommagetrennt, mit/ohne r/, maximal 10), Hot/New/Top, Top-Zeitraum, Wechselintervall, Reddit-Refresh, Poolgröße, Mindestscore, NSFW, Video-Previews, Overlay und seine vier Felder, Auto-Hide, Cover/Contain, Transition, Dauer und Debug-Modus. Datenfilter laden einen neuen Pool; visuelle Änderungen greifen sofort.

## Architektur und Caching

wallpaper/app.js hält einen deduplizierten Pool, eine zufällige Queue sowie Sets für bereits gezeigte und defekte Bilder. Das nächste Bild wird über Image vorgeladen. Zwei Layer verhindern schwarze Frames. Der letzte erfolgreiche Pool bleibt höchstens sieben Tage in localStorage.

Der Helper bindet nur an 127.0.0.1. Er cached jeden Parametersatz standardmäßig zehn Minuten und liefert bei temporären Reddit-Fehlern das letzte erfolgreiche Ergebnis. Galeriebilder werden einzeln ausgegeben, nur HTTPS-Bildquellen akzeptiert.

## Tests

    npm test
    npm run check

Automatisiert geprüft werden Normalisierung, ungültige Namen, Score-/NSFW-/Video-Filter, Galleries, HTTPS-URLs, TTL-Cache, Health, Fehlerstatus und HTTP-Caching. Manuell in Wallpaper Engine prüfen: Start ohne/mit Helper, Live-Properties, Rotation, Refresh, Crossfade, Overlay, Cover/Contain und Neustart.

## Troubleshooting

- configured: false: .env fehlt oder enthält Platzhalter.
- OAuth 401/403: Client ID/Secret und Reddit-Freigabe prüfen.
- 429: Rate Limit; Cache/Pool laufen weiter. Refresh nicht unnötig verkürzen.
- Privates/nicht existentes Subreddit: Reddit kann 403/404 liefern; Eintrag entfernen.
- Keine Bilder: Mindestscore senken, Sortierung/Zeitraum ändern.
- Helper nicht erreichbar: Port 3847, Firewall und Node-Prozess prüfen.
- Langsames/defektes Bild: Nach 15 Sekunden wird es übersprungen.

## Project Structure

wallpaper enthält index.html, style.css, app.js, project.json und assets. helper enthält src, test, .env.example und start-helper.ps1. Im Root liegen package.json, .gitignore und diese README.

## Security Notes

Secrets gehören nur in helper\.env, nie ins Wallpaper, Git, Screenshots oder Logs. Der Server lauscht ausschließlich lokal. Reddit-Inhalte bleiben Eigentum ihrer Rechteinhaber; Reddit-Bedingungen und lokale Regeln gelten.

## Known Limitations

- Live-Zugriff hängt von einer von Reddit erlaubten klassischen Data-API-App ab.
- Manche CDNs blockieren Einbettung; solche Bilder werden übersprungen.
- Allow Videos verwendet nur statische Previews, keine laufenden Videos.
- localStorage speichert Metadaten/URLs, nicht die Bilddateien.
- Der Helper muss separat oder über die dokumentierte Windows-Aufgabe laufen.
