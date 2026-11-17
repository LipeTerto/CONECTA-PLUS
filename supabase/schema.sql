-- =====================================================================
-- Conecta+ | Esquema do banco de dados (PostgreSQL / Supabase)
-- Execute UMA vez no SQL Editor do Supabase.
-- =====================================================================


-- ---------------------------------------------------------------------
-- 1. TABELAS
-- ---------------------------------------------------------------------

-- 1.1 PROFILES: dados do usuário além do login (1:1 com auth.users)
create table public.profiles (
  id         uuid primary key references auth.users (id) on delete cascade,
  name       text not null,
  email      text not null,
  created_at timestamptz not null default now()
);

-- 1.2 EVENTS
create table public.events (
  id             uuid primary key default gen_random_uuid(),
  user_id        uuid not null default auth.uid()
                   references auth.users (id) on delete cascade,
  title          text not null check (char_length(trim(title)) > 0),
  description    text not null,
  category       text not null,
  event_date     date not null,
  event_time     time not null,
  location_name  text not null,
  address        text not null,
  organizer_name text not null,
  created_at     timestamptz not null default now()
);

-- 1.3 INSTITUTIONS (rede de apoio)
create table public.institutions (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid not null default auth.uid()
                 references auth.users (id) on delete cascade,
  name         text not null check (char_length(trim(name)) > 0),
  description  text not null,
  category     text not null,
  address      text not null,
  contact_info text not null,
  website      text,                       -- opcional
  created_at   timestamptz not null default now()
);

-- 1.4 INITIATIVES (projetos sociais)
create table public.initiatives (
  id                uuid primary key default gen_random_uuid(),
  user_id           uuid not null default auth.uid()
                      references auth.users (id) on delete cascade,
  title             text not null check (char_length(trim(title)) > 0),
  description       text not null,
  category          text not null,
  organization_name text not null,
  location          text not null,
  contact_info      text,                  -- opcional
  created_at        timestamptz not null default now()
);

-- 1.5 FAVORITES: cada linha aponta para EXATAMENTE um item
create table public.favorites (
  id             uuid primary key default gen_random_uuid(),
  user_id        uuid not null default auth.uid()
                   references auth.users (id) on delete cascade,
  event_id       uuid references public.events (id) on delete cascade,
  institution_id uuid references public.institutions (id) on delete cascade,
  initiative_id  uuid references public.initiatives (id) on delete cascade,
  created_at     timestamptz not null default now(),

  -- exatamente uma das três colunas deve estar preenchida
  constraint favorites_exactly_one_target
    check (num_nonnulls(event_id, institution_id, initiative_id) = 1),

  -- impede favoritar o mesmo item duas vezes
  constraint favorites_unique_event       unique (user_id, event_id),
  constraint favorites_unique_institution unique (user_id, institution_id),
  constraint favorites_unique_initiative  unique (user_id, initiative_id)
);

-- Índices para acelerar as consultas mais comuns
create index events_created_at_idx       on public.events       (created_at desc);
create index institutions_created_at_idx on public.institutions (created_at desc);
create index initiatives_created_at_idx  on public.initiatives  (created_at desc);
create index favorites_user_id_idx       on public.favorites    (user_id);


-- ---------------------------------------------------------------------
-- 2. TRIGGER: cria o perfil automaticamente quando alguém se cadastra
-- ---------------------------------------------------------------------

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (id, name, email)
  values (
    new.id,
    coalesce(
      nullif(trim(new.raw_user_meta_data ->> 'name'), ''),
      split_part(new.email, '@', 1)
    ),
    new.email
  );
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();


-- ---------------------------------------------------------------------
-- 3. PERMISSÕES (GRANT): o que cada papel pode fazer nas tabelas
--    Sem estes GRANTs a API devolve "permission denied" (erro 42501).
--    Não há GRANT para "anon": quem não está logado não acessa nada.
-- ---------------------------------------------------------------------

grant select, insert, update, delete
  on public.events, public.institutions, public.initiatives
  to authenticated;

grant select, insert, delete on public.favorites to authenticated;  -- sem UPDATE
grant select, update         on public.profiles  to authenticated;  -- INSERT é do trigger


-- ---------------------------------------------------------------------
-- 4. ROW LEVEL SECURITY (RLS)
--    GRANT diz "este papel pode usar a tabela".
--    RLS diz "e quais LINHAS ele pode ver/alterar".
--    As duas camadas valem ao mesmo tempo.
-- ---------------------------------------------------------------------

alter table public.profiles     enable row level security;
alter table public.events       enable row level security;
alter table public.institutions enable row level security;
alter table public.initiatives  enable row level security;
alter table public.favorites    enable row level security;

-- 4.1 PROFILES: cada um vê e edita só o próprio perfil
create policy "profiles_select_own" on public.profiles
  for select to authenticated
  using ((select auth.uid()) = id);

create policy "profiles_update_own" on public.profiles
  for update to authenticated
  using ((select auth.uid()) = id)
  with check ((select auth.uid()) = id);

-- 4.2 EVENTS
create policy "events_select_all" on public.events
  for select to authenticated
  using (true);

create policy "events_insert_own" on public.events
  for insert to authenticated
  with check ((select auth.uid()) = user_id);

create policy "events_update_own" on public.events
  for update to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

create policy "events_delete_own" on public.events
  for delete to authenticated
  using ((select auth.uid()) = user_id);

-- 4.3 INSTITUTIONS
create policy "institutions_select_all" on public.institutions
  for select to authenticated
  using (true);

create policy "institutions_insert_own" on public.institutions
  for insert to authenticated
  with check ((select auth.uid()) = user_id);

create policy "institutions_update_own" on public.institutions
  for update to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

create policy "institutions_delete_own" on public.institutions
  for delete to authenticated
  using ((select auth.uid()) = user_id);

-- 4.4 INITIATIVES
create policy "initiatives_select_all" on public.initiatives
  for select to authenticated
  using (true);

create policy "initiatives_insert_own" on public.initiatives
  for insert to authenticated
  with check ((select auth.uid()) = user_id);

create policy "initiatives_update_own" on public.initiatives
  for update to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

create policy "initiatives_delete_own" on public.initiatives
  for delete to authenticated
  using ((select auth.uid()) = user_id);

-- 4.5 FAVORITES: totalmente privado (ver, criar e remover só os próprios)
create policy "favorites_select_own" on public.favorites
  for select to authenticated
  using ((select auth.uid()) = user_id);

create policy "favorites_insert_own" on public.favorites
  for insert to authenticated
  with check ((select auth.uid()) = user_id);

create policy "favorites_delete_own" on public.favorites
  for delete to authenticated
  using ((select auth.uid()) = user_id);