# Sticker Haven Website

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
