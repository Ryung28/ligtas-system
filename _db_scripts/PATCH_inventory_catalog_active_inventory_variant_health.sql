-- Per-site health buckets inside JSON variants + parent qty_* on active_inventory.
-- Applied via Supabase migration `inventory_views_variant_health_buckets` (Apr 2026).
-- Re-run here if you need to align a branch DB manually.

CREATE OR REPLACE VIEW inventory_catalog AS
WITH variant_summary AS (
  SELECT inventory.parent_id,
    jsonb_agg(
      jsonb_build_object(
        'id', inventory.id,
        'location', inventory.storage_location,
        'location_registry_id', inventory.location_registry_id,
        'stock_available', inventory.stock_available,
        'stock_total', inventory.stock_total,
        'status', inventory.status,
        'qty_good', COALESCE(inventory.qty_good, 0),
        'qty_damaged', COALESCE(inventory.qty_damaged, 0),
        'qty_maintenance', COALESCE(inventory.qty_maintenance, 0),
        'qty_lost', COALESCE(inventory.qty_lost, 0)
      ) ORDER BY inventory.id
    ) AS variant_list,
    sum(inventory.stock_available) AS sum_available,
    sum(inventory.stock_total) AS sum_total
  FROM inventory
  WHERE inventory.parent_id IS NOT NULL AND inventory.deleted_at IS NULL
  GROUP BY inventory.parent_id
)
SELECT i.id,
  i.item_name,
  i.category,
  i.description,
  i.image_url,
  i.item_type,
  i.storage_location AS primary_location,
  i.stock_available AS primary_stock_available,
  i.stock_total AS primary_stock_total,
  i.stock_available + COALESCE(vs.sum_available, 0::bigint) AS aggregate_available,
  i.stock_total + COALESCE(vs.sum_total, 0::bigint) AS aggregate_total,
  COALESCE(vs.variant_list, '[]'::jsonb) AS variants,
  i.status,
  (
    SELECT COALESCE(sum(borrow_logs.quantity), 0::bigint)
    FROM borrow_logs
    WHERE borrow_logs.inventory_id = i.id
      AND (borrow_logs.status = ANY (ARRAY['pending'::text, 'staged'::text]))
  ) AS stock_pending
FROM inventory i
LEFT JOIN variant_summary vs ON i.id = vs.parent_id
WHERE i.parent_id IS NULL
  AND i.deleted_at IS NULL
  AND (
    get_user_warehouse() IS NULL
    OR i.storage_location = get_user_warehouse()
    OR (EXISTS (
      SELECT 1 FROM inventory v
      WHERE v.parent_id = i.id AND v.storage_location = get_user_warehouse()
    ))
  );

DROP VIEW IF EXISTS active_inventory;

CREATE VIEW active_inventory AS
WITH variant_summary AS (
  SELECT v.parent_id,
    jsonb_agg(
      jsonb_build_object(
        'id', v.id,
        'location', v.storage_location,
        'location_registry_id', v.location_registry_id,
        'stock_available', v.stock_available,
        'stock_total', v.stock_total,
        'status', v.status,
        'qty_good', COALESCE(v.qty_good, 0),
        'qty_damaged', COALESCE(v.qty_damaged, 0),
        'qty_maintenance', COALESCE(v.qty_maintenance, 0),
        'qty_lost', COALESCE(v.qty_lost, 0)
      ) ORDER BY v.id
    ) AS variant_list,
    sum(v.stock_available) AS sum_available,
    sum(v.stock_total) AS sum_total
  FROM inventory v
  WHERE v.parent_id IS NOT NULL AND v.deleted_at IS NULL
  GROUP BY v.parent_id
)
SELECT
  i.id,
  i.item_name,
  i.category,
  i.stock_total,
  i.stock_available,
  i.stock_available + COALESCE(vs.sum_available, 0::bigint) AS aggregate_available,
  i.stock_total + COALESCE(vs.sum_total, 0::bigint) AS aggregate_total,
  COALESCE(i.qty_good, 0) AS qty_good,
  COALESCE(i.qty_damaged, 0) AS qty_damaged,
  COALESCE(i.qty_maintenance, 0) AS qty_maintenance,
  COALESCE(i.qty_lost, 0) AS qty_lost,
  i.status,
  i.description,
  i.storage_location AS location,
  i.location_registry_id,
  i.qr_code AS "qrCode",
  i.item_code AS code,
  i.low_stock_threshold,
  i.restock_alert_enabled,
  i.unit,
  i.image_url,
  i.model_number,
  i.target_stock,
  i.created_at,
  i.updated_at,
  i.expiry_date,
  COALESCE(vs.variant_list, '[]'::jsonb) AS variants
FROM inventory i
LEFT JOIN variant_summary vs ON i.id = vs.parent_id
WHERE i.deleted_at IS NULL
  AND i.parent_id IS NULL
  AND (
    get_user_warehouse() IS NULL
    OR i.storage_location = get_user_warehouse()
  );

GRANT SELECT ON active_inventory TO authenticated;
GRANT SELECT ON active_inventory TO anon;
GRANT SELECT ON active_inventory TO service_role;
