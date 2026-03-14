-- Enforce referential integrity for all declared foreign keys.
PRAGMA foreign_keys = ON;

-- users: account-level profile and authentication identities.
CREATE TABLE IF NOT EXISTS users (
	-- Stable internal identifier for a user.
	user_id INTEGER PRIMARY KEY,
	-- Login/contact email (uniqueness for active users is enforced by index below).
	email TEXT NOT NULL,
	-- User's given name.
	name_first TEXT,
	-- User's family name.
	name_last TEXT,
	-- Optional display/full name.
	name TEXT,
	-- Admin authorization flag (0 = false, 1 = true).
	admin INTEGER NOT NULL DEFAULT 0 CHECK (admin IN (0, 1)),
	-- Password hash for local auth.
	password_hash TEXT,
	-- OAuth subject/identifier for Google sign-in.
	google_id TEXT,
	-- OAuth subject/identifier for Microsoft sign-in.
	microsoft_id TEXT,
	-- Soft-delete timestamp; NULL means active.
	deleted_at TEXT
);

-- addresses: reusable shipping/billing addresses owned by a user.
CREATE TABLE IF NOT EXISTS addresses (
	-- Owning user id.
	user_id INTEGER NOT NULL,
	-- Address identifier scoped to a user.
	address_id INTEGER NOT NULL,
	-- Primary street line.
	line_1 TEXT NOT NULL,
	-- Secondary street line (apt/suite/etc.).
	line_2 TEXT,
	-- City/locality.
	city TEXT NOT NULL,
	-- State/province/region.
	state TEXT NOT NULL,
	-- Postal/ZIP code.
	zip_code TEXT NOT NULL,
	-- Country code/name.
	country TEXT NOT NULL,
	-- Soft-delete timestamp; NULL means active.
	deleted_at TEXT,
	-- Composite PK keeps address ids unique per user.
	PRIMARY KEY (user_id, address_id),
	-- Address must belong to a valid user.
	FOREIGN KEY (user_id) REFERENCES users (user_id)
);

-- payment_methods: tokenized customer payment instruments.
CREATE TABLE IF NOT EXISTS payment_methods (
	-- Owning user id.
	user_id INTEGER NOT NULL,
	-- Payment method identifier scoped to a user.
	payment_method_id INTEGER NOT NULL,
	-- Payment provider name (e.g., stripe).
	provider TEXT NOT NULL,
	-- Provider-specific payment method identifier/token.
	provider_payment_method_id TEXT NOT NULL,
	-- Last 4 digits for display/reference.
	last4 TEXT,
	-- Expiration month.
	exp_month INTEGER,
	-- Expiration year.
	exp_year INTEGER,
	-- Row creation timestamp.
	created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
	-- Last update timestamp.
	updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
	-- Soft-delete timestamp; NULL means active.
	deleted_at TEXT,
	-- Composite PK keeps payment ids unique per user.
	PRIMARY KEY (user_id, payment_method_id),
	-- Prevent duplicate provider method attachment for same user.
	UNIQUE (user_id, provider, provider_payment_method_id),
	-- Enforce 4-digit format when present.
	CHECK (last4 IS NULL OR length(last4) = 4),
	-- Valid month range when present.
	CHECK (exp_month IS NULL OR (exp_month BETWEEN 1 AND 12)),
	-- Reasonable year floor when present.
	CHECK (exp_year IS NULL OR exp_year >= 2000),
	-- Payment method must belong to an existing user.
	FOREIGN KEY (user_id) REFERENCES users (user_id)
);

