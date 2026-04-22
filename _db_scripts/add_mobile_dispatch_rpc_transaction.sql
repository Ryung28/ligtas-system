-- Atomic mobile dispatch transaction (stock check + stock deduction + borrow log insert).
-- Run this in Supabase SQL editor before deploying the mobile repository change.

create or replace function public.mobile_dispatch_borrow_transaction(
  p_inventory_id bigint,
  p_item_name text,
  p_quantity integer,
  p_borrower_name text,
  p_borrower_contact text,
  p_borrower_organization text,
  p_approved_by_name text default null,
  p_released_by_name text default null,
  p_released_by_user_id uuid default null,
  p_now timestamptz default now()
)
returns jsonb
language plpgsql
as $$
declare
  v_current_stock integer;
begin
  if p_quantity is null or p_quantity < 1 then
    raise exception 'Quantity must be at least 1';
  end if;

  select stock_available
  into v_current_stock
  from public.inventory
  where id = p_inventory_id
  for update;

  if v_current_stock is null then
    raise exception 'Inventory item not found: %', p_inventory_id;
  end if;

  -- 🛡️ PREFLIGHT CHECK: Still verify stock, but don't substract here. 
  -- The 'auto_update_inventory_stock' trigger on borrow_logs takes care of the subtraction.
  if v_current_stock < p_quantity then
    raise exception 'Insufficient stock. Requested %, available %', p_quantity, v_current_stock;
  end if;

  insert into public.borrow_logs (
    inventory_id,
    item_name,
    quantity,
    borrower_name,
    borrower_contact,
    borrower_organization,
    approved_by_name,
    released_by_name,
    released_by_user_id,
    transaction_type,
    status,
    borrow_date,
    platform_origin,
    created_origin,
    last_updated_origin,
    created_at
  ) values (
    p_inventory_id,
    p_item_name,
    p_quantity,
    p_borrower_name,
    p_borrower_contact,
    p_borrower_organization,
    p_approved_by_name,
    p_released_by_name,
    p_released_by_user_id,
    'borrow',
    'borrowed',
    p_now,
    'Mobile',
    'Mobile',
    'Mobile',
    p_now
  );

  return jsonb_build_object(
    'success', true,
    'inventory_id', p_inventory_id,
    'quantity', p_quantity
  );
end;
$$;

grant execute on function public.mobile_dispatch_borrow_transaction(
  bigint,
  text,
  integer,
  text,
  text,
  text,
  text,
  text,
  uuid,
  timestamptz
) to authenticated;
