-- Migration: 001_create_profiles.sql
-- Creates the unified profiles table for all users (homeowners and vendors).
-- One row per user, regardless of role. Role is stored in user_type.
-- Vendor-specific business data lives in vendor_extensions (migration 002).

create table if not exists public.profiles (
  id          uuid        primary key references auth.users on delete cascade,
  user_type   text        not null check (user_type in ('homeowner', 'vendor')),
  name        text,
  phone       text,
  avatar_url  text,
  created_at  timestamptz not null default now()
);

-- Enable Row Level Security
alter table public.profiles enable row level security;

-- Policy: users can only read and write their own profile row.
-- auth.uid() = id ensures no user can access another user's data.
create policy "users_own_profile"
  on public.profiles
  for all
  using (auth.uid() = id)
  with check (auth.uid() = id);

-- Index on user_type for role-based routing queries (used by go_router guards).
create index if not exists profiles_user_type_idx on public.profiles (user_type);