-- orders: order header, payment snapshot fields, and lifecycle status.
CREATE TABLE IF NOT EXISTS orders (
	-- Owning user id.
	user_id INTEGER NOT NULL,
	-- Order identifier scoped to user.
	order_id INTEGER NOT NULL,
	-- Current order lifecycle status.
	status TEXT NOT NULL CHECK (status IN ('draft', 'pending', 'paid', 'in_production', 'shipped', 'completed', 'cancelled', 'refunded')),
	-- Order creation/business date.
	date TEXT NOT NULL,
	-- Chosen address id snapshot reference.
	address_id INTEGER,
	-- Chosen payment method id snapshot reference.
	payment_method_id INTEGER,
	-- Payment brand snapshot (e.g., visa).
	payment_brand TEXT,
	-- Payment last4 snapshot.
	payment_last4 TEXT,
	-- Payment expiration month snapshot.
	payment_exp_month INTEGER,
	-- Payment expiration year snapshot.
	payment_exp_year INTEGER,
	-- Order total in cents.
	total_cents INTEGER NOT NULL DEFAULT 0 CHECK (total_cents >= 0),
	-- ISO currency code.
	currency TEXT NOT NULL DEFAULT 'USD' CHECK (length(currency) = 3 AND currency = upper(currency)),
	-- Soft-delete timestamp; NULL means active.
	deleted_at TEXT,
	-- Composite PK keeps order ids unique per user.
	PRIMARY KEY (user_id, order_id),
	-- Enforce 4-digit snapshot when present.
	CHECK (payment_last4 IS NULL OR length(payment_last4) = 4),
	-- Valid month range when present.
	CHECK (payment_exp_month IS NULL OR (payment_exp_month BETWEEN 1 AND 12)),
	-- Reasonable year floor when present.
	CHECK (payment_exp_year IS NULL OR payment_exp_year >= 2000),
	-- Order must belong to an existing user.
	FOREIGN KEY (user_id) REFERENCES users (user_id),
	-- Referenced address must exist for that user.
	FOREIGN KEY (user_id, address_id) REFERENCES addresses (user_id, address_id),
	-- Referenced payment method must exist for that user.
	FOREIGN KEY (user_id, payment_method_id) REFERENCES payment_methods (user_id, payment_method_id)
);

-- default_shipping_addresses: one default shipping address per user.
CREATE TABLE IF NOT EXISTS default_shipping_addresses (
	-- User id (and PK to enforce one row per user).
	user_id INTEGER PRIMARY KEY,
	-- Default shipping address id for the user.
	address_id INTEGER NOT NULL,
	-- User must exist.
	FOREIGN KEY (user_id) REFERENCES users (user_id),
	-- Address must exist and belong to same user.
	FOREIGN KEY (user_id, address_id) REFERENCES addresses (user_id, address_id)
);

-- default_billing_addresses: one default billing address per user.
CREATE TABLE IF NOT EXISTS default_billing_addresses (
	-- User id (and PK to enforce one row per user).
	user_id INTEGER PRIMARY KEY,
	-- Default billing address id for the user.
	address_id INTEGER NOT NULL,
	-- User must exist.
	FOREIGN KEY (user_id) REFERENCES users (user_id),
	-- Address must exist and belong to same user.
	FOREIGN KEY (user_id, address_id) REFERENCES addresses (user_id, address_id)
);

-- default_payment_methods: one default payment method per user.
CREATE TABLE IF NOT EXISTS default_payment_methods (
	-- User id (and PK to enforce one row per user).
	user_id INTEGER PRIMARY KEY,
	-- Default payment method id for the user.
	payment_method_id INTEGER NOT NULL,
	-- User must exist.
	FOREIGN KEY (user_id) REFERENCES users (user_id),
	-- Payment method must exist and belong to same user.
	FOREIGN KEY (user_id, payment_method_id) REFERENCES payment_methods (user_id, payment_method_id)
);

-- product_categories: catalog categorization layer (e.g., stickers).
CREATE TABLE IF NOT EXISTS product_categories (
	-- Stable category identifier.
	product_category_id INTEGER PRIMARY KEY,
	-- Machine-friendly unique category code.
	code TEXT NOT NULL UNIQUE,
	-- Human-readable category name.
	name TEXT NOT NULL
);

