-- Travel Atlas mobile app core schema for a Supabase-backed start
-- while keeping the domain portable to a later Spring migration.

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = timezone('utc', now());
  return new;
end;
$$;

create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  email text not null default '',
  display_name text not null default '',
  home_base text not null default 'Local-first travel archive',
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.trips (
  id text primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  title text not null,
  subtitle text not null default '',
  start_date timestamptz not null,
  end_date timestamptz not null,
  hero_place jsonb not null default '{}'::jsonb,
  cover_hint text not null default '',
  memory_count integer not null default 0,
  photo_count integer not null default 0,
  country_count integer not null default 0,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.journal_entries (
  id text primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  trip_id text not null references public.trips (id) on delete cascade,
  title text not null,
  body text not null default '',
  recorded_at timestamptz not null,
  place jsonb not null default '{}'::jsonb,
  type text not null default 'note' check (type in ('note', 'photo')),
  photo_asset_ids jsonb not null default '[]'::jsonb,
  has_pending_upload boolean not null default false,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.photo_assets (
  id text primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  file_name text not null,
  preview_label text not null,
  format text not null,
  taken_at timestamptz not null,
  place jsonb not null default '{}'::jsonb,
  upload_state text not null default 'queued'
    check (upload_state in ('localOnly', 'queued', 'uploading', 'uploaded', 'failed')),
  storage_path text,
  byte_size bigint,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create index if not exists trips_user_id_start_date_idx
  on public.trips (user_id, start_date desc);

create index if not exists journal_entries_user_id_recorded_at_idx
  on public.journal_entries (user_id, recorded_at desc);

create index if not exists journal_entries_trip_id_recorded_at_idx
  on public.journal_entries (trip_id, recorded_at desc);

create index if not exists photo_assets_user_id_taken_at_idx
  on public.photo_assets (user_id, taken_at desc);

create or replace function public.handle_profile_from_auth_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, email, display_name, home_base)
  values (
    new.id,
    coalesce(new.email, ''),
    coalesce(new.raw_user_meta_data ->> 'display_name', split_part(coalesce(new.email, ''), '@', 1)),
    coalesce(new.raw_user_meta_data ->> 'home_base', 'Local-first travel archive')
  )
  on conflict (id) do update
    set email = excluded.email,
        display_name = excluded.display_name,
        home_base = excluded.home_base,
        updated_at = timezone('utc', now());

  return new;
end;
$$;

drop trigger if exists on_auth_user_profile_sync on auth.users;
create trigger on_auth_user_profile_sync
after insert or update on auth.users
for each row execute procedure public.handle_profile_from_auth_user();

drop trigger if exists set_profiles_updated_at on public.profiles;
create trigger set_profiles_updated_at
before update on public.profiles
for each row execute procedure public.set_updated_at();

drop trigger if exists set_trips_updated_at on public.trips;
create trigger set_trips_updated_at
before update on public.trips
for each row execute procedure public.set_updated_at();

drop trigger if exists set_journal_entries_updated_at on public.journal_entries;
create trigger set_journal_entries_updated_at
before update on public.journal_entries
for each row execute procedure public.set_updated_at();

drop trigger if exists set_photo_assets_updated_at on public.photo_assets;
create trigger set_photo_assets_updated_at
before update on public.photo_assets
for each row execute procedure public.set_updated_at();

alter table public.profiles enable row level security;
alter table public.trips enable row level security;
alter table public.journal_entries enable row level security;
alter table public.photo_assets enable row level security;

drop policy if exists profiles_select_own on public.profiles;
create policy profiles_select_own
on public.profiles
for select
to authenticated
using (auth.uid() = id);

drop policy if exists profiles_insert_own on public.profiles;
create policy profiles_insert_own
on public.profiles
for insert
to authenticated
with check (auth.uid() = id);

drop policy if exists profiles_update_own on public.profiles;
create policy profiles_update_own
on public.profiles
for update
to authenticated
using (auth.uid() = id)
with check (auth.uid() = id);

drop policy if exists trips_select_own on public.trips;
create policy trips_select_own
on public.trips
for select
to authenticated
using (auth.uid() = user_id);

drop policy if exists trips_insert_own on public.trips;
create policy trips_insert_own
on public.trips
for insert
to authenticated
with check (auth.uid() = user_id);

drop policy if exists trips_update_own on public.trips;
create policy trips_update_own
on public.trips
for update
to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

drop policy if exists trips_delete_own on public.trips;
create policy trips_delete_own
on public.trips
for delete
to authenticated
using (auth.uid() = user_id);

drop policy if exists journal_entries_select_own on public.journal_entries;
create policy journal_entries_select_own
on public.journal_entries
for select
to authenticated
using (auth.uid() = user_id);

drop policy if exists journal_entries_insert_own on public.journal_entries;
create policy journal_entries_insert_own
on public.journal_entries
for insert
to authenticated
with check (auth.uid() = user_id);

drop policy if exists journal_entries_update_own on public.journal_entries;
create policy journal_entries_update_own
on public.journal_entries
for update
to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

drop policy if exists journal_entries_delete_own on public.journal_entries;
create policy journal_entries_delete_own
on public.journal_entries
for delete
to authenticated
using (auth.uid() = user_id);

drop policy if exists photo_assets_select_own on public.photo_assets;
create policy photo_assets_select_own
on public.photo_assets
for select
to authenticated
using (auth.uid() = user_id);

drop policy if exists photo_assets_insert_own on public.photo_assets;
create policy photo_assets_insert_own
on public.photo_assets
for insert
to authenticated
with check (auth.uid() = user_id);

drop policy if exists photo_assets_update_own on public.photo_assets;
create policy photo_assets_update_own
on public.photo_assets
for update
to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

drop policy if exists photo_assets_delete_own on public.photo_assets;
create policy photo_assets_delete_own
on public.photo_assets
for delete
to authenticated
using (auth.uid() = user_id);

insert into storage.buckets (id, name, public)
values ('travel-media', 'travel-media', false)
on conflict (id) do nothing;

drop policy if exists "travel_media_read_own" on storage.objects;
create policy "travel_media_read_own"
on storage.objects
for select
to authenticated
using (
  bucket_id = 'travel-media'
  and auth.uid()::text = (storage.foldername(name))[1]
);

drop policy if exists "travel_media_insert_own" on storage.objects;
create policy "travel_media_insert_own"
on storage.objects
for insert
to authenticated
with check (
  bucket_id = 'travel-media'
  and auth.uid()::text = (storage.foldername(name))[1]
);

drop policy if exists "travel_media_update_own" on storage.objects;
create policy "travel_media_update_own"
on storage.objects
for update
to authenticated
using (
  bucket_id = 'travel-media'
  and auth.uid()::text = (storage.foldername(name))[1]
)
with check (
  bucket_id = 'travel-media'
  and auth.uid()::text = (storage.foldername(name))[1]
);

drop policy if exists "travel_media_delete_own" on storage.objects;
create policy "travel_media_delete_own"
on storage.objects
for delete
to authenticated
using (
  bucket_id = 'travel-media'
  and auth.uid()::text = (storage.foldername(name))[1]
);
