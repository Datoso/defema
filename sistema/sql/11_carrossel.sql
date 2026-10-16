-- =====================================================================
-- DEFEMA · Catálogo — 11_carrossel.sql
-- Configurações do site editadas pelo painel (por enquanto: o carrossel
-- da página inicial — qual produto vai na "Oferta destaque da semana" e
-- quais slides aparecem).
--   site_config.chave = 'carrossel'
--   site_config.valor = {"oferta": {"id": "...", "nome": "..."} | null,
--                        "ocultar": ["boasVindas","oferta","mudas","criacao"]}
-- Todo mundo lê (o site é público); só administradores gravam.
-- Pode rodar de novo sem problema.
-- =====================================================================
create table if not exists public.site_config (
  chave          text primary key,
  valor          jsonb not null default '{}'::jsonb,
  atualizado_em  timestamptz not null default now()
);
comment on table public.site_config is 'Configurações do site editadas no painel (ex.: carrossel da página inicial).';

grant select on public.site_config to anon, authenticated;
grant insert, update on public.site_config to authenticated;

alter table public.site_config enable row level security;

drop policy if exists "config: todos leem" on public.site_config;
create policy "config: todos leem" on public.site_config
  for select to anon, authenticated using (true);
drop policy if exists "config: admin cria" on public.site_config;
create policy "config: admin cria" on public.site_config
  for insert to authenticated with check (public.eh_admin());
drop policy if exists "config: admin altera" on public.site_config;
create policy "config: admin altera" on public.site_config
  for update to authenticated using (public.eh_admin()) with check (public.eh_admin());

insert into public.site_config (chave, valor) values ('carrossel', '{}'::jsonb)
on conflict (chave) do nothing;