-- products: sellable catalog products.
CREATE TABLE IF NOT EXISTS products (
	-- Stable product identifier.
	product_id INTEGER PRIMARY KEY,
	-- Category classification.
	product_category_id INTEGER NOT NULL,
	-- Optional merchant SKU.
	sku TEXT,
	-- Product name.
	name TEXT NOT NULL,
	-- Product description.
	description TEXT,
	-- Active listing flag (0 = inactive, 1 = active).
	active INTEGER NOT NULL DEFAULT 1 CHECK (active IN (0, 1)),
	-- Row creation timestamp.
	created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
	-- Last update timestamp.
	updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
	-- Soft-delete timestamp; NULL means active.
	deleted_at TEXT,
	-- Product category must exist.
	FOREIGN KEY (product_category_id) REFERENCES product_categories (product_category_id)
);

-- product_designs: design identity with pointer to current approved version.
CREATE TABLE IF NOT EXISTS product_designs (
	-- Stable design identifier.
	design_id INTEGER PRIMARY KEY,
	-- Owning product.
	product_id INTEGER NOT NULL,
	-- Current active version number for this design.
	current_version INTEGER CHECK (current_version IS NULL OR current_version >= 1),
	-- Row creation timestamp.
	created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
	-- Last update timestamp.
	updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
	-- Soft-delete timestamp; NULL means active.
	deleted_at TEXT,
	-- Design must belong to an existing product.
	FOREIGN KEY (product_id) REFERENCES products (product_id),
	-- Current version must match an existing version row for this design.
	FOREIGN KEY (design_id, current_version) REFERENCES product_design_versions (design_id, version)
);

-- product_design_versions: immutable version history for design files/specs.
CREATE TABLE IF NOT EXISTS product_design_versions (
	-- Parent design identifier.
	design_id INTEGER NOT NULL,
	-- Version number within a design.
	version INTEGER NOT NULL CHECK (version >= 1),
	-- Internal source/production file location.
	file_url TEXT NOT NULL,
	-- JSON specification payload for this version.
	specifications TEXT NOT NULL CHECK (json_valid(specifications)),
	-- Version creation timestamp.
	created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
	-- Composite PK enforces unique version per design.
	PRIMARY KEY (design_id, version),
	-- Version row must attach to an existing design.
	FOREIGN KEY (design_id) REFERENCES product_designs (design_id)
);

-- order_items: line items that bind an order to an exact design version.
CREATE TABLE IF NOT EXISTS order_items (
	-- Owning user id.
	user_id INTEGER NOT NULL,
	-- Owning order id.
	order_id INTEGER NOT NULL,
	-- Line item id scoped to order.
	order_item_id INTEGER NOT NULL,
	-- Ordered design id.
	design_id INTEGER NOT NULL,
	-- Ordered design version.
	design_version INTEGER NOT NULL CHECK (design_version >= 1),
	-- Quantity ordered.
	quantity INTEGER NOT NULL CHECK (quantity > 0),
	-- Line subtotal in cents (source of truth).
	line_total_cents INTEGER NOT NULL CHECK (line_total_cents >= 0),
	-- Computed line subtotal in dollars.
	line_total_dollars REAL GENERATED ALWAYS AS (line_total_cents / 100.0) VIRTUAL,
	-- Computed per-unit price in cents.
	unit_price_cents REAL GENERATED ALWAYS AS (line_total_cents * 1.0 / quantity) VIRTUAL,
	-- Computed per-unit price in dollars.
	unit_price_dollars REAL GENERATED ALWAYS AS (unit_price_cents / 100.0) VIRTUAL,
	-- Soft-delete timestamp; NULL means active.
	deleted_at TEXT,
	-- Composite PK keeps line ids unique per order.
	PRIMARY KEY (user_id, order_id, order_item_id),
	-- Line item must belong to an existing order.
	FOREIGN KEY (user_id, order_id) REFERENCES orders (user_id, order_id),
	-- Ordered design version must exist.
	FOREIGN KEY (design_id, design_version) REFERENCES product_design_versions (design_id, version)
);

