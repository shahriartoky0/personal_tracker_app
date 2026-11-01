-- 1) updated_at everywhere (tables that already have it are skipped by IF NOT EXISTS)
alter table public.accounts            add column if not exists updated_at timestamptz not null default now();
alter table public.categories          add column if not exists updated_at timestamptz not null default now();
alter table public.payees              add column if not exists updated_at timestamptz not null default now();
alter table public.budget_allocations  add column if not exists updated_at timestamptz not null default now();
alter table public.planned_expenses    add column if not exists updated_at timestamptz not null default now();
alter table public.reminder_preferences add column if not exists updated_at timestamptz not null default now();
-- profiles, daily_budgets, budget_templates, transactions already have updated_at.

do $$
declare t text;
begin
  foreach t in array array['accounts','categories','payees','budget_allocations','planned_expenses','reminder_preferences',
                           'budget_templates']
  loop
    execute format('drop trigger if exists %I on public.%I', t || '_set_updated', t);
    execute format('create trigger %I before update on public.%I for each row execute function public.set_updated_at()',
                   t || '_set_updated', t);
  end loop;
  -- delta-pull index on every synced table
  foreach t in array array['accounts','categories','payees','daily_budgets','budget_allocations','budget_templates',
                           'planned_expenses','transactions','reminder_preferences']
  loop
    execute format('create index if not exists %I on public.%I (user_id, updated_at, id)', t || '_sync_idx', t);
  end loop;
end $$;

-- 2) tombstones for hard deletes
create table if not exists public.sync_tombstones (
  id bigint generated always as identity primary key,
  user_id uuid not null,
  table_name text not null,
  row_id uuid not null,
  deleted_at timestamptz not null default clock_timestamp()
);
create index if not exists sync_tombstones_user_idx on public.sync_tombstones (user_id, deleted_at, id);
alter table public.sync_tombstones enable row level security;
create policy sync_tombstones_select on public.sync_tombstones
  for select to authenticated using (user_id = (select auth.uid()));
-- no insert/update/delete policies: only the trigger below (security definer) writes.

create or replace function public.record_tombstone() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  insert into public.sync_tombstones (user_id, table_name, row_id) values (old.user_id, tg_table_name, old.id);
  return old;
end $$;
revoke all on function public.record_tombstone() from public, anon, authenticated;

do $$
declare t text;
begin
  foreach t in array array['accounts','categories','payees','daily_budgets','budget_allocations','budget_templates',
                           'planned_expenses','transactions','reminder_preferences']
  loop
    execute format('drop trigger if exists %I on public.%I', t || '_tombstone', t);
    execute format('create trigger %I after delete on public.%I for each row execute function public.record_tombstone()',
                   t || '_tombstone', t);
  end loop;
end $$;

-- 3) original_* are immutable after insert
create or replace function public.keep_original_limit() returns trigger
language plpgsql set search_path = '' as $$
begin new.original_limit := old.original_limit; return new; end $$;
create or replace function public.keep_original_amount() returns trigger
language plpgsql set search_path = '' as $$
begin new.original_amount := old.original_amount; return new; end $$;

drop trigger if exists daily_budgets_keep_original on public.daily_budgets;
create trigger daily_budgets_keep_original before update on public.daily_budgets
  for each row execute function public.keep_original_limit();
drop trigger if exists budget_allocations_keep_original on public.budget_allocations;
create trigger budget_allocations_keep_original before update on public.budget_allocations
  for each row execute function public.keep_original_amount();

-- 4) client compatibility gate (read-only for clients)
create table if not exists public.app_config (
  id int primary key default 1 check (id = 1),
  schema_version int not null default 1,
  min_client_version text not null default '0.0.0'
);
insert into public.app_config (id) values (1) on conflict do nothing;
alter table public.app_config enable row level security;
create policy app_config_read on public.app_config for select to authenticated using (true);

-- 5) optional: live updates
-- alter publication supabase_realtime add table public.transactions, public.accounts, public.categories,
--   public.payees, public.daily_budgets, public.budget_allocations, public.planned_expenses;
