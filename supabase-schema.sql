-- CCF production database starter schema (Supabase / PostgreSQL)
-- This file is a backend blueprint only. The static prototype does not connect to Supabase.
-- Review access policies with your organization before applying to a live project.

create extension if not exists pgcrypto;

create table if not exists public.farmers (
  id uuid primary key default gen_random_uuid(),
  farmer_code text not null unique,
  farmer_name text not null,
  contact_details text,
  village_name text not null,
  mandal_name text,
  district text not null,
  state_name text not null,
  seed_variety text,
  acreage numeric(12,2) not null default 0 check (acreage >= 0),
  sowing_date date,
  quality_parameters jsonb not null default '{}'::jsonb,
  notes text,
  public_trace_enabled boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.processed_lots (
  id uuid primary key default gen_random_uuid(),
  lot_code text not null unique,
  lot_name text not null,
  processed_on date,
  district text,
  state_name text,
  seed_variety text,
  seed_cotton_kg numeric(14,2) not null default 0 check (seed_cotton_kg >= 0),
  moisture_pct numeric(5,2) check (moisture_pct between 0 and 100),
  got_pct numeric(5,2) check (got_pct between 0 and 100),
  status text not null default 'In review' check (status in ('In review','Tested','Released','Archived')),
  quality_parameters jsonb not null default '{}'::jsonb,
  hvi_report_id text,
  notes text,
  public_trace_enabled boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.lot_farmers (
  lot_id uuid not null references public.processed_lots(id) on delete cascade,
  farmer_id uuid not null references public.farmers(id) on delete restrict,
  contribution_note text,
  created_at timestamptz not null default now(),
  primary key (lot_id, farmer_id)
);

create table if not exists public.bales (
  id uuid primary key default gen_random_uuid(),
  bale_code text not null unique,
  lot_id uuid not null references public.processed_lots(id) on delete restrict,
  farmer_id uuid references public.farmers(id) on delete restrict,
  weight_kg numeric(10,2) not null default 170 check (weight_kg > 0),
  status text not null default 'In review' check (status in ('In review','Tested','Released','Archived')),
  hvi_report_id text,
  public_trace_enabled boolean not null default false,
  qr_token uuid not null unique default gen_random_uuid(),
  published_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists farmers_district_idx on public.farmers(district);
create index if not exists farmers_village_idx on public.farmers(village_name);
create index if not exists processed_lots_processed_on_idx on public.processed_lots(processed_on desc);
create index if not exists lot_farmers_farmer_id_idx on public.lot_farmers(farmer_id);
create index if not exists bales_lot_id_idx on public.bales(lot_id);
create index if not exists bales_farmer_id_idx on public.bales(farmer_id);

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists farmers_set_updated_at on public.farmers;
create trigger farmers_set_updated_at before update on public.farmers
for each row execute function public.set_updated_at();
drop trigger if exists processed_lots_set_updated_at on public.processed_lots;
create trigger processed_lots_set_updated_at before update on public.processed_lots
for each row execute function public.set_updated_at();
drop trigger if exists bales_set_updated_at on public.bales;
create trigger bales_set_updated_at before update on public.bales
for each row execute function public.set_updated_at();

-- The base tables are private by default. Authenticated staff can read/write in this starter policy.
-- Add role-based policies (e.g. procurement, quality lab, traceability admin) before production use.
alter table public.farmers enable row level security;
alter table public.processed_lots enable row level security;
alter table public.lot_farmers enable row level security;
alter table public.bales enable row level security;

drop policy if exists "authenticated staff manage farmers" on public.farmers;
create policy "authenticated staff manage farmers" on public.farmers
for all to authenticated using (true) with check (true);
drop policy if exists "authenticated staff manage lots" on public.processed_lots;
create policy "authenticated staff manage lots" on public.processed_lots
for all to authenticated using (true) with check (true);
drop policy if exists "authenticated staff manage lot farmer links" on public.lot_farmers;
create policy "authenticated staff manage lot farmer links" on public.lot_farmers
for all to authenticated using (true) with check (true);
drop policy if exists "authenticated staff manage bales" on public.bales;
create policy "authenticated staff manage bales" on public.bales
for all to authenticated using (true) with check (true);

-- Shareable public report: deliberately excludes farmer contact details and internal notes.
-- Only rows explicitly published by staff are visible through this view.
create or replace view public.public_bale_traceability as
select
  b.bale_code,
  b.weight_kg,
  b.status as bale_status,
  b.published_at,
  l.lot_code,
  l.lot_name,
  l.processed_on,
  l.district as processing_district,
  l.state_name as processing_state,
  l.seed_variety as lot_seed_variety,
  l.seed_cotton_kg,
  l.moisture_pct,
  l.got_pct,
  l.quality_parameters as lot_quality_parameters,
  coalesce(b.hvi_report_id, l.hvi_report_id) as hvi_report_id,
  f.farmer_code,
  f.farmer_name,
  f.village_name,
  f.mandal_name,
  f.district as farmer_district,
  f.state_name as farmer_state,
  f.seed_variety as farmer_seed_variety,
  f.acreage,
  f.quality_parameters as farmer_quality_parameters
from public.bales b
join public.processed_lots l on l.id = b.lot_id
left join public.farmers f on f.id = b.farmer_id
where b.public_trace_enabled = true
  and b.published_at is not null
  and l.public_trace_enabled = true
  and (f.id is null or f.public_trace_enabled = true);

grant select on public.public_bale_traceability to anon, authenticated;

-- IMPORTANT:
-- 1. Keep the Supabase service-role key on the server only; never put it in app.js.
-- 2. Configure Auth and stricter role-specific policies before enabling staff writes.
-- 3. Use the public view or a server-side endpoint for customer QR scans, not direct table access.
-- 4. HVI values should be associated with the authorized lab report and audit trail, not self-certified by the UI.
