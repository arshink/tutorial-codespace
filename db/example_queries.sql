-- example_queries.sql
USE product_inventory;

-- 1) Search products by attribute (manufacturer) using generated column
SELECT id, sku_master, name, JSON_EXTRACT(attributes, '$.color') AS color
FROM product
WHERE manufacturer = 'Acme Corp';

-- 2) Find total inventory for an SKU across all locations
SELECT s.sku_code, SUM(ii.quantity) AS total_qty
FROM sku s
JOIN inventory_item ii ON ii.sku_id = s.id
WHERE s.sku_code = 'SKU-12345'
GROUP BY s.sku_code;

-- 3) Reserve stock transactionally (simple example)
-- Business assumption: reservation reduces available quantity immediately.
START TRANSACTION;

-- lock the inventory row
SELECT * FROM inventory_item
WHERE sku_id = 1 AND location_id = 1 FOR UPDATE;

-- check quantity and update
UPDATE inventory_item
SET quantity = quantity - 2
WHERE sku_id = 1 AND location_id = 1 AND quantity >= 2;

-- insert audit transaction
INSERT INTO stock_transaction (inventory_item_id, txn_type, qty_delta, metadata)
VALUES (1, 'reserve', -2, JSON_OBJECT('order_id', 'ORD-1001'));

COMMIT;

-- 4) Consume FIFO lots stored in JSON 'lots_batches' (conceptual)
-- lots_batches example: [{"lot":"L1","qty":10,"received_at":"2026-01-12"}, {...}]
-- Pseudocode / approach: read JSON, iterate oldest lots in app code, update lots_batches JSON and inventory_item.quantity, and insert stock_transaction entries.

-- 5) Create a PO with lines stored as JSON
INSERT INTO purchase_order (supplier_id, po_number, lines, status)
VALUES (1, 'PO-2026-0001',
  JSON_ARRAY(JSON_OBJECT('sku_id', 1, 'qty', 100, 'unit_cost', 5.25)),
  'open');

-- 6) Receive PO lines and update inventory (example for one line)
START TRANSACTION;
-- find or create inventory_item for sku/location
INSERT INTO inventory_item (sku_id, location_id, quantity, lots_batches)
VALUES (1, 1, 100, JSON_ARRAY(JSON_OBJECT('lot','L2026-01-01','qty',100,'received_at',NOW())))
ON DUPLICATE KEY UPDATE quantity = quantity + VALUES(quantity),
lots_batches = JSON_ARRAY_APPEND(COALESCE(lots_batches, JSON_ARRAY()), '$', JSON_OBJECT('lot','L2026-01-01','qty',100,'received_at',NOW()));

-- insert stock transaction
INSERT INTO stock_transaction (inventory_item_id, txn_type, qty_delta, metadata)
VALUES (LAST_INSERT_ID(), 'po_receipt', 100, JSON_OBJECT('po_number','PO-2026-0001','sku_id',1));

COMMIT;

-- 7) Audit: get all transactions for an SKU in date range
SELECT st.*
FROM stock_transaction st
JOIN inventory_item ii ON st.inventory_item_id = ii.id
JOIN sku s ON ii.sku_id = s.id
WHERE s.sku_code = 'SKU-12345' AND st.txn_at BETWEEN '2026-01-01' AND '2026-12-31'
ORDER BY st.txn_at;
