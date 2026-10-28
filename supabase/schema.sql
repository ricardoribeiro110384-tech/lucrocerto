-- LucroCerto: esquema inicial para contas individuais (MVP).
-- Execute somente em um projeto Supabase dedicado ao LucroCerto.
create table if not exists public.products (
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null references auth.users(id) on delete cascade,
 sku text not null check (length(trim(sku)) between 1 and 60),
 name text not null check (length(trim(name)) between 1 and 120),
 cost numeric(14,2) not null check (cost >= 0),
 price numeric(14,2) not null check (price > 0),
 stock integer not null default 0 check (stock >= 0),
 lead integer not null default 7 check (lead between 1 and 180),
 created_at timestamptz not null default now(),
 unique(user_id,sku),
 unique(user_id,id)
);
create table if not exists public.sales (
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null references auth.users(id) on delete cascade,
 product_id uuid not null,
 qty integer not null check (qty > 0),
 sold_on date not null default current_date,
 unit_price numeric(14,2) not null check(unit_price >= 0),
 unit_cost numeric(14,2) not null check(unit_cost >= 0),
 created_at timestamptz not null default now(),
 foreign key(user_id, product_id) references public.products(user_id,id)
);
create index if not exists idx_sales_user_date on public.sales(user_id,sold_on desc);
alter table public.products enable row level security;
alter table public.sales enable row level security;
create policy "products_select_own" on public.products for select to authenticated using ((select auth.uid())=user_id);
create policy "products_insert_own" on public.products for insert to authenticated with check ((select auth.uid())=user_id);
create policy "products_update_own" on public.products for update to authenticated using ((select auth.uid())=user_id) with check ((select auth.uid())=user_id);
create policy "products_delete_own" on public.products for delete to authenticated using ((select auth.uid())=user_id);
create policy "sales_select_own" on public.sales for select to authenticated using ((select auth.uid())=user_id);
create policy "sales_insert_own" on public.sales for insert to authenticated with check ((select auth.uid())=user_id);
create policy "sales_delete_own" on public.sales for delete to authenticated using ((select auth.uid())=user_id);
-- Planos são administrados exclusivamente por ambiente servidor, nunca pelo navegador.
create table if not exists public.subscriptions (
 user_id uuid primary key references auth.users(id) on delete cascade,
 plan text not null default 'trial' check(plan in ('trial','initial','pro','business')),
 status text not null default 'trialing' check(status in ('trialing','active','past_due','canceled')),
 provider_customer_id text,
 provider_subscription_id text,
 current_period_end timestamptz
);
alter table public.subscriptions enable row level security;
create policy "subscriptions_read_own" on public.subscriptions for select to authenticated using ((select auth.uid())=user_id);
-- Sem permissões INSERT/UPDATE/DELETE no cliente: cobranças devem vir de webhook autenticado.
revoke all on public.subscriptions from anon,authenticated;
grant select on public.subscriptions to authenticated;
grant select,insert,update,delete on public.products, public.sales to authenticated;
