-- =====================================================================
-- DEFEMA · Catálogo — 07_mudas_balcao.sql
-- Mudas de bandeja: preço do lote x bandeja fechada (encomenda) e
-- contagem das vendas de balcão para emitir nota fiscal.
--
--  * produtos.preco          = preço do LOTE (10 mudas na bandeja de 200,
--                              4 mudas na bandeja de 128)
--  * produtos.preco_bandeja  = preço da BANDEJA FECHADA (por encomenda)
--  * mudas_movimentos        = cada venda de balcão (tipo 'venda', em mudas)
--                              e cada NF emitida (tipo 'nf', 1 bandeja).
--    Saldo para NF = soma das vendas − soma das NFs.
--
-- Só administradores leem e gravam os movimentos. Pode rodar de novo sem problema.
-- =====================================================================

-- 1) Preço da bandeja fechada ------------------------------------------
alter table public.produtos add column if not exists preco_bandeja numeric(10,2) null;
comment on column public.produtos.preco_bandeja is
  'Mudas de bandeja: preço da bandeja fechada (encomenda). Em produtos.preco fica o preço do lote (10 mudas na de 200, 4 na de 128).';

-- Primeira vez: o preço que estava cadastrado era o da bandeja inteira.
-- Passa ele para preco_bandeja e calcula um preço de lote inicial
-- (proporcional, arredondado para cima em R$ 0,10). A loja ajusta no painel.
update public.produtos p
   set preco_bandeja = p.preco,
       preco = case when s.nome = 'Bandeja 128 mudas'
                    then ceil(p.preco / 128 * 4 * 10) / 10
                    else ceil(p.preco / 200 * 10 * 10) / 10 end,
       preco_antigo = null
  from public.subcategorias s
 where s.id = p.subcategoria_id
   and s.nome in ('Bandeja 200 mudas', 'Bandeja 128 mudas')
   and p.preco_bandeja is null
   and p.preco is not null;

-- 2) Movimentos de balcão ----------------------------------------------
create table if not exists public.mudas_movimentos (
  id          bigserial primary key,
  produto_id  uuid not null references public.produtos(id) on delete cascade,
  tipo        text not null check (tipo in ('venda', 'nf')),
  mudas       int  not null check (mudas > 0 and mudas <= 100000),
  criado_em   timestamptz not null default now(),
  criado_por  uuid null default auth.uid()
);
comment on table public.mudas_movimentos is
  'Vendas de mudas no balcão (tipo venda, em mudas) e NFs emitidas (tipo nf, uma bandeja). Saldo para NF = vendas − nf.';
create index if not exists mudas_movimentos_produto_idx on public.mudas_movimentos (produto_id, criado_em desc);

grant select, insert, delete on public.mudas_movimentos to authenticated;
revoke all on public.mudas_movimentos from anon;
grant usage, select on sequence public.mudas_movimentos_id_seq to authenticated;

alter table public.mudas_movimentos enable row level security;

drop policy if exists "mudas: admin lê" on public.mudas_movimentos;
create policy "mudas: admin lê" on public.mudas_movimentos
  for select to authenticated using (public.eh_admin());
drop policy if exists "mudas: admin registra" on public.mudas_movimentos;
create policy "mudas: admin registra" on public.mudas_movimentos
  for insert to authenticated with check (public.eh_admin());
drop policy if exists "mudas: admin desfaz" on public.mudas_movimentos;
create policy "mudas: admin desfaz" on public.mudas_movimentos
  for delete to authenticated using (public.eh_admin());
