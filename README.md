# Sticker Haven Website

Sticker Haven Website is a SvelteKit storefront for a custom sticker business. It includes public-facing marketing pages, reusable UI components, and Cloudflare-ready deployment/configuration so the app can run on edge infrastructure.

## Project overview

- Framework: SvelteKit + Vite + TypeScript
- Hosting/runtime target: Cloudflare (Wrangler + Cloudflare adapter)
- Data layer: Cloudflare D1 with SQL migrations in `migrations/`
- Testing: Playwright end-to-end tests in `e2e/`

## Key folders

- `src/routes/`: pages and route-level layouts
- `src/Components/`: reusable UI components
- `src/Collections/`: shared page sections (header, footer, announcements)
- `migrations/`: database schema migrations
- `static/`: static assets (images, fonts, robots file)

## Styling file structure

Global styles are loaded from the route layout:

- `src/routes/+layout.svelte` imports `src/layout.scss`

The top-level stylesheet is an aggregator:

- `src/layout.scss`
    - `@use './styles/fonts'`
    - `@use './styles/reset'`
    - `@use './styles/theme'`
    - `@use './styles/content'`

Style modules are grouped by type:

- `src/styles/fonts.scss`: `@font-face` declarations
- `src/styles/reset.scss`: base/reset and element normalization
- `src/styles/theme.scss`: theme-level aggregator for general elements
    - `src/styles/theme/tokens.scss`: CSS custom properties and theme tokens
    - `src/styles/theme/headings.scss`: `h1`–`h6` styles
    - `src/styles/theme/lists.scss`: list and nav/footer list behavior
    - `src/styles/theme/text.scss`: general text element defaults (for example `p`)
- `src/styles/content.scss`: shared content-layout aggregator
    - `src/styles/content/sections.scss`: content section and layout grids
    - `src/styles/content/utilities.scss`: utility classes (for example `.text-left`)
    - `src/styles/content/tables.scss`: default table styling

Rule of thumb for new styles: keep component-specific styles inside each Svelte component file; use `src/styles/theme/*` only for global element/theme defaults; treat `src/styles/content/sections.scss` as the shared exception for reusable section layout patterns.

## Local development

Install dependencies:

```sh
npm install
```

Start the dev server:

```sh
npm run dev
```

Useful commands:

```sh
npm run check      # type and Svelte checks
npm run lint       # lint + formatting checks
npm run test       # Playwright e2e tests
npm run build      # production build
```

## Deployment

This project is configured for Cloudflare deployment via Wrangler.

Build the app:

```sh
npm run build
```

Preview the Cloudflare worker locally (staging config):

```sh
npm run preview
```

Deploy to Cloudflare:

Before deploying, make sure required staging/production secrets are set with Wrangler (see `Environment variables` below).

```sh
# staging environment
npx wrangler deploy -e staging

# production environment
npx wrangler deploy
```

## Environment variables

This project uses a hybrid approach:

- Local development: `.env`
- Deployed environments (staging/production): Wrangler secrets

### Required Cloudflare bindings

- `DB` (D1 database binding)
    - Production: configured in `wrangler.jsonc` under top-level `d1_databases`
    - Staging: configured in `wrangler.jsonc` under `env.staging.d1_databases`
- `ASSETS` (static asset binding)
    - Configured in `wrangler.jsonc` under `assets.binding`

### .env setup

Create a `.env` file in the project root:

```sh
cp .env.example .env
```

If `.env.example` does not exist yet, create `.env` manually and add your secret values.

Example:

```env
SECRET_API_KEY=your-secret-value
SECRET_WEBHOOK_TOKEN=your-webhook-token
```

Guidelines:

- Keep secrets in `.env` (do not commit real secret values).
- Only use `PUBLIC_` prefix for values that are safe to expose to the browser.
- Restart the dev server after changing `.env` values.

### Deployment secrets (Wrangler)

Set secrets for Cloudflare environments with Wrangler:

```sh
# set production secret
npx wrangler secret put SECRET_NAME

# set staging secret
npx wrangler secret put SECRET_NAME -e staging
```

Use Wrangler secrets for anything required at runtime in deployed Workers.

### Local development behavior

- Run `npm run dev` for local development.
- Database migration commands target local/staging/production based on the script you run.

After adding or changing Cloudflare bindings/secrets, regenerate worker types:

```sh
npm run gen
```

## Database migrations (Cloudflare D1)

- Migrations live in `migrations/`.
- Baseline schema migration: `migrations/0001_initial_schema.sql`.

Create a new migration file:

```sh
npm run db:migrations:create -- <migration_name>
```

Apply migrations:

```sh
# local D1
npm run db:migrate:local

# staging D1 (wrangler env: staging)
npm run db:migrate:staging

# production D1 (remote)
npm run db:migrate:prod
```

List migration status:

```sh
npm run db:migrations:list
```

## How to read the schema

The baseline schema is designed for a self-serve ordering flow and lives in `migrations/0001_initial_schema.sql`.

### Core entities

- `users`: customer accounts.
- `addresses`, `payment_methods`: reusable customer checkout data.
- `orders`: order header/status/total.
- `order_items`: line items tied to an exact `design_id + design_version`.

### Catalog and design model

- `product_categories` and `products`: catalog structure.
- `product_designs`: stable design identity with a pointer to `current_version`.
- `product_design_versions`: immutable version history (`file_url`, `specifications`).

### Customer proof and production flow

- `design_proof_approvals`: proof artifacts sent to customer + approval decision timeline.
- `order_status_history`: immutable status event log for each order.
- `shipments`: carrier/tracking and delivery timestamps.
- `production_jobs`: internal print/cut/laminate/pack workflow tracking.

### Typical order lifecycle

1. User creates an order (`orders`) and line items (`order_items`).
2. Line items reference specific design versions from `product_design_versions`.
3. Proof(s) are sent and tracked in `design_proof_approvals`.
4. Order status changes are appended to `order_status_history`.
5. Internal execution is tracked in `production_jobs`.
6. Fulfillment updates are stored in `shipments`.

### Soft-delete convention

Many tables include `deleted_at`.

- `deleted_at IS NULL` => active row
- `deleted_at IS NOT NULL` => soft-deleted row

Use active-only filters in app queries unless historical records are required.