-- order_status_history: immutable event log of status changes over time.
CREATE TABLE IF NOT EXISTS order_status_history (
	-- Owning user id.
	user_id INTEGER NOT NULL,
	-- Owning order id.
	order_id INTEGER NOT NULL,
	-- Event id scoped to order.
	status_event_id INTEGER NOT NULL,
	-- Status value recorded at this event.
	status TEXT NOT NULL CHECK (status IN ('draft', 'pending', 'paid', 'in_production', 'shipped', 'completed', 'cancelled', 'refunded')),
	-- Optional note explaining transition.
	notes TEXT,
	-- Event creation timestamp.
	created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
	-- Soft-delete timestamp; NULL means active.
	deleted_at TEXT,
	-- Composite PK keeps history events unique per order.
	PRIMARY KEY (user_id, order_id, status_event_id),
	-- Event must belong to an existing order.
	FOREIGN KEY (user_id, order_id) REFERENCES orders (user_id, order_id)
);

-- shipments: shipment records and tracking lifecycle for orders.
CREATE TABLE IF NOT EXISTS shipments (
	-- Owning user id.
	user_id INTEGER NOT NULL,
	-- Owning order id.
	order_id INTEGER NOT NULL,
	-- Shipment id scoped to order.
	shipment_id INTEGER NOT NULL,
	-- Carrier name.
	carrier TEXT,
	-- Service level (ground, priority, etc.).
	service_level TEXT,
	-- Carrier tracking number.
	tracking_number TEXT,
	-- Tracking URL for customer/support.
	tracking_url TEXT,
	-- Shipping label cost in cents.
	label_cost_cents INTEGER CHECK (label_cost_cents IS NULL OR label_cost_cents >= 0),
	-- Time parcel was shipped.
	shipped_at TEXT,
	-- Time parcel was delivered.
	delivered_at TEXT,
	-- Row creation timestamp.
	created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
	-- Last update timestamp.
	updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
	-- Soft-delete timestamp; NULL means active.
	deleted_at TEXT,
	-- Composite PK keeps shipment ids unique per order.
	PRIMARY KEY (user_id, order_id, shipment_id),
	-- Shipment must belong to an existing order.
	FOREIGN KEY (user_id, order_id) REFERENCES orders (user_id, order_id),
	-- Delivery cannot precede shipment when both exist.
	CHECK (delivered_at IS NULL OR shipped_at IS NULL OR delivered_at >= shipped_at)
);

-- design_proof_approvals: customer proof exchange and approval decisions.
CREATE TABLE IF NOT EXISTS design_proof_approvals (
	-- Owning user id.
	user_id INTEGER NOT NULL,
	-- Owning order id.
	order_id INTEGER NOT NULL,
	-- Proof id scoped to order.
	proof_id INTEGER NOT NULL,
	-- Related design id.
	design_id INTEGER NOT NULL,
	-- Related design version shown for review.
	design_version INTEGER NOT NULL CHECK (design_version >= 1),
	-- Customer-facing proof asset URL.
	proof_file_url TEXT NOT NULL,
	-- Proof review status.
	status TEXT NOT NULL CHECK (status IN ('sent', 'approved', 'rejected', 'superseded')),
	-- Name of reviewer/contact.
	reviewer_name TEXT,
	-- Email of reviewer/contact.
	reviewer_email TEXT,
	-- Optional feedback or rationale.
	reviewer_notes TEXT,
	-- Timestamp of customer review decision.
	reviewed_at TEXT,
	-- Row creation timestamp.
	created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
	-- Soft-delete timestamp; NULL means active.
	deleted_at TEXT,
	-- Composite PK keeps proof ids unique per order.
	PRIMARY KEY (user_id, order_id, proof_id),
	-- Proof row must belong to an existing order.
	FOREIGN KEY (user_id, order_id) REFERENCES orders (user_id, order_id),
	-- Proof must reference a valid design version.
	FOREIGN KEY (design_id, design_version) REFERENCES product_design_versions (design_id, version)
);

