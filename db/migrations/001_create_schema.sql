-- 001_create_schema.sql
-- Hybrid relational + JSON schema for Products & Inventory

CREATE DATABASE IF NOT EXISTS product_inventory;
USE product_inventory;

CREATE TABLE product (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  sku_master VARCHAR(100) NOT NULL,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  attributes JSON NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX (sku_master),
  FULLTEXT KEY ft_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE sku (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  product_id BIGINT NOT NULL,
  sku_code VARCHAR(100) NOT NULL,
  barcode VARCHAR(128),
  sku_attributes JSON NULL,
  weight DECIMAL(10,3),
  length DECIMAL(10,3),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (product_id) REFERENCES product(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE category (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(150) NOT NULL,
  description TEXT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE product_category (
  product_id BIGINT NOT NULL,
  category_id BIGINT NOT NULL,
  PRIMARY KEY (product_id, category_id),
  FOREIGN KEY (product_id) REFERENCES product(id) ON DELETE CASCADE,
  FOREIGN KEY (category_id) REFERENCES category(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE inventory_location (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  code VARCHAR(50) UNIQUE,
  name VARCHAR(255),
  type VARCHAR(50),
  metadata JSON NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE inventory_item (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  sku_id BIGINT NOT NULL,
  location_id BIGINT NOT NULL,
  quantity INT NOT NULL DEFAULT 0,
  lots_batches JSON NULL,
  last_counted_at DATETIME NULL,
  FOREIGN KEY (sku_id) REFERENCES sku(id) ON DELETE CASCADE,
  FOREIGN KEY (location_id) REFERENCES inventory_location(id) ON DELETE CASCADE,
  UNIQUE KEY ux_sku_location (sku_id, location_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE stock_transaction (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  inventory_item_id BIGINT NOT NULL,
  txn_type VARCHAR(50) NOT NULL,
  qty_delta INT NOT NULL,
  txn_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  metadata JSON NULL,
  FOREIGN KEY (inventory_item_id) REFERENCES inventory_item(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE supplier (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  contact JSON NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE purchase_order (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  supplier_id BIGINT,
  po_number VARCHAR(100) NOT NULL,
  po_lines JSON NULL,
  status VARCHAR(50),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (supplier_id) REFERENCES supplier(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Example: create generated column from JSON 'attributes.manufacturer' and index it
ALTER TABLE product
  ADD COLUMN manufacturer VARCHAR(200) GENERATED ALWAYS AS (JSON_UNQUOTE(JSON_EXTRACT(attributes, '$.manufacturer'))) STORED;
CREATE INDEX idx_product_manufacturer ON product(manufacturer);

-- Example: index a SKU JSON attribute (color)
ALTER TABLE sku
  ADD COLUMN color VARCHAR(100) GENERATED ALWAYS AS (JSON_UNQUOTE(JSON_EXTRACT(sku_attributes, '$.color'))) STORED;
CREATE INDEX idx_sku_color ON sku(color);

-- Notes:
-- - Use transactions when updating inventory_item.quantity and inserting stock_transaction to keep balances consistent.
-- - Consider partitioning stock_transaction by date for very large volumes.
-- - Use application-level logic or stored procedures to enforce lot FIFO when consuming lots in JSON 'lots_batches'.
