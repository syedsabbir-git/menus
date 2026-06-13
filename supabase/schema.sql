-- ============================================================
-- Menus App — Supabase starter schema
-- Run this in your Supabase project SQL editor.
-- ============================================================

-- PROFILES (extends auth.users)
create table if not exists public.profiles (
  id            uuid primary key references auth.users(id) on delete cascade,
  full_name     text not null default '',
  phone         text not null default '',
  role          text not null default 'customer'
                  check (role in ('customer', 'vendor', 'admin')),
  delivery_address text,
  created_at    timestamptz not null default now()
);

-- Auto-create profile row when a user signs up
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer as $$
begin
  insert into public.profiles (id, full_name, phone)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'full_name', ''),
    coalesce(new.raw_user_meta_data->>'phone', '')
  );
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- RESTAURANTS
create table if not exists public.restaurants (
  id          uuid primary key default gen_random_uuid(),
  owner_id    uuid not null references public.profiles(id) on delete cascade,
  name        text not null,
  description text,
  image_url   text,
  is_open     boolean not null default false,
  created_at  timestamptz not null default now()
);

-- MENU ITEMS
create table if not exists public.menu_items (
  id                  uuid primary key default gen_random_uuid(),
  restaurant_id       uuid not null references public.restaurants(id) on delete cascade,
  name                text not null,
  description         text,
  price               numeric(10, 2) not null check (price >= 0),
  image_url           text,
  category            text,
  is_available_today  boolean not null default false,
  created_at          timestamptz not null default now()
);

-- ORDERS
create table if not exists public.orders (
  id               uuid primary key default gen_random_uuid(),
  customer_id      uuid not null references public.profiles(id) on delete cascade,
  restaurant_id    uuid not null references public.restaurants(id) on delete cascade,
  status           text not null default 'pending'
                     check (status in ('pending','confirmed','preparing','out_for_delivery','delivered','cancelled')),
  total            numeric(10, 2) not null check (total >= 0),
  delivery_address text not null,
  created_at       timestamptz not null default now()
);

-- ORDER ITEMS
create table if not exists public.order_items (
  id            uuid primary key default gen_random_uuid(),
  order_id      uuid not null references public.orders(id) on delete cascade,
  menu_item_id  uuid not null references public.menu_items(id),
  quantity      int not null check (quantity > 0),
  unit_price    numeric(10, 2) not null check (unit_price >= 0)
);

-- ============================================================
-- Row Level Security (RLS)
-- ============================================================

alter table public.profiles enable row level security;
alter table public.restaurants enable row level security;
alter table public.menu_items enable row level security;
alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Profiles: users can read/update their own profile; admins can read all
create policy "profiles_self_read"  on public.profiles for select using (auth.uid() = id);
create policy "profiles_self_update" on public.profiles for update using (auth.uid() = id);

-- Restaurants: public read, vendor can manage their own
create policy "restaurants_public_read"   on public.restaurants for select using (true);
create policy "restaurants_vendor_insert" on public.restaurants for insert with check (auth.uid() = owner_id);
create policy "restaurants_vendor_update" on public.restaurants for update using (auth.uid() = owner_id);

-- Menu items: public read, vendor (owner) can manage
create policy "menu_items_public_read"   on public.menu_items for select using (true);
create policy "menu_items_vendor_write"  on public.menu_items for all
  using (auth.uid() = (select owner_id from public.restaurants where id = restaurant_id));

-- Orders: customer sees own orders; restaurant owner sees their restaurant's orders
create policy "orders_customer_read" on public.orders for select
  using (auth.uid() = customer_id);
create policy "orders_customer_insert" on public.orders for insert
  with check (auth.uid() = customer_id);
create policy "orders_vendor_read" on public.orders for select
  using (auth.uid() = (select owner_id from public.restaurants where id = restaurant_id));
create policy "orders_vendor_update" on public.orders for update
  using (auth.uid() = (select owner_id from public.restaurants where id = restaurant_id));

-- Order items: follow parent order visibility
create policy "order_items_read" on public.order_items for select
  using (exists (
    select 1 from public.orders o
    where o.id = order_id
      and (o.customer_id = auth.uid()
        or exists (select 1 from public.restaurants r where r.id = o.restaurant_id and r.owner_id = auth.uid()))
  ));
create policy "order_items_insert" on public.order_items for insert
  with check (exists (
    select 1 from public.orders o where o.id = order_id and o.customer_id = auth.uid()
  ));
