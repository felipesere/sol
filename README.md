# Sol

A small app for tracking a child's temperature and medicine when they are ill.
It shows how much of each medicine was given in the last 24 hours, when the next
dose is allowed, how the temperature is moving, and who logged what.

Rails 8, SQLite, no JavaScript to write (Turbo plus one Stimulus controller that draws the chart).

## Run your own copy

```sh
docker compose up -d      # then open http://localhost:3000
```

Edit `docker-compose.yml` first. Everything is configured with environment variables:

| Variable | Purpose |
| --- | --- |
| `HOUSEHOLD_USERS` | Comma separated names, e.g. `Felipe,Anna`. People pick their name; there are no passwords. Use only on a network you trust (a tailnet, your home LAN). |
| `OIDC_ISSUER`, `OIDC_CLIENT_ID`, `OIDC_CLIENT_SECRET`, `APP_URL` | Log in with an OIDC provider such as PocketID. Used when `HOUSEHOLD_USERS` is not set. |
| `TZ` | Fallback timezone, e.g. `Europe/London`. Each browser reports its own timezone, and times are entered and shown on that clock, so this only applies before the first page load finishes or if cookies are blocked. Defaults to UTC. |
| `ASSUME_SSL` / `FORCE_SSL` | Set to `true` when HTTPS is terminated in front of the app (e.g. `tailscale serve`). |
| `SECRET_KEY_BASE` | Optional. Generated on first boot and stored in the data volume if unset. |
| `DATA_DIR` | Where the SQLite databases live. Defaults to `/data` in the image. Mount it as a volume. |

The app refuses to start if neither `HOUSEHOLD_USERS` nor all four OIDC variables are set.

### PocketID

Create an OIDC client in PocketID with the redirect URI `APP_URL/auth/oidc/callback`
(for example `https://sol.your-tailnet.ts.net/auth/oidc/callback`), then set the four
`OIDC_*`/`APP_URL` variables. Users are created on their first login and their name comes
from the `name` claim (falling back to email).

## First use

1. Add a child.
2. Add their medicines: dose, minimum minutes between doses, and maximum doses per 24 hours.
   Sol shows whatever limits you enter. Check them with your doctor or pharmacist.
3. Use **Give dose** and **Log temperature**. Both accept a time in the past.

A dose that is not allowed yet is still recordable ("Record anyway"), since it may already have been given.
The 24 hour window is rolling: a dose stops counting exactly 24 hours after it was given.

## Development

Needs Ruby 4.0 (see `.ruby-version`).

```sh
bin/setup
bin/rails db:seed    # example child, medicines and readings
bin/dev              # http://localhost:3000, logs in as Felipe or Anna
bin/rails test
```

In development, `HOUSEHOLD_USERS` defaults to `Felipe,Anna`.

### Updating Chart.js

`bin/importmap pin chart.js` downloads only the main file, and jspm splits Chart.js in two.
After re-pinning, fetch the second file and point the first at it:

```sh
curl -sf https://ga.jspm.io/npm:chart.js@<version>/_/<chunk>.js -o vendor/javascript/chart-chunk.js
sed -i '' 's#"\.\./_/<chunk>\.js"#"chart.js/chunk"#' vendor/javascript/chart.js.js
```

`bin/rails test test/importmap_test.rb` fails if a vendored file imports something that isn't pinned.
