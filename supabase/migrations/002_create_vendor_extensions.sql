-- Migration: 002_create_vendor_extensions.sql
-- Vendor-specific profile data. Separate from profiles to avoid nullable columns on homeowner rows.
-- Run order: Apply after 001_create_profiles.sql. The id column references profiles.id.

create table if not exists public.vendor_extensions (
  id                    uuid        primary key references public.profiles(id) on delete cascade,
  services              text[]      not null default '{}',
  price_range_min       numeric,
  price_range_max       numeric,
  qrph_url              text,
  avatar_url            text,
  is_available          boolean     not null default true,
  is_suspended          boolean     not null default false,
  completed_jobs_count  integer     not null default 0,
  created_at            timestamptz not null default now()
);

-- Enable Row Level Security
alter table public.vendor_extensions enable row level security;

-- Vendors can read/write their own row
create policy "vendor_own_extensions"
  on public.vendor_extensions
  for all
  using (auth.uid() = id)
  with check (auth.uid() = id);

-- Homeowners can read all non-suspended vendor rows (for vendor browse in Story 3.1)
create policy "homeowner_read_active_vendors"
  on public.vendor_extensions
  for select
  using (
    is_suspended = false
    and exists (
      select 1 from public.profiles
      where profiles.id = auth.uid()
        and profiles.user_type = 'homeowner'
    )
  );