-- production_jobs: internal manufacturing workflow tracking per order/item.
CREATE TABLE IF NOT EXISTS production_jobs (
	-- Stable internal production job identifier.
	job_id INTEGER PRIMARY KEY,
	-- Owning user id.
	user_id INTEGER NOT NULL,
	-- Owning order id.
	order_id INTEGER NOT NULL,
	-- Optional line item id this job is tied to.
	order_item_id INTEGER,
	-- Type of production step.
	job_type TEXT NOT NULL CHECK (job_type IN ('print', 'cut', 'laminate', 'pack')),
	-- Workflow status for this job.
	status TEXT NOT NULL CHECK (status IN ('queued', 'in_progress', 'completed', 'blocked', 'cancelled')),
	-- Machine identifier/name.
	machine_name TEXT,
	-- Material descriptor.
	material TEXT,
	-- Operator user id handling the job.
	operator_user_id INTEGER,
	-- Target due time.
	due_at TEXT,
	-- Start time.
	started_at TEXT,
	-- Completion time.
	completed_at TEXT,
	-- Freeform internal notes.
	notes TEXT,
	-- Row creation timestamp.
	created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
	-- Last update timestamp.
	updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
	-- Soft-delete timestamp; NULL means active.
	deleted_at TEXT,
	-- Job must belong to an existing order.
	FOREIGN KEY (user_id, order_id) REFERENCES orders (user_id, order_id),
	-- If line item is provided, it must exist.
	FOREIGN KEY (user_id, order_id, order_item_id) REFERENCES order_items (user_id, order_id, order_item_id),
	-- Operator must be a valid user.
	FOREIGN KEY (operator_user_id) REFERENCES users (user_id),
	-- Completion cannot precede start when both exist.
	CHECK (completed_at IS NULL OR started_at IS NULL OR completed_at >= started_at)
);

-- Index for fetching a user's orders by date (recent-first query support).
CREATE INDEX IF NOT EXISTS idx_orders_user_date
	ON orders (user_id, date);

-- Index for filtering a user's orders by current status.
CREATE INDEX IF NOT EXISTS idx_orders_user_status
	ON orders (user_id, status);

-- Index for resolving orders by selected address.
CREATE INDEX IF NOT EXISTS idx_orders_user_address
	ON orders (user_id, address_id);

-- Index for resolving orders by selected payment method.
CREATE INDEX IF NOT EXISTS idx_orders_user_payment_method
	ON orders (user_id, payment_method_id);

-- Index to accelerate active/soft-deleted user filters.
CREATE INDEX IF NOT EXISTS idx_users_deleted_at
	ON users (deleted_at);

-- Active-only uniqueness for user emails under soft-delete policy.
CREATE UNIQUE INDEX IF NOT EXISTS uq_users_email_active
	ON users (email)
	WHERE deleted_at IS NULL;

-- Index to accelerate active/soft-deleted address filters.
CREATE INDEX IF NOT EXISTS idx_addresses_deleted_at
	ON addresses (deleted_at);

-- Index to accelerate active/soft-deleted payment method filters.
CREATE INDEX IF NOT EXISTS idx_payment_methods_deleted_at
	ON payment_methods (deleted_at);

-- Index to accelerate active/soft-deleted order filters.
CREATE INDEX IF NOT EXISTS idx_orders_deleted_at
	ON orders (deleted_at);

-- Index for loading all line items on an order.
CREATE INDEX IF NOT EXISTS idx_order_items_order
	ON order_items (user_id, order_id);

-- Index for finding order items by design.
CREATE INDEX IF NOT EXISTS idx_order_items_design
	ON order_items (design_id);

-- Index for finding order items by exact design version.
CREATE INDEX IF NOT EXISTS idx_order_items_design_version
	ON order_items (design_id, design_version);

-- Index for browsing products within category.
CREATE INDEX IF NOT EXISTS idx_products_category
	ON products (product_category_id);

-- Index for listing active/inactive products.
CREATE INDEX IF NOT EXISTS idx_products_active
	ON products (active);

