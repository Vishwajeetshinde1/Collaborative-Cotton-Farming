# CCF — Collaborative Cotton Farming

A no-build, multi-page HTML/CSS/JavaScript website for CCF under NSL Textiles Limited, with emphasis on the connected **seed-to-fabric** value chain and bale-to-farmer traceability.

## Pages are separate

- `index.html` — clean company homepage, animated seed-to-fabric hero, editable impact figures, four-stage value chain, group organizations and links to the operational pages.
- `traceability.html` — farmer directory, processed lots, detail pages for farmer/lot/bale records, QR preview, add farmer, add lot, search and JSON export.
- `calculators.html` — live cotton candy/outturn estimator and procurement profit/loss calculator.
- `settings.html` — edit homepage figures, configure the public QR destination, import/export records, and restore defaults from the code data file.

Each page has its own CSS and JavaScript file. Shared styles and data helpers are kept separate.

## Project structure

```text
ccf-seed-to-cloth-website/
├── index.html
├── traceability.html
├── calculators.html
├── settings.html
├── css/
│   ├── common.css
│   ├── home.css
│   ├── traceability.css
│   ├── calculators.css
│   └── settings.css
├── js/
│   ├── data.js
│   ├── store.js
│   ├── common.js
│   ├── home.js
│   ├── traceability.js
│   ├── calculators.js
│   └── settings.js
├── assets/
│   ├── ccf-mark.svg
│   ├── nuziveedu-seeds-wordmark.svg
│   └── images/
│       ├── ccf-brand-banner.jpg
│       └── nsl-textiles-logo.png
├── supabase-schema.sql
└── README.md
```

## How to edit your website in GitHub

### Change homepage numbers

Open `js/data.js` and update the `metrics` values near the top:

```js
metrics: { farmers: 1248, acres: 3860, cotton: 2485, bales: 6420 },
```

These values feed the homepage metrics and the starter dataset used by **Restore code defaults** in `settings.html`.

### Add or change a farmer in code

In `js/data.js`, edit the `farmers: [ ... ]` list. A farmer item looks like this:

```js
{
  id: 'FARM-013',
  name: 'Farmer Name',
  contact: 'Phone number',
  village: 'Village',
  mandal: 'Mandal',
  district: 'District',
  state: 'State',
  hybrid: 'Seed variety',
  acres: 4.5,
  sowingDate: '2026-06-18',
  quality: {
    moisture: 8.0,
    micronaire: 4.1,
    stapleLength: 29.0,
    strength: 30.0,
    uniformity: 82.0,
    trash: 2.0,
    hviReport: 'HVI-REPORT-ID'
  }
}
```

Keep IDs unique. For direct editing, match the existing field names and use a comma between objects. Change the sample fields to authorized, verified company data.

### Add a processed lot in code

Edit the `lots: [ ... ]` list in `js/data.js`. A lot includes `id`, `name`, `date`, `district`, `state`, `hybrid`, `seedCottonKg`, `moisture`, `got`, `status`, `farmerIds`, `quality` and `bales`. Each bale has its own stable `id` and may link to `farmerId`.

### Important: reload code defaults after editing

The browser caches its current working dataset in `localStorage`. After changing `js/data.js` in GitHub and deploying, open **Data & QR settings → Restore code defaults** to load your new code defaults. This intentionally replaces the current browser's locally saved edits, so export a JSON backup first if you need to keep them. Code defaults do not automatically overwrite local changes.

## Use the pages without editing code

- Use **Traceability → Add record** to add a farmer or processed lot and automatically generate bale IDs.
- Open a farmer, lot or bale to view the trace report.
- Use **Data & QR settings** to update the four homepage figures or save a public website URL.
- Export a JSON backup before importing another dataset; importing replaces the current browser data.
- Use **Calculators** for live estimates; outputs update as the inputs change.

## Preview and deploy

You can open `index.html` directly, but a local web server is better for testing. From this folder run:

```bash
python -m http.server 8000
```

Then open `http://localhost:8000`. Commit the full project folder to GitHub and deploy the folder through GitHub Pages or your existing static host. QR labels intended for farmers must point to a publicly accessible HTTPS deployment, not to localhost or a local file.

## QR behavior and privacy

The QR links are designed to open a static, contact-free snapshot of bale/lot/farmer provenance. QR images are currently rendered through an external QR service, so network access is needed to display or download an image. The QR payload excludes farmer contact details. Snapshot URLs can be long, can be copied, and are **not cryptographically signed or tamper-proof**. Data embedded in the link reflects the time that QR URL was generated and may not update when the record changes.

The website saves records in `localStorage` for the current browser only. Different employee devices do not synchronize data, and there is no login, role-based access or server-side audit log. It is a front-end prototype, not ready for production handling of private farmer data. Production traceability should use a backend database, authenticated staff access, public endpoints that reveal only approved fields, stable server-resolved QR IDs and audit logs.

## Branding assets

The uploaded CCF/NSL banner and NSL Textiles transparent image have been included as provided. The Nuziveedu Seeds SVG is a locally styled placeholder inherited from the prototype, not an official approved logo. Replace it with a brand-approved logo file before public launch if required. The CCF mark used in the site navigation is also a simple editable brand mark; use official assets wherever the company requires them.

All farmer names, phone strings, acre counts, lots, bale IDs, dates and fiber measurements in `js/data.js` are **illustrative demo data**. Replace with approved records before public use. Verify every HVI reference against the original lab report.

## Calculator assumptions

- Outturn: dry mass = incoming seed cotton kg × (1 − moisture %); lint kg = dry mass × GOT %; candy equivalents = lint kg ÷ entered candy weight; bale equivalents = lint kg ÷ entered bale weight.
- Procurement P&L: procurement cost = incoming quintals × purchase price; processing/other costs are per input quintal; lint revenue uses theoretical lint bale equivalents; seed revenue uses estimated non-lint dry mass.

Actual recovery, trash, weight conventions, freight, taxes, financing, quality premiums and the mill's moisture/GOT accounting basis can change settlement results. Confirm the assumptions with the CCF ginning/accounts team before using the calculator in production.
