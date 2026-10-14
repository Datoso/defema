-- =====================================================================
-- DEFEMA · Catálogo — 02_seguranca.sql
-- Regras de acesso (RLS) e bucket de fotos. Rode DEPOIS do 01_schema.sql.
--
--  * Visitante do site (papel "anon"): só LÊ departamentos, subcategorias,
--    produtos ATIVOS e as opções desses produtos.
--  * Usuário logado que está na tabela "administradores": lê tudo e altera tudo.
--  * Qualquer outro usuário logado: só o mesmo que o visitante.
--  * Fotos: bucket "produtos" público para leitura; enviar/trocar/apagar
--    só administradores.
-- Pode ser rodado de novo sem problema.
-- =====================================================================

-- ---------------------------------------------------------------------
-- Função auxiliar: o usuário atual é administrador?
-- SECURITY DEFINER para poder consultar "administradores" sem depender da RLS.
-- ---------------------------------------------------------------------
create or replace function public.eh_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (select 1 from public.administradores a where a.user_id = auth.uid());
$$;
comment on function public.eh_admin() is 'Verdadeiro quando o usuário logado está na tabela administradores (painel: supabase.rpc(''eh_admin'')).';
revoke all on function public.eh_admin() from public;
grant execute on function public.eh_admin() to anon, authenticated;
-- ---------------------------------------------------------------------
-- Permissões básicas (a RLS abaixo é que filtra as linhas)
-- ---------------------------------------------------------------------
grant usage on schema public to anon, authenticated;
grant select on public.departamentos, public.subcategorias, public.produtos, public.produto_opcoes to anon, authenticated;
grant insert, update, delete on public.departamentos, public.subcategorias, public.produtos, public.produto_opcoes to authenticated;
grant usage, select on all sequences in schema public to authenticated; -- ids serial
grant select on public.administradores to authenticated;
revoke insert, update, delete on public.administradores from anon, authenticated;

-- ---------------------------------------------------------------------
-- Liga a RLS em todas as tabelas
-- ---------------------------------------------------------------------
alter table public.departamentos   enable row level security;
alter table public.subcategorias   enable row level security;
alter table public.produtos        enable row level security;
alter table public.produto_opcoes  enable row level security;
alter table public.administradores enable row level security;

-- Departamentos ---------------------------------------------------------
drop policy if exists "departamentos: leitura pública" on public.departamentos;
create policy "departamentos: leitura pública" on public.departamentos
  for select to anon, authenticated using (true);

drop policy if exists "departamentos: admin altera" on public.departamentos;
drop policy if exists "departamentos: admin insere" on public.departamentos;
create policy "departamentos: admin insere" on public.departamentos
  for insert to authenticated with check (public.eh_admin());
drop policy if exists "departamentos: admin atualiza" on public.departamentos;
create policy "departamentos: admin atualiza" on public.departamentos
  for update to authenticated using (public.eh_admin()) with check (public.eh_admin());
drop policy if exists "departamentos: admin apaga" on public.departamentos;
create policy "departamentos: admin apaga" on public.departamentos
  for delete to authenticated using (public.eh_admin());

-- Subcategorias ---------------------------------------------------------
drop policy if exists "subcategorias: leitura pública" on public.subcategorias;
create policy "subcategorias: leitura pública" on public.subcategorias
  for select to anon, authenticated using (true);

drop policy if exists "subcategorias: admin altera" on public.subcategorias;
drop policy if exists "subcategorias: admin insere" on public.subcategorias;
create policy "subcategorias: admin insere" on public.subcategorias
  for insert to authenticated with check (public.eh_admin());
drop policy if exists "subcategorias: admin atualiza" on public.subcategorias;
create policy "subcategorias: admin atualiza" on public.subcategorias
  for update to authenticated using (public.eh_admin()) with check (public.eh_admin());
drop policy if exists "subcategorias: admin apaga" on public.subcategorias;
create policy "subcategorias: admin apaga" on public.subcategorias
  for delete to authenticated using (public.eh_admin());

-- Produtos: público vê só os ativos; admin vê e altera todos ------------
drop policy if exists "produtos: leitura pública dos ativos" on public.produtos;
create policy "produtos: leitura pública dos ativos" on public.produtos
  for select to anon, authenticated using (ativo or public.eh_admin());

drop policy if exists "produtos: admin altera" on public.produtos;
drop policy if exists "produtos: admin insere" on public.produtos;
create policy "produtos: admin insere" on public.produtos
  for insert to authenticated with check (public.eh_admin());
drop policy if exists "produtos: admin atualiza" on public.produtos;
create policy "produtos: admin atualiza" on public.produtos
  for update to authenticated using (public.eh_admin()) with check (public.eh_admin());
drop policy if exists "produtos: admin apaga" on public.produtos;
create policy "produtos: admin apaga" on public.produtos
  for delete to authenticated using (public.eh_admin());

-- Opções: visíveis quando o produto é visível ---------------------------
drop policy if exists "opcoes: leitura pública" on public.produto_opcoes;
create policy "opcoes: leitura pública" on public.produto_opcoes
  for select to anon, authenticated using (
    public.eh_admin()
    or exists (select 1 from public.produtos p where p.id = produto_id and p.ativo)
  );

drop policy if exists "opcoes: admin altera" on public.produto_opcoes;
drop policy if exists "opcoes: admin insere" on public.produto_opcoes;
create policy "opcoes: admin insere" on public.produto_opcoes
  for insert to authenticated with check (public.eh_admin());
drop policy if exists "opcoes: admin atualiza" on public.produto_opcoes;
create policy "opcoes: admin atualiza" on public.produto_opcoes
  for update to authenticated using (public.eh_admin()) with check (public.eh_admin());
drop policy if exists "opcoes: admin apaga" on public.produto_opcoes;
create policy "opcoes: admin apaga" on public.produto_opcoes
  for delete to authenticated using (public.eh_admin());

-- Administradores: cada um só enxerga a própria linha (o painel usa isso
-- para saber se quem entrou é admin). Ninguém altera pelo site/painel:
-- inclua administradores pelo SQL Editor.
drop policy if exists "administradores: vê a si mesmo" on public.administradores;
create policy "administradores: vê a si mesmo" on public.administradores
  for select to authenticated using (user_id = auth.uid());

-- ---------------------------------------------------------------------
-- STORAGE: bucket "produtos" (fotos), público para leitura
-- ---------------------------------------------------------------------
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('produtos', 'produtos', true, 5242880, array['image/jpeg','image/png','image/webp'])
on conflict (id) do update set public = true,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists "fotos produtos: leitura pública" on storage.objects;
create policy "fotos produtos: leitura pública" on storage.objects
  for select to anon, authenticated using (bucket_id = 'produtos');

drop policy if exists "fotos produtos: admin envia" on storage.objects;
create policy "fotos produtos: admin envia" on storage.objects
  for insert to authenticated with check (bucket_id = 'produtos' and public.eh_admin());

drop policy if exists "fotos produtos: admin troca" on storage.objects;
create policy "fotos produtos: admin troca" on storage.objects
  for update to authenticated
  using (bucket_id = 'produtos' and public.eh_admin())
  with check (bucket_id = 'produtos' and public.eh_admin());

drop policy if exists "fotos produtos: admin apaga" on storage.objects;
create policy "fotos produtos: admin apaga" on storage.objects
  for delete to authenticated using (bucket_id = 'produtos' and public.eh_admin());

-- Limpeza: remove a função antiga com acento (versões anteriores deste script)
drop function if exists public."é_admin"();