-- Index to accelerate active/soft-deleted product filters.
CREATE INDEX IF NOT EXISTS idx_products_deleted_at
	ON products (deleted_at);

-- Active-only uniqueness for SKU under soft-delete policy.
CREATE UNIQUE INDEX IF NOT EXISTS uq_products_sku_active
	ON products (sku)
	WHERE deleted_at IS NULL AND sku IS NOT NULL;

-- Index for retrieving designs for a product.
CREATE INDEX IF NOT EXISTS idx_product_designs_product
	ON product_designs (product_id);

-- Index to accelerate active/soft-deleted design filters.
CREATE INDEX IF NOT EXISTS idx_product_designs_deleted_at
	ON product_designs (deleted_at);

-- Index for product designs ordered by current version.
CREATE INDEX IF NOT EXISTS idx_product_designs_product_current_version
	ON product_designs (product_id, current_version DESC);

-- Index for retrieving version history in reverse creation order.
CREATE INDEX IF NOT EXISTS idx_product_design_versions_design_created
	ON product_design_versions (design_id, created_at DESC);

-- Index to accelerate active/soft-deleted line item filters.
CREATE INDEX IF NOT EXISTS idx_order_items_deleted_at
	ON order_items (deleted_at);

-- Index for querying order status history timeline per order.
CREATE INDEX IF NOT EXISTS idx_order_status_history_order
	ON order_status_history (user_id, order_id, created_at DESC);

-- Index for querying orders/events by status value.
CREATE INDEX IF NOT EXISTS idx_order_status_history_status
	ON order_status_history (status);

-- Index to accelerate active/soft-deleted status-event filters.
CREATE INDEX IF NOT EXISTS idx_order_status_history_deleted_at
	ON order_status_history (deleted_at);

-- Index for loading shipments on an order.
CREATE INDEX IF NOT EXISTS idx_shipments_order
	ON shipments (user_id, order_id);

-- Partial index for tracking lookups when tracking number is set.
CREATE INDEX IF NOT EXISTS idx_shipments_tracking_number
	ON shipments (tracking_number)
	WHERE tracking_number IS NOT NULL;

-- Index to accelerate active/soft-deleted shipment filters.
CREATE INDEX IF NOT EXISTS idx_shipments_deleted_at
	ON shipments (deleted_at);

-- Index for proof timeline per order.
CREATE INDEX IF NOT EXISTS idx_design_proof_approvals_order
	ON design_proof_approvals (user_id, order_id, created_at DESC);

-- Index for proof lookups by exact design version.
CREATE INDEX IF NOT EXISTS idx_design_proof_approvals_design_version
	ON design_proof_approvals (design_id, design_version);

-- Index for filtering proofs by decision status.
CREATE INDEX IF NOT EXISTS idx_design_proof_approvals_status
	ON design_proof_approvals (status);

-- Index to accelerate active/soft-deleted proof filters.
CREATE INDEX IF NOT EXISTS idx_design_proof_approvals_deleted_at
	ON design_proof_approvals (deleted_at);

-- Index for loading all production jobs on an order.
CREATE INDEX IF NOT EXISTS idx_production_jobs_order
	ON production_jobs (user_id, order_id);

-- Index for loading production jobs by line item.
CREATE INDEX IF NOT EXISTS idx_production_jobs_order_item
	ON production_jobs (user_id, order_id, order_item_id);

-- Index for workflow queue filtering by job status.
CREATE INDEX IF NOT EXISTS idx_production_jobs_status
	ON production_jobs (status);

-- Index for scheduling/queueing by due timestamp.
CREATE INDEX IF NOT EXISTS idx_production_jobs_due_at
	ON production_jobs (due_at);

-- Index to accelerate active/soft-deleted production job filters.
CREATE INDEX IF NOT EXISTS idx_production_jobs_deleted_at
	ON production_jobs (deleted_at);

-- Seed default category for current business model.
INSERT OR IGNORE INTO product_categories (code, name)
VALUES ('stickers', 'Stickers');
