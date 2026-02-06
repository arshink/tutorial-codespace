Implementation Notes — Hybrid Relational + JSON (MySQL)

1) Transactional integrity
- All inventory quantity updates should occur inside DB transactions that also insert a corresponding `stock_transaction` row for audit.
- Use `SELECT ... FOR UPDATE` to lock `inventory_item` rows when adjusting quantity.

2) JSON usage
- Store flexible product specs and SKU-level attributes in `attributes` and `sku_attributes` JSON.
- Create generated columns and indexes for JSON keys used frequently in WHERE clauses (see migration example).

3) Read models and search
- Build denormalized read tables or push product documents to Elasticsearch for faceted search and fast queries.
- Keep the canonical relational data for writes; update read models asynchronously via triggers or app-level events.

4) Lots and FIFO
- Represent lots/batches as JSON in `lots_batches` for flexibility. For reliable FIFO consumption, implement lot-consumption logic in application code or stored procedures and record each consumption as `stock_transaction` entries.

5) High-volume considerations
- For very high write rates on `stock_transaction`, consider partitioning by time and/or using an append-only NoSQL event store, then materialize balances.

6) Backups and portability
- JSON columns are portable between MySQL versions >=5.7 / 8.0. When migrating, ensure JSON structure compatibility.

7) Example indexes
- `idx_product_manufacturer` on generated `manufacturer` column
- `idx_sku_color` on generated `color` column
- Index `inventory_item (sku_id, location_id)` for fast lookups

8) Queries and safety
- Validate JSON content at the app layer; use JSON_SCHEMA if desired (MySQL 8.0.17+ supports JSON_SCHEMA_VALIDATE via UDFs or application validation).

